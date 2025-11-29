import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import '../config/tcp_config.dart';
import '../services/config_service.dart';

class TcpService {
  Socket? _commandSocket;
  Socket? _feedbackSocket;
  Socket? _serverSocket; // 6601 포트로 메시지를 보내는 소켓
  ServerSocket? _serverListener; // 서버로 메시지를 받는 리스너

  final StreamController<String> _commandController =
      StreamController<String>.broadcast();
  final StreamController<String> _feedbackController =
      StreamController<String>.broadcast();
  final StreamController<String> _serverController =
      StreamController<String>.broadcast();
  final StreamController<int> _queueUpdateController =
      StreamController<int>.broadcast();

  bool _isConnected = false;
  bool _isRunning = false; // RUNNING 상태 여부

  // 명령어 큐
  final Queue<String> _commandQueue = Queue<String>();
  bool _isProcessingQueue = false;

  // 명령어 포트로 연결
  Future<bool> connectToRobot() async {
    try {
      final config = await TcpConfig.loadConfig();
      _commandSocket = await Socket.connect(config.robotHost, config.robotPort);
      _commandSocket!.listen(
        (data) {
          final message = utf8.decode(data);
          _commandController.add(message);
        },
        onError: (error) {
          print('Command socket error: $error');
        },
        onDone: () {
          print('Command socket closed');
          _isConnected = false;
        },
      );
      return true;
    } catch (e) {
      print('Failed to connect to robot: $e');
      return false;
    }
  }

  // 피드백 포트로 연결
  Future<bool> connectToFeedback() async {
    try {
      final config = await TcpConfig.loadConfig();
      _feedbackSocket = await Socket.connect(
        config.robotHost,
        config.robotFeedbackPort,
      );
      _feedbackSocket!.listen(
        (data) {
          final message = utf8.decode(data);
          _feedbackController.add(message);
        },
        onError: (error) {
          print('Feedback socket error: $error');
        },
        onDone: () {
          print('Feedback socket closed');
        },
      );
      return true;
    } catch (e) {
      print('Failed to connect to feedback: $e');
      return false;
    }
  }

  // 6601 포트로 서버에 연결 (기본 전송 포트)
  Future<bool> connectToServer({String? host}) async {
    TcpConfigData? config;
    String? serverHost;
    int? serverPort;

    try {
      config = await TcpConfig.loadConfig();
      serverHost = host ?? config.serverHost;
      serverPort = config.serverPort;

      print('Attempting to connect to server: $serverHost:$serverPort');
      print(
        'Config loaded - serverHost: ${config.serverHost}, serverPort: ${config.serverPort}',
      );

      _serverSocket = await Socket.connect(serverHost, serverPort);
      _isConnected = true;

      _serverSocket!.listen(
        (data) {
          final message = utf8.decode(data);
          _serverController.add(message);
        },
        onError: (error) {
          print('Server socket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('Server socket closed');
          _isConnected = false;
        },
      );

      print('Successfully connected to server at $serverHost:$serverPort');
      return true;
    } catch (e) {
      print('Failed to connect to server: $e');
      config ??= await TcpConfig.loadConfig();
      print('Connection attempt details:');
      print('  Target host: ${serverHost ?? 'unknown'}');
      print('  Target port: ${serverPort ?? 'unknown'}');
      print('  Config serverHost: ${config.serverHost}');
      print('  Config serverPort: ${config.serverPort}');
      print('Note: On Android emulator, use 10.0.2.2 instead of localhost');
      print(
        'Note: On physical device, use your computer\'s IP address instead of localhost',
      );
      _isConnected = false;
      return false;
    }
  }

  // 서버 소켓 시작 (K1 시스템에서 메시지 수신)
  Future<bool> startServerListener() async {
    try {
      final config = await TcpConfig.loadConfig();
      _serverListener = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        config.serverPort,
      );
      _serverListener!.listen(
        (Socket socket) {
          socket.listen(
            (data) {
              final message = utf8.decode(data);
              _serverController.add(message);
            },
            onError: (error) {
              print('Server listener socket error: $error');
            },
            onDone: () {
              socket.destroy();
            },
          );
        },
        onError: (error) {
          print('Server listener error: $error');
        },
      );
      print('Server listener started on port ${config.serverPort}');
      return true;
    } catch (e) {
      print('Failed to start server listener: $e');
      return false;
    }
  }

  // 큐 상태 출력 헬퍼 함수
  void _printQueueStatus(String action, String? message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('═══════════════════════════════════════════════════════');
    print('[$timestamp] 📋 큐 대기열 상태: $action');
    if (message != null) {
      print('  명령어: $message');
    }
    print('  큐 길이: ${_commandQueue.length}개');
    if (_commandQueue.isNotEmpty) {
      print('  큐 내용:');
      int index = 1;
      for (var cmd in _commandQueue) {
        print('    [$index] $cmd');
        index++;
      }
    } else {
      print('  큐 내용: (비어있음)');
    }
    print('  RUNNING 상태: $_isRunning');
    print('  처리 중: $_isProcessingQueue');
    print('═══════════════════════════════════════════════════════');
  }

  // 6601 포트로 메시지 전송 (큐에 추가)
  // 명령어 추가는 언제든지 가능, 실제 전송은 RUNNING 상태가 false일 때만
  Future<bool> sendMessage(String message) async {
    final timestamp = DateTime.now().toString().substring(11, 19);

    // MOVE 명령어의 경우 중복 체크 (큐에 추가하기 전에)
    if (message.toUpperCase().startsWith('MOVE_')) {
      if (_commandQueue.contains(message)) {
        print('[$timestamp] ⚠️  MOVE 명령어 중복 방지: 큐에 이미 "$message" 명령어가 있음');
        print('  - 큐 내용: $_commandQueue');
        print('  - 명령어 추가 취소');
        return false; // 중복이므로 추가하지 않음
      }
    }

    // 우선순위에 따라 명령어를 큐에 삽입
    _insertCommandByPriority(message);
    
    final operatingMode = ConfigService.getOperatingMode();
    final priority = _getCommandPriority(message);
    
    if (_isRunning) {
      print('[$timestamp] 📋 명령어 큐에 추가 (RUNNING 상태이지만 큐에 추가): $message');
      print('  - 운영 모드: $operatingMode');
      print('  - 우선순위: $priority');
      print('  ⏸️  실제 전송은 RUNNING 상태가 해제된 후 진행됩니다.');
    } else {
      print('[$timestamp] 📋 명령어 큐에 추가: $message');
      print('  - 운영 모드: $operatingMode');
      print('  - 우선순위: $priority');
    }
    _printQueueStatus('명령어 추가', message);

    // 큐 업데이트 알림 (안전하게)
    if (!_queueUpdateController.isClosed) {
      _queueUpdateController.add(_commandQueue.length);
    }

    // 큐 처리 시작 (RUNNING 상태가 아니면)
    if (!_isRunning) {
      _processQueue();
    } else {
      print('[$timestamp] ⏸️  RUNNING 상태: 큐 처리는 END 메시지 수신 후 재개됩니다.');
    }

    // 큐에 추가 완료
    return true;
  }

  /// 이머전시 명령어를 큐에 추가 (E_OUTPUT은 최우선, E_OUTPUT들 사이에서는 먼저 추가된 것이 먼저 처리)
  Future<bool> sendEmergencyMessage(String message) async {
    final timestamp = DateTime.now().toString().substring(11, 19);

    // E_OUTPUT 명령어는 최우선순위로 추가
    _insertCommandByPriority(message);
    
    final priority = _getCommandPriority(message);
    print('[$timestamp] 🚨 이머전시 명령어 큐에 추가: $message');
    print('  - 우선순위: $priority (최우선)');
    print('  - E_OUTPUT들 사이에서는 먼저 추가된 것이 먼저 처리됨');
    
    _printQueueStatus('이머전시 명령어 추가', message);

    // 큐 업데이트 알림 (안전하게)
    if (!_queueUpdateController.isClosed) {
      _queueUpdateController.add(_commandQueue.length);
    }

    // 큐 처리 시작 (RUNNING 상태가 아니면)
    if (!_isRunning) {
      _processQueue();
    } else {
      print('[$timestamp] ⏸️  RUNNING 상태: 큐 처리는 END 메시지 수신 후 재개됩니다.');
    }

    return true;
  }

  /// 명령어 우선순위 계산
  /// 조리시간 준수: INPUT(1) -> OUTPUT(2) -> MOVE(3) -> SHAPING(4) -> CLEAN(5)
  /// 생산량 위주: E_OUTPUT(0) -> INPUT(1) -> MOVE(2) -> OUTPUT(3) -> SHAPING(4) -> CLEAN(5)
  int _getCommandPriority(String command) {
    final upperCmd = command.toUpperCase();
    final isProduction = ConfigService.isProductionMode();
    
    // E_OUTPUT은 항상 최우선 (생산량 위주 모드에서만 사용)
    if (upperCmd.startsWith('E_OUTPUT_')) {
      return 0;
    }
    
    if (isProduction) {
      // 생산량 위주: INPUT(1) -> MOVE(2) -> OUTPUT(3) -> SHAPING(4) -> CLEAN(5)
      if (upperCmd.startsWith('INPUT_')) return 1;
      if (upperCmd.startsWith('MOVE_')) return 2;
      if (upperCmd.startsWith('OUTPUT_')) return 3;
      if (upperCmd.startsWith('SHAPING_')) return 4;
      if (upperCmd.startsWith('CLEAN_')) return 5;
    } else {
      // 조리시간 준수: INPUT(1) -> OUTPUT(2) -> MOVE(3) -> SHAPING(4) -> CLEAN(5)
      if (upperCmd.startsWith('INPUT_')) return 1;
      if (upperCmd.startsWith('OUTPUT_')) return 2;
      if (upperCmd.startsWith('MOVE_')) return 3;
      if (upperCmd.startsWith('SHAPING_')) return 4;
      if (upperCmd.startsWith('CLEAN_')) return 5;
    }
    
    // 알 수 없는 명령어는 낮은 우선순위
    return 99;
  }

  /// 우선순위에 따라 명령어를 큐에 삽입
  void _insertCommandByPriority(String message) {
    final messagePriority = _getCommandPriority(message);
    
    // 큐가 비어있으면 그냥 추가
    if (_commandQueue.isEmpty) {
      _commandQueue.add(message);
      return;
    }
    
    // 우선순위에 따라 적절한 위치 찾기
    int insertIndex = _commandQueue.length;
    for (int i = 0; i < _commandQueue.length; i++) {
      final cmd = _commandQueue.elementAt(i);
      final cmdPriority = _getCommandPriority(cmd);
      
      // 같은 우선순위면 먼저 추가된 것이 앞에 (FIFO)
      if (messagePriority < cmdPriority) {
        insertIndex = i;
        break;
      }
    }
    
    // 적절한 위치에 삽입
    if (insertIndex == _commandQueue.length) {
      _commandQueue.add(message);
    } else {
      final tempList = _commandQueue.toList();
      tempList.insert(insertIndex, message);
      _commandQueue.clear();
      _commandQueue.addAll(tempList);
    }
  }

  // 명령어 큐 처리 (한 번에 하나만 처리)
  Future<void> _processQueue() async {
    // 이미 처리 중이면 리턴
    if (_isProcessingQueue || _commandQueue.isEmpty) {
      if (_commandQueue.isEmpty) {
        final timestamp = DateTime.now().toString().substring(11, 19);
        print('[$timestamp] ℹ️  큐 처리 시도: 큐가 비어있음');
      }
      return;
    }

    // RUNNING 상태가 아니면 처리 시작
    if (_isRunning) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      print('[$timestamp] ⏸️  RUNNING 상태: 큐 처리 대기 중');
      return;
    }

    _isProcessingQueue = true;
    _printQueueStatus('큐 처리 시작 (명령어 1개만 처리)', null);

    // 한 번에 하나의 명령어만 처리
    if (_commandQueue.isNotEmpty) {
      // RUNNING 상태가 되면 큐 처리 중단
      if (_isRunning) {
        final timestamp = DateTime.now().toString().substring(11, 19);
        print('[$timestamp] ⚠️  RUNNING 상태 감지: 명령어 큐 처리 중단');
        _printQueueStatus('큐 처리 중단 (RUNNING 상태)', null);
        _isProcessingQueue = false;
        return;
      }

      final message = _commandQueue.removeFirst(); // 큐에서 제거
      final config = await TcpConfig.loadConfig();
      final timestamp = DateTime.now().toString().substring(11, 19);

      print('═══════════════════════════════════════════════════════');
      print('[$timestamp] 📤 명령어 전송 시도 (큐에서 처리 - 1개만)');
      print('  포트: ${config.serverPort} (서버)');
      print('  호스트: ${config.serverHost}');
      print('  명령어: $message');
      print('  큐에서 제거됨: ✅ (전송 시도 전에 큐에서 제거)');
      print('═══════════════════════════════════════════════════════');
      
      // 큐에서 제거 후 상태 출력
      _printQueueStatus('명령어 큐에서 제거 (전송 시도)', message);

      if (_serverSocket == null || !_isConnected) {
        // 연결이 안 되어 있으면 자동으로 연결 시도
        print('[$timestamp] ⚠️  서버 연결되지 않음, 연결 시도 중...');
        final connected = await connectToServer();
        if (!connected) {
          print('[$timestamp] ❌ 명령어 전송 실패: 서버 연결 불가');
          print('[$timestamp] ⚠️  명령어를 큐에 다시 추가: $message');
          _commandQueue.addFirst(message); // 실패한 명령어를 다시 큐 앞에 추가
          _isProcessingQueue = false;
          return;
        }
      }

      try {
        _serverSocket!.add(utf8.encode(message));
        print('[$timestamp] ✅ 명령어 전송 성공: $message');
        print('  → ${config.serverHost}:${config.serverPort}로 전송됨');
        print('  큐 상태: 명령어가 큐에서 제거되어 전송됨 (큐에 남은 명령어: ${_commandQueue.length}개)');

        // MOVE 명령어인 경우 전송 후 즉시 처리 중 상태 해제
        // (MOVE_START를 받으면 명령어 처리가 시작된 것이므로)
        if (message.toUpperCase().startsWith('MOVE_')) {
          _isProcessingQueue = false;
          print('[$timestamp] 🔄 MOVE 명령어 전송 완료: 처리 중 상태 해제');
          print('  - MOVE_START 수신 대기 중...');
        }

        // 큐 업데이트 알림 (명령어가 큐에서 제거됨) (안전하게)
        if (!_queueUpdateController.isClosed) {
          _queueUpdateController.add(_commandQueue.length);
        }

        // 명령어 전송 후 약간의 대기 시간 (서버 처리 시간 고려)
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('[$timestamp] ❌ 명령어 전송 실패: $e');
        print('  명령어: $message');
        print('[$timestamp] ⚠️  명령어를 큐 앞에 다시 추가: $message');
        _commandQueue.addFirst(message); // 실패한 명령어를 다시 큐 앞에 추가
        print('  큐 상태: 전송 실패로 인해 큐 앞에 재추가됨 (큐에 남은 명령어: ${_commandQueue.length}개)');
        _printQueueStatus('명령어 전송 실패 - 큐에 재추가', message);
        _isConnected = false;
        _isProcessingQueue = false;
        return;
      }
    }

    _isProcessingQueue = false;
    _printQueueStatus('명령어 1개 처리 완료', null);

    // 큐 업데이트 알림 (안전하게)
    if (!_queueUpdateController.isClosed) {
      _queueUpdateController.add(_commandQueue.length);
    }
    
    // 큐에 더 많은 명령어가 있으면 로그만 출력 (다음 RUNNING 해제 시 처리)
    if (_commandQueue.isNotEmpty) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      print('[$timestamp] ℹ️  큐에 ${_commandQueue.length}개 명령어 대기 중 (다음 RUNNING 해제 시 처리)');
    }
  }

  // RUNNING 상태 설정
  void setRunningState(bool isRunning) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final oldState = _isRunning;
    _isRunning = isRunning;
    
    if (oldState != isRunning) {
      print('[$timestamp] 🔄 RUNNING 상태 변경: $oldState → $isRunning');
      _printQueueStatus('RUNNING 상태 변경', null);
    }
  }

  // 처리 중 상태 설정 (외부에서 호출 가능)
  void setProcessingState(bool isProcessing) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final oldState = _isProcessingQueue;
    _isProcessingQueue = isProcessing;
    
    if (oldState != isProcessing) {
      print('[$timestamp] 🔄 처리 중 상태 변경: $oldState → $isProcessing');
      _printQueueStatus('처리 중 상태 변경', null);
    }
  }

  // RUNNING 상태 확인
  bool get isRunning => _isRunning;

  // 큐에 있는 명령어 개수 확인
  int get queueLength => _commandQueue.length;

  // 큐에 있는 명령어 목록 가져오기 (읽기 전용)
  List<String> get queueCommands => List.unmodifiable(_commandQueue);

  // 큐 처리 재개 (외부에서 호출 가능)
  void processQueue() {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('[$timestamp] 🔄 큐 처리 재개 요청');
    _printQueueStatus('큐 처리 재개', null);
    _processQueue();
  }

  // 큐에서 특정 MOVE 명령어 제거 (MOVE_START 수신 시 호출)
  void removeMoveCommand(int targetBasketIndex) {
    final moveCommand = 'MOVE_$targetBasketIndex';
    final removed = _commandQueue.remove(moveCommand);
    
    if (removed) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      print('[$timestamp] 🗑️  MOVE 명령어 큐에서 제거: $moveCommand');
      _printQueueStatus('MOVE 명령어 제거', moveCommand);
      
      // 큐 업데이트 알림
      if (!_queueUpdateController.isClosed) {
        _queueUpdateController.add(_commandQueue.length);
      }
    }
  }

  // 큐에서 특정 OUTPUT 명령어 제거 (E_OUTPUT 생성 시 호출)
  void removeOutputCommand(int basketIndex) {
    final outputCommand = 'OUTPUT_$basketIndex';
    final removed = _commandQueue.remove(outputCommand);
    
    if (removed) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      print('[$timestamp] 🗑️  OUTPUT 명령어 큐에서 제거: $outputCommand');
      _printQueueStatus('OUTPUT 명령어 제거', outputCommand);
      
      // 큐 업데이트 알림
      if (!_queueUpdateController.isClosed) {
        _queueUpdateController.add(_commandQueue.length);
      }
    }
  }

  // 큐 초기화
  void clearQueue() {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('[$timestamp] 🗑️  명령어 큐 초기화 요청');
    _commandQueue.clear();
    _isProcessingQueue = false;
    if (!_queueUpdateController.isClosed) {
      _queueUpdateController.add(0);
    }
    _printQueueStatus('큐 초기화 완료', null);
  }

  // 명령어 전송 (로봇 포트로)
  Future<void> sendCommand(String command) async {
    final config = await TcpConfig.loadConfig();
    final timestamp = DateTime.now().toString().substring(11, 19);

    print('═══════════════════════════════════════════════════════');
    print('[$timestamp] 📤 로봇 명령어 전송 시도');
    print('  포트: ${config.robotPort} (로봇 명령어)');
    print('  호스트: ${config.robotHost}');
    print('  명령어: $command');
    print('═══════════════════════════════════════════════════════');

    if (_commandSocket != null) {
      try {
        _commandSocket!.add(utf8.encode(command));
        print('[$timestamp] ✅ 로봇 명령어 전송 성공: $command');
        print('  → ${config.robotHost}:${config.robotPort}로 전송됨');
      } catch (e) {
        print('[$timestamp] ❌ 로봇 명령어 전송 실패: $e');
        print('  명령어: $command');
      }
    } else {
      print('[$timestamp] ⚠️  로봇 소켓이 연결되지 않음');
      print('  명령어: $command (전송되지 않음)');
    }
  }

  // 연결 상태 확인
  bool get isConnected => _isConnected;

  // 스트림 구독
  Stream<String> get commandStream => _commandController.stream;
  Stream<String> get feedbackStream => _feedbackController.stream;
  Stream<String> get serverStream => _serverController.stream;
  Stream<int> get queueUpdateStream => _queueUpdateController.stream;

  // 연결 종료
  Future<void> disconnect() async {
    await _commandSocket?.close();
    await _feedbackSocket?.close();
    await _serverSocket?.close();
    await _serverListener?.close();
    _commandSocket = null;
    _feedbackSocket = null;
    _serverSocket = null;
    _serverListener = null;
    _isConnected = false;
  }

  void dispose() {
    clearQueue();
    disconnect();
    _commandController.close();
    _feedbackController.close();
    _serverController.close();
    _queueUpdateController.close();
  }
}
