import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/status_panel.dart';
import '../widgets/slot_grid.dart';
import '../widgets/move_confirmation_dialog.dart';
import '../models/basket_state.dart';
import '../models/fryer_state.dart';
import '../config/menu_config.dart';
import '../services/tcp_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 타겟 해상도 상수
  static const double targetWidth = 2944.0;
  static const double targetHeight = 1840.0;

  // 바스켓 상태 관리
  final List<BasketState> _basketStates = List.generate(
    6,
    (index) => BasketState(basketNumber: index + 1),
  );

  // 수동 조리 튀김기 상태
  FryerState _manualFryerState = FryerState();

  Timer? _timer;
  bool _shouldShowMoveDialog = false;
  bool _isCheckingMoveCommand = false; // MOVE 명령어 체크 중 플래그 (중복 방지)

  // TCP 통신 서비스
  final TcpService _tcpService = TcpService();
  StreamSubscription<String>? _serverSubscription;
  StreamSubscription<int>? _queueUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeTcp();
  }

  Future<void> _initializeTcp() async {
    // 6601 포트로 서버 연결
    await _tcpService.connectToServer();

    // 서버 메시지 수신
    _serverSubscription = _tcpService.serverStream.listen((data) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final originalData = data.trim();
      
      print('═══════════════════════════════════════════════════════');
      print('[$timestamp] 📥 서버로부터 명령어 수신');
      print('  포트: 6601 (서버)');
      print('  원본 메시지: "$originalData"');
      print('  현재 RUNNING 상태: ${_tcpService.isRunning}');
      print('═══════════════════════════════════════════════════════');

      // 여러 줄로 나뉘어진 메시지 처리 (각 줄을 개별적으로 처리)
      final lines = originalData.split('\n');
      for (var line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;
        
        final upperLine = trimmedLine.toUpperCase();
        print('[$timestamp] 📋 명령어 라인 처리: "$trimmedLine" (대문자: "$upperLine")');
        
        // RUNNING 상태 확인 및 업데이트
        if (upperLine.contains('MOVE_START') || upperLine.contains('MOVE START')) {
          // MOVE_START_X 명령어: RUNNING 상태 활성화 + 이동 예정 표시
          final oldRunningState = _tcpService.isRunning;
          _tcpService.setRunningState(true);
          
          // MOVE_START_X에서 목적지 바스켓 번호 추출 (X는 0~5, 바스켓 번호는 X+1)
          int? targetBasketNumber;
          int? targetBasketIndexForCommand; // MOVE_X 명령어에서 사용하는 인덱스 (0~5)
          final moveStartMatch = RegExp(r'MOVE_START[_\s]?(\d+)', caseSensitive: false).firstMatch(upperLine);
          if (moveStartMatch != null) {
            final basketIndex = int.tryParse(moveStartMatch.group(1) ?? '');
            if (basketIndex != null) {
              targetBasketIndexForCommand = basketIndex; // 0~5 인덱스
              targetBasketNumber = basketIndex + 1; // 인덱스 0~5를 바스켓 번호 1~6으로 변환
            }
          }
          
          // MOVE_START를 받으면 큐에서 해당 MOVE 명령어 확실하게 제거
          if (targetBasketIndexForCommand != null) {
            _tcpService.removeMoveCommand(targetBasketIndexForCommand);
          }
          
          // 1번 바스켓에 이동 예정 정보 설정 및 목적지 바스켓 예약 상태 설정
          if (targetBasketNumber != null && targetBasketNumber >= 2 && targetBasketNumber <= 6) {
            final targetBasketIndex = targetBasketNumber - 1;
            setState(() {
              // 1번 바스켓에 이동 예정 정보 설정
              _basketStates[0] = _basketStates[0].copyWith(pendingMoveTo: targetBasketNumber);
              // 목적지 바스켓을 예약 상태로 설정 (예약되어 있다는 의미)
              _basketStates[targetBasketIndex] = _basketStates[targetBasketIndex]
                  .copyWith(isWaiting: true);
            });
            print('[$timestamp] 🔴 MOVE_START 명령어 수신: ${targetBasketNumber}번 바스켓으로 이동 예정');
            print('  - ${targetBasketNumber}번 바스켓: 예약 상태로 설정');
          } else {
            print('[$timestamp] 🔴 MOVE_START 명령어 수신 (목적지 바스켓 번호 파싱 실패)');
          }
          
          print('  - RUNNING 상태 변경: $oldRunningState → true');
          print('  - 명령어 전송 중단 (큐에 추가만 가능, 전송 불가)');
          print('  - 큐에 대기 중인 명령어: ${_tcpService.queueLength}개');
          // 처리 중 상태도 해제 (MOVE_START를 받았으므로 명령어 처리가 시작됨)
          _tcpService.setProcessingState(false);
        } else if (upperLine.contains('INPUT_START') || upperLine.contains('INPUT START')) {
          // INPUT_START_X 명령어: RUNNING 상태 활성화
          final oldRunningState = _tcpService.isRunning;
          _tcpService.setRunningState(true);
          print('[$timestamp] 🔴 INPUT_START 명령어 수신');
          print('  - RUNNING 상태 변경: $oldRunningState → true');
          print('  - 명령어 전송 중단 (큐에 추가만 가능, 전송 불가)');
          print('  - 큐에 대기 중인 명령어: ${_tcpService.queueLength}개');
          // 처리 중 상태도 해제 (INPUT_START를 받았으므로 명령어 처리가 시작됨)
          _tcpService.setProcessingState(false);
        } else if (upperLine.contains('INPUT_END') || upperLine.contains('INPUT END')) {
          // INPUT_END_X 명령어: 1번 바스켓 채우기 + RUNNING 해제
          final oldRunningState = _tcpService.isRunning;
          final queueLengthBefore = _tcpService.queueLength;
          _tcpService.setRunningState(false);
          print('[$timestamp] 📥 INPUT_END 명령어 수신: "$trimmedLine"');
          print('  - RUNNING 상태 변경: $oldRunningState → false');
          print('  - 1번 바스켓 채우기 처리 시작');
          print('  - 명령어 전송 재개 가능');
          print('  - 큐에 대기 중인 명령어: $queueLengthBefore개');
          print('  - 큐 처리 재개 중...');
          // 큐 처리 재개
          _tcpService.processQueue();
          print('  - 큐 처리 재개 완료');
          // 1번 바스켓 채우기
          _handleInputEnd();
        } else if (upperLine.contains('MOVE_MOTION_START') || upperLine.contains('MOVE MOTION START')) {
          // MOVE_MOTION_START 명령어: 1번 바스켓 이동중, 목적지 바스켓 곧 도착 예정
          final pendingMoveTo = _basketStates[0].pendingMoveTo;
          if (pendingMoveTo != null && pendingMoveTo >= 2 && pendingMoveTo <= 6) {
            final targetBasketIndex = pendingMoveTo - 1;
            setState(() {
              // 1번 바스켓을 이동중 상태로 설정 (메뉴와 시간 정보는 유지)
              _basketStates[0] = _basketStates[0].copyWith(isMoving: true);
              // 목적지 바스켓을 곧 도착 예정 상태로 설정 (메뉴는 아직 없음)
              _basketStates[targetBasketIndex] = _basketStates[targetBasketIndex]
                  .copyWith(isArrivingSoon: true, isWaiting: false);
            });
            print('[$timestamp] 🚚 MOVE_MOTION_START 명령어 수신');
            print('  - 1번 바스켓: 이동중 상태로 변경 (메뉴/시간 정보 유지)');
            print('  - ${pendingMoveTo}번 바스켓: 곧 도착 예정 상태로 변경');
          } else {
            print('[$timestamp] ⚠️  MOVE_MOTION_START 수신했지만 이동 예정 정보가 없음');
            print('  - pendingMoveTo: $pendingMoveTo');
          }
        } else if (upperLine.contains('MOVE_MOTION_END') || upperLine.contains('MOVE MOTION END')) {
          // MOVE_MOTION_END 명령어: 목적지 바스켓에 메뉴 도착, 1번 바스켓은 사용불가
          final pendingMoveTo = _basketStates[0].pendingMoveTo;
          if (pendingMoveTo != null && pendingMoveTo >= 2 && pendingMoveTo <= 6) {
            final targetBasketIndex = pendingMoveTo - 1;
            setState(() {
              // 1번 바스켓의 메뉴 정보를 목적지 바스켓으로 이동
              final menuFromBasket1 = _basketStates[0].selectedMenu;
              final cookTimeFromBasket1 = _basketStates[0].cookRemainingTime;
              
              if (menuFromBasket1 != null) {
                // 목적지 바스켓에 메뉴 온전히 이동 (정상적으로 표시)
                _basketStates[targetBasketIndex] = BasketState(
                  basketNumber: pendingMoveTo,
                  selectedMenu: menuFromBasket1,
                  isPreFrying: false,
                  isCooking: true,
                  cookRemainingTime: cookTimeFromBasket1,
                  isMoving: false,
                  isArrivingSoon: false,
                );
                
                // 1번 바스켓은 사용불가 상태 (바스켓이 돌아오는 중)
                _basketStates[0] = BasketState(
                  basketNumber: 1,
                  pendingMoveTo: null,
                  isMoving: false,
                  isUnavailable: true, // 사용불가
                );
              }
            });
            print('[$timestamp] 📦 MOVE_MOTION_END 명령어 수신');
            print('  - ${pendingMoveTo}번 바스켓: 메뉴 도착 완료 (정상 표시)');
            print('  - 1번 바스켓: 사용불가 상태 (바스켓이 돌아오는 중)');
          } else {
            print('[$timestamp] ⚠️  MOVE_MOTION_END 수신했지만 이동 예정 정보가 없음');
          }
        } else if (upperLine.contains('MOVE_END') || upperLine.contains('MOVE END')) {
          // MOVE_END 명령어: RUNNING 해제 + 1번 바스켓 사용불가 해제 (비어있음으로)
          final oldRunningState = _tcpService.isRunning;
          final queueLengthBefore = _tcpService.queueLength;
          
          _tcpService.setRunningState(false);
          print('[$timestamp] 🟢 MOVE_END 명령어 수신');
          print('  - RUNNING 상태 변경: $oldRunningState → false');
          print('  - 명령어 전송 재개 가능');
          print('  - 큐에 대기 중인 명령어: $queueLengthBefore개');
          
          // 1번 바스켓 사용불가 해제 (비어있음으로 변경)
          setState(() {
            _basketStates[0] = BasketState(
              basketNumber: 1,
              isUnavailable: false, // 사용불가 해제
            );
          });
          print('  - 1번 바스켓: 사용불가 해제 (비어있음으로 변경)');
          
          print('  - 큐 처리 재개 중...');
          // 큐 처리 재개
          _tcpService.processQueue();
          print('  - 큐 처리 재개 완료');
        } else if (upperLine.contains('MOTION_END') || upperLine.contains('MOTION END')) {
          // MOTION_END 명령어: RUNNING 해제하지 않음 (단순 수신만)
          print('[$timestamp] 📋 MOTION_END 명령어 수신: "$trimmedLine"');
          print('  - RUNNING 상태 유지 (변경 없음)');
          print('  - 현재 RUNNING 상태: ${_tcpService.isRunning}');
        } else {
          // 기타 명령어 수신
          print('[$timestamp] 📋 기타 명령어 수신: "$trimmedLine"');
        }
      }
    });

    // 큐 업데이트 수신 (UI 갱신용)
    _queueUpdateSubscription = _tcpService.queueUpdateStream.listen((
      queueLength,
    ) {
      setState(() {
        // 큐 길이 변경 시 UI 업데이트
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _serverSubscription?.cancel();
    _queueUpdateSubscription?.cancel();
    _tcpService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // 바스켓 타이머 업데이트 (초벌과 조리 동시 진행)
        for (int i = 0; i < _basketStates.length; i++) {
          final basket = _basketStates[i];
          if (basket.selectedMenu != null) {
            bool updated = false;
            int newPreFryTime = basket.preFryRemainingTime;
            int newCookTime = basket.cookRemainingTime;
            bool newIsPreFrying = basket.isPreFrying;
            bool newIsCooking = basket.isCooking;

            // 초벌 시간 감소
            if (basket.isPreFrying && basket.preFryRemainingTime > 0) {
              newPreFryTime = basket.preFryRemainingTime - 1;
              if (newPreFryTime == 0) {
                newIsPreFrying = false;
              }
              updated = true;
            }

            // 조리 시간 감소 (초벌과 동시에 진행)
            if (basket.isCooking && basket.cookRemainingTime > 0) {
              newCookTime = basket.cookRemainingTime - 1;
              if (newCookTime == 0) {
                newIsCooking = false;
              }
              updated = true;
            }

            if (updated) {
              _basketStates[i] = basket.copyWith(
                isPreFrying: newIsPreFrying,
                isCooking: newIsCooking,
                preFryRemainingTime: newPreFryTime,
                cookRemainingTime: newCookTime,
              );
            }
          }
        }

        // 수동 조리 튀김기 타이머 업데이트 (초벌과 조리 동시 진행)
        if (_manualFryerState.selectedMenu != null) {
          bool updated = false;
          int newPreFryTime = _manualFryerState.preFryRemainingTime;
          int newCookTime = _manualFryerState.cookRemainingTime;
          bool newIsPreFrying = _manualFryerState.isPreFrying;
          bool newIsCooking = _manualFryerState.isCooking;
          bool preFryJustCompleted = false;

          // 초벌 시간 감소
          if (_manualFryerState.isPreFrying &&
              _manualFryerState.preFryRemainingTime > 0) {
            newPreFryTime = _manualFryerState.preFryRemainingTime - 1;
            if (newPreFryTime == 0) {
              newIsPreFrying = false;
              preFryJustCompleted = true;
            }
            updated = true;
          }

          // 조리 시간 감소 (초벌과 동시에 진행)
          if (_manualFryerState.isCooking &&
              _manualFryerState.cookRemainingTime > 0) {
            newCookTime = _manualFryerState.cookRemainingTime - 1;
            if (newCookTime == 0) {
              newIsCooking = false;
            }
            updated = true;
          }

          if (updated) {
            _manualFryerState = _manualFryerState.copyWith(
              isPreFrying: newIsPreFrying,
              isCooking: newIsCooking,
              preFryRemainingTime: newPreFryTime,
              cookRemainingTime: newCookTime,
            );

            // 초벌 완료 + 1번 바스켓이 차있고 2~6번 바스켓 중 비어있는 것이 있으면 팝업 표시 플래그 설정
            if (preFryJustCompleted && !_basketStates[0].isEmpty) {
              // 2~6번 바스켓 중 비어있는 것이 있는지 확인
              bool hasEmptyBasket = false;
              for (int i = 1; i < _basketStates.length; i++) {
                if (_basketStates[i].isEmpty) {
                  hasEmptyBasket = true;
                  break;
                }
              }
              if (hasEmptyBasket) {
                _shouldShowMoveDialog = true;
              }
            } else if (preFryJustCompleted && _basketStates[0].isEmpty) {
              // 1번 바스켓이 비어있으면 기존대로 1번으로 이동
              _shouldShowMoveDialog = true;
            }
          }
        }
      });
    });
  }

  void _onMenuSelected(MenuConfig menu) {
    // 수동 조리 튀김기에 메뉴 할당 (초벌과 조리 동시 시작)
    if (_manualFryerState.isEmpty) {
      setState(() {
        _manualFryerState = FryerState(
          selectedMenu: menu,
          isPreFrying: true,
          isCooking: true, // 조리도 동시에 시작
          preFryRemainingTime: menu.preFryTime,
          cookRemainingTime: menu.cookTime,
        );
      });
    }
  }

  void _showMoveConfirmationDialog(BuildContext context, double scale) {
    if (_manualFryerState.selectedMenu == null) return;

    // 이동할 바스켓 번호 결정
    int targetBasketNumber = 1;
    if (!_basketStates[0].isEmpty) {
      // 1번 바스켓이 차있으면 2~6번 바스켓 중 비어있는 것 중 가장 큰 번호 찾기
      for (int i = _basketStates.length - 1; i >= 1; i--) {
        if (_basketStates[i].isEmpty) {
          targetBasketNumber = i + 1;
          break;
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MoveConfirmationDialog(
        scale: scale,
        menuName: _manualFryerState.selectedMenu!.name,
        targetBasketNumber: targetBasketNumber,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // 확인 버튼을 눌렀을 때 적절한 바스켓으로 이동
        _moveToAvailableBasket();
      }
    });
  }

  Future<void> _moveToAvailableBasket() async {
    if (_manualFryerState.selectedMenu == null) {
      print('⚠️  _moveToAvailableBasket: 수동 조리 튀김기에 메뉴가 없음');
      return;
    }

    final selectedMenu = _manualFryerState.selectedMenu!;
    final isTestMenu = selectedMenu.name == '테스트 메뉴';

    int targetBasketIndex = -1;
    int sourceBasketIndex = 0; // 1번 바스켓에서 출발

    // 1번 바스켓 상태 확인
    final isBasket1Empty = _basketStates[0].isEmpty;
    print('🔍 바스켓 이동 로직 시작:');
    print('  - 선택된 메뉴: ${selectedMenu.name}');
    print('  - 테스트 메뉴: $isTestMenu');
    print('  - 1번 바스켓 비어있음: $isBasket1Empty');

    // 1번 바스켓이 비어있으면 1번으로 이동
    if (isBasket1Empty) {
      targetBasketIndex = 0;
      print('  - 목적지: 1번 바스켓 (비어있음)');
    } else {
      // 1번 바스켓이 차있으면 2~6번 바스켓 중 비어있는 것 중 가장 큰 번호 찾기
      print('  - 1번 바스켓이 차있음, 다른 바스켓 찾는 중...');
      for (int i = _basketStates.length - 1; i >= 1; i--) {
        if (_basketStates[i].isEmpty) {
          targetBasketIndex = i;
          print('  - 찾은 목적지: ${i + 1}번 바스켓 (비어있음)');
          break;
        }
      }
      if (targetBasketIndex == -1) {
        print('  - ⚠️  이동할 바스켓을 찾을 수 없음 (모든 바스켓이 차있음)');
      }
    }

    // 이동할 바스켓이 없으면 리턴
    if (targetBasketIndex == -1) {
      print('❌ 이동할 바스켓이 없어 함수 종료');
      return;
    }

    final targetBasketNumber = targetBasketIndex + 1;
    final isBasket1Full = !isBasket1Empty;

    print('  - 최종 목적지: $targetBasketNumber번 바스켓 (인덱스: $targetBasketIndex)');
    print('  - 1번 바스켓 차있음: $isBasket1Full');

    setState(() {
      if (targetBasketIndex == 0) {
        // 1번 바스켓으로 바로 이동 (기존 로직)
        print('  - 1번 바스켓으로 바로 이동');
        _basketStates[0] = BasketState(
          basketNumber: 1,
          selectedMenu: selectedMenu,
          isPreFrying: false, // 초벌 완료
          isCooking: true, // 조리 시작
          preFryRemainingTime: 0,
          cookRemainingTime: _manualFryerState.cookRemainingTime,
        );

        // 수동 조리 튀김기 초기화
        _manualFryerState = FryerState();
        
        // 1번 바스켓이 채워진 후 MOVE 명령어 자동 체크
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndAddMoveCommand();
        });
      } else {
        // 다른 바스켓으로 이동 예정
        print('  - $targetBasketNumber번 바스켓으로 이동 예정');
        // 목적지 바스켓을 대기중 상태로 설정
        _basketStates[targetBasketIndex] = _basketStates[targetBasketIndex]
            .copyWith(isWaiting: true);

        // 1번 바스켓에 이동 예정 상태 설정 (INPUT_END를 받으면 1번 바스켓에 메뉴가 들어감)
        // 수동 조리 튀김기의 메뉴 정보를 임시로 저장해두기 위해 pendingMoveTo에 목적지 저장
        _basketStates[sourceBasketIndex] = _basketStates[sourceBasketIndex]
            .copyWith(pendingMoveTo: targetBasketNumber);

        // 수동 조리 튀김기는 아직 초기화하지 않음 (INPUT_END 후 1번 바스켓 채우고 초기화)
      }
    });

    // 테스트 메뉴인 경우 INPUT_0 명령어 전송
    if (isTestMenu) {
      print('  - 테스트 메뉴: INPUT_0 명령어 전송');
      _tcpService.sendMessage('INPUT_0');
    } else {
      // setState() 후 실제 바스켓 상태 다시 확인
      final actualBasket1Full = !_basketStates[0].isEmpty;
      
      // 다른 바스켓(2~6번) 중 하나라도 비어있는지 확인 (큰 번호부터 찾기)
      bool hasEmptyOtherBasket = false;
      int emptyBasketIndex = -1;
      for (int i = _basketStates.length - 1; i >= 1; i--) {
        if (_basketStates[i].isEmpty) {
          hasEmptyOtherBasket = true;
          emptyBasketIndex = i; // 가장 큰 번호의 비어있는 바스켓
          break;
        }
      }
      
      print('  - 일반 메뉴: 명령어 전송 조건 확인 (setState 후)');
      print('    - 실제 1번 바스켓 차있음: $actualBasket1Full');
      print('    - 다른 바스켓(2~6번) 중 비어있는 바스켓 있음: $hasEmptyOtherBasket');
      print('    - targetBasketIndex: $targetBasketIndex');
      if (hasEmptyOtherBasket) {
        print('    - 비어있는 바스켓 인덱스: $emptyBasketIndex (${emptyBasketIndex + 1}번)');
      }
      
      // 1번 바스켓이 비어있으면 바로 이동 (INPUT_END 없이)
      if (!actualBasket1Full && targetBasketIndex == 0) {
        print('✅ 1번 바스켓이 비어있어 바로 이동 완료');
        // 1번 바스켓이 채워진 후 MOVE 명령어 자동 체크
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndAddMoveCommand();
        });
      } else if (actualBasket1Full && hasEmptyOtherBasket) {
        // 1번 바스켓이 차있고 다른 바스켓으로 이동 예정인 경우
        // MOVE 명령어는 _checkAndAddMoveCommand()에서 처리하므로 여기서는 추가하지 않음
        print('  - 1번 바스켓이 차있어 다른 바스켓으로 이동 예정');
        print('  - MOVE 명령어는 _checkAndAddMoveCommand()에서 자동으로 추가됨');
        // INPUT_END를 받으면 _handleInputEnd()에서 _checkAndAddMoveCommand() 호출됨
      } else {
        print('⚠️  MOVE 명령어 전송 조건 불만족:');
        print('    - 실제 1번 바스켓 차있음: $actualBasket1Full');
        print('    - 다른 바스켓 비어있음: $hasEmptyOtherBasket');
        print('    - targetBasketIndex: $targetBasketIndex');
      }
    }
  }

  // 1번 바스켓이 차있고 다른 바스켓이 비어있으면 MOVE 명령어 자동 추가 (통합된 유일한 전송 지점)
  Future<void> _checkAndAddMoveCommand() async {
    // 이미 체크 중이면 리턴 (중복 방지)
    if (_isCheckingMoveCommand) {
      print('⚠️  MOVE 명령어 체크 중복 방지: 이미 체크 중입니다.');
      return;
    }

    _isCheckingMoveCommand = true;

    try {
      // 1번 바스켓에 메뉴가 있는지 확인
      final isBasket1Full = !_basketStates[0].isEmpty;
      
      if (!isBasket1Full) {
        print('🔍 MOVE 명령어 체크: 1번 바스켓이 비어있음 - MOVE 명령어 불필요');
        return;
      }

      // 2~6번 바스켓 중 하나라도 비어있는지 확인 (큰 번호부터 찾기)
      bool hasEmptyOtherBasket = false;
      int emptyBasketIndex = -1;
      for (int i = _basketStates.length - 1; i >= 1; i--) {
        if (_basketStates[i].isEmpty) {
          hasEmptyOtherBasket = true;
          emptyBasketIndex = i; // 가장 큰 번호의 비어있는 바스켓
          break;
        }
      }

      print('🔍 MOVE 명령어 자동 체크 (통합 전송 지점):');
      print('  - 1번 바스켓 차있음: $isBasket1Full');
      print('  - 다른 바스켓(2~6번) 중 비어있는 바스켓 있음: $hasEmptyOtherBasket');

      // 1번 바스켓이 차있고 다른 바스켓이 비어있으면 MOVE 명령어 추가
      if (isBasket1Full && hasEmptyOtherBasket) {
        final targetBasketNumber = emptyBasketIndex + 1;
        final moveCommand = 'MOVE_${targetBasketNumber - 1}';
        
        // 큐에 이미 같은 MOVE 명령어가 있는지 확인 (중복 방지)
        final queueCommands = _tcpService.queueCommands;
        final alreadyInQueue = queueCommands.contains(moveCommand);
        
        if (alreadyInQueue) {
          print('⚠️  MOVE 명령어 중복 방지: 큐에 이미 "$moveCommand" 명령어가 있음');
          print('  - 큐 내용: $queueCommands');
          return;
        }
        
        print('═══════════════════════════════════════════════════════');
        print('🚀 MOVE 명령어 자동 추가 (통합 전송 지점):');
        print('  - 1번 바스켓 차있음: $isBasket1Full');
        print('  - 다른 바스켓 비어있음: $hasEmptyOtherBasket');
        print('  - 목적지 바스켓 번호: $targetBasketNumber');
        print('  - 전송할 명령어: $moveCommand');
        print('  - RUNNING 상태: ${_tcpService.isRunning}');
        print('  - 큐에 이미 같은 명령어 있음: $alreadyInQueue');
        print('═══════════════════════════════════════════════════════');
        
        // sendMessage()에서도 중복 체크를 하므로, 여기서는 로그만 남김
        final result = await _tcpService.sendMessage(moveCommand);
        if (result) {
          print('  ✅ MOVE 명령어 큐 추가 성공');
        } else {
          print('  ❌ MOVE 명령어 큐 추가 실패 (중복 또는 기타 이유)');
        }
      } else {
        print('  ⚠️  MOVE 명령어 추가 조건 불만족');
        print('    - 1번 바스켓 차있음: $isBasket1Full');
        print('    - 다른 바스켓 비어있음: $hasEmptyOtherBasket');
      }
    } finally {
      // 체크 완료 후 플래그 해제 (약간의 지연을 두어 동시 호출 방지)
      Future.delayed(const Duration(milliseconds: 100), () {
        _isCheckingMoveCommand = false;
      });
    }
  }

  // INPUT_END 메시지 수신 시 처리: 1번 바스켓 채우기
  void _handleInputEnd() {
    if (_manualFryerState.selectedMenu == null) {
      print('⚠️  INPUT_END 수신했지만 수동 조리 튀김기에 메뉴가 없음');
      // 수동 조리 튀김기에 메뉴가 없어도 1번 바스켓 상태를 체크
      _checkAndAddMoveCommand();
      return;
    }

    final selectedMenu = _manualFryerState.selectedMenu!;
    final pendingMoveTo = _basketStates[0].pendingMoveTo;

    setState(() {
      // 1번 바스켓에 메뉴 채우기 (INPUT_END를 받았으므로 메뉴가 들어옴)
      _basketStates[0] = BasketState(
        basketNumber: 1,
        selectedMenu: selectedMenu,
        isPreFrying: false, // 초벌 완료
        isCooking: true, // 조리 시작
        preFryRemainingTime: 0,
        cookRemainingTime: _manualFryerState.cookRemainingTime,
        pendingMoveTo: pendingMoveTo, // 이동 예정 정보 유지
      );

      // 수동 조리 튀김기 초기화
      _manualFryerState = FryerState();

      print('✅ INPUT_END 처리 완료: 1번 바스켓에 ${selectedMenu.name} 채움');
      if (pendingMoveTo != null) {
        print('  → ${pendingMoveTo}번 바스켓으로 이동 예정');
      }
    });

    // 1번 바스켓이 채워진 후 MOVE 명령어 자동 체크
    _checkAndAddMoveCommand();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // 타겟 해상도 비율에 맞춰 스케일 계산
    final widthScale = screenWidth / targetWidth;
    final heightScale = screenHeight / targetHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;

    // 팝업 표시 (초벌 완료 + 1번 바스켓 비어있음)
    if (_shouldShowMoveDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shouldShowMoveDialog = false;
        _showMoveConfirmationDialog(context, scale);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 검은색 헤더
          HeaderWidget(scale: scale),

          // 상단 현황판
          StatusPanel(
            scale: scale,
            onMenuSelected: _onMenuSelected,
            manualFryerState: _manualFryerState,
            isBasket1Empty: _basketStates[0].isEmpty,
            commandQueue: _tcpService.queueCommands,
          ),

          // 메인 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 슬롯 그리드
                  SlotGrid(scale: scale, basketStates: _basketStates),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
