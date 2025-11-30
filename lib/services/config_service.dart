import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/menu_config.dart';
import '../services/tcp_service.dart';

/// 설정 파일을 로드하는 서비스
class ConfigService {
  static TcpConfigData? _tcpConfig;
  static List<MenuConfig>? _menuConfigs;
  static double? _globalShakeTimePercent;
  static double? _globalOvercookTimePercent;
  static String? _operatingMode; // "production" 또는 "recipe"

  /// TCP 설정 로드
  static Future<TcpConfigData> loadTcpConfig() async {
    if (_tcpConfig != null) {
      debugPrint('Using cached TCP config: ${_tcpConfig!.serverHost}:${_tcpConfig!.serverPort}');
      return _tcpConfig!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/config/tcp_config.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      _tcpConfig = TcpConfigData.fromJson(json);
      debugPrint('TCP config loaded successfully:');
      debugPrint('  Robot: ${_tcpConfig!.robotHost}:${_tcpConfig!.robotPort}');
      debugPrint('  Server: ${_tcpConfig!.serverHost}:${_tcpConfig!.serverPort}');
      return _tcpConfig!;
    } catch (e) {
      debugPrint('Failed to load TCP config: $e');
      debugPrint('Using default TCP config values');
      // 기본값 반환
      _tcpConfig = TcpConfigData(
        robotHost: '0.0.0.0',
        robotPort: 29999,
        robotFeedbackPort: 30004,
        serverHost: 'localhost',
        serverPort: 6601,
      );
      return _tcpConfig!;
    }
  }

  /// 전역 쉐이킹 시간 퍼센트 가져오기
  static double getGlobalShakeTimePercent() {
    return _globalShakeTimePercent ?? 0.83; // 기본값
  }

  /// 전역 쉐이킹 시간 퍼센트 설정
  static void setGlobalShakeTimePercent(double percent) {
    _globalShakeTimePercent = percent;
    // 메뉴 캐시 무효화하여 다시 로드 시 새로운 퍼센트 적용
    _menuConfigs = null;
  }

  /// 전역 오버쿡 시간 퍼센트 설정
  static void setGlobalOvercookTimePercent(double percent) {
    _globalOvercookTimePercent = percent;
  }

  /// 전역 오버쿡 시간 퍼센트 가져오기
  static double getGlobalOvercookTimePercent() {
    return _globalOvercookTimePercent ?? 10.0; // 기본값
  }

  /// 운영 모드 가져오기 ("production" 또는 "recipe")
  static String getOperatingMode() {
    return _operatingMode ?? 'recipe'; // 기본값: 레시피 준수
  }

  /// 운영 모드 설정
  static void setOperatingMode(String mode) {
    final oldMode = _operatingMode;
    if (mode == 'production' || mode == 'recipe') {
      _operatingMode = mode;
    } else {
      _operatingMode = 'recipe'; // 기본값
    }
    
    // 운영모드가 변경되었고 이전 모드가 있었으면 큐 재정렬
    if (oldMode != null && oldMode != _operatingMode) {
      try {
        TcpService.instance.reorderQueueByOperatingMode();
      } catch (e) {
        debugPrint('큐 재정렬 실패 (TcpService가 초기화되지 않았을 수 있음): $e');
      }
    }
  }

  /// 생산량 위주 모드인지 확인
  static bool isProductionMode() {
    return getOperatingMode() == 'production';
  }

  /// 레시피 준수 모드인지 확인
  static bool isRecipeMode() {
    return getOperatingMode() == 'recipe';
  }

  /// 메뉴 설정 로드
  static Future<List<MenuConfig>> loadMenuConfig() async {
    if (_menuConfigs != null) {
      return _menuConfigs!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/config/menu_config.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      // 전역 설정에서 shakeTimePercent, overcookTimePercent, operatingMode 읽기
      if (json.containsKey('globalSettings')) {
        final globalSettings = json['globalSettings'] as Map<String, dynamic>;
        _globalShakeTimePercent = (globalSettings['shakeTimePercent'] as num?)?.toDouble() ?? 0.83;
        _globalOvercookTimePercent = (globalSettings['overcookTimePercent'] as num?)?.toDouble() ?? 10.0;
        _operatingMode = (globalSettings['operatingMode'] as String?) ?? 'recipe';
      } else {
        _globalShakeTimePercent = 0.83; // 기본값
        _globalOvercookTimePercent = 10.0; // 기본값
        _operatingMode = 'recipe'; // 기본값: 레시피 준수
      }
      
      final List<dynamic> menusJson = json['menus'] as List<dynamic>;
      _menuConfigs = menusJson.map((menuJson) => MenuConfig.fromJson(menuJson, _globalShakeTimePercent!)).toList();
      
      return _menuConfigs!;
    } catch (e) {
      debugPrint('Failed to load menu config: $e');
      // 기본값 반환
      _globalShakeTimePercent = 0.83;
      _globalOvercookTimePercent = 10.0;
      _operatingMode = 'recipe';
      return [
        MenuConfig(
          name: '테스트 메뉴',
          preFryTime: 5,
          cookTime: 20,
          shapeTime: 5,
        ),
      ];
    }
  }

  /// 설정 캐시 초기화 (앱 재시작 시)
  static void clearCache() {
    _tcpConfig = null;
    _menuConfigs = null;
    _globalShakeTimePercent = null;
    _globalOvercookTimePercent = null;
    _operatingMode = null;
  }
}

/// TCP 설정 데이터 클래스
class TcpConfigData {
  final String robotHost;
  final int robotPort;
  final int robotFeedbackPort;
  final String serverHost;
  final int serverPort;

  TcpConfigData({
    required this.robotHost,
    required this.robotPort,
    required this.robotFeedbackPort,
    required this.serverHost,
    required this.serverPort,
  });

  factory TcpConfigData.fromJson(Map<String, dynamic> json) {
    return TcpConfigData(
      robotHost: json['robot']?['host'] ?? '0.0.0.0',
      robotPort: json['robot']?['port'] ?? 29999,
      robotFeedbackPort: json['robot']?['feedbackPort'] ?? 30004,
      serverHost: json['server']?['host'] ?? 'localhost',
      serverPort: json['server']?['port'] ?? 6601,
    );
  }
}

