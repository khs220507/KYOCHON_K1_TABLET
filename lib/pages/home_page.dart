import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/status_panel.dart';
import '../widgets/slot_grid.dart';
import '../widgets/move_confirmation_dialog.dart';
import '../models/basket_state.dart';
import '../models/fryer_state.dart';
import '../config/menu_config.dart';

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

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          if (_manualFryerState.isPreFrying && _manualFryerState.preFryRemainingTime > 0) {
            newPreFryTime = _manualFryerState.preFryRemainingTime - 1;
            if (newPreFryTime == 0) {
              newIsPreFrying = false;
              preFryJustCompleted = true;
            }
            updated = true;
          }

          // 조리 시간 감소 (초벌과 동시에 진행)
          if (_manualFryerState.isCooking && _manualFryerState.cookRemainingTime > 0) {
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

            // 초벌 완료 + 1번 바스켓 비어있으면 팝업 표시 플래그 설정
            if (preFryJustCompleted && _basketStates[0].isEmpty) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MoveConfirmationDialog(
        scale: scale,
        menuName: _manualFryerState.selectedMenu!.name,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // 확인 버튼을 눌렀을 때 1번 바스켓으로 이동
        _moveToBasket1();
      }
    });
  }

  void _moveToBasket1() {
    if (_manualFryerState.selectedMenu == null || !_basketStates[0].isEmpty) {
      return;
    }

    setState(() {
      // 1번 바스켓에 데이터 이동 (초벌 완료 상태이므로 조리만 진행)
      _basketStates[0] = BasketState(
        basketNumber: 1,
        selectedMenu: _manualFryerState.selectedMenu,
        isPreFrying: false, // 초벌 완료
        isCooking: true, // 조리 시작
        preFryRemainingTime: 0,
        cookRemainingTime: _manualFryerState.cookRemainingTime, // 남은 조리 시간
      );

      // 수동 조리 튀김기 초기화
      _manualFryerState = FryerState();
    });
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
          ),
          
          // 메인 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // 슬롯 그리드
                  SlotGrid(
                    scale: scale,
                    basketStates: _basketStates,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

