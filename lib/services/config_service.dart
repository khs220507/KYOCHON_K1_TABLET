import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/menu_config.dart';

/// 설정 파일을 로드하는 서비스
class ConfigService {
  static TcpConfigData? _tcpConfig;
  static List<MenuConfig>? _menuConfigs;

  /// TCP 설정 로드
  static Future<TcpConfigData> loadTcpConfig() async {
    if (_tcpConfig != null) {
      print('Using cached TCP config: ${_tcpConfig!.serverHost}:${_tcpConfig!.serverPort}');
      return _tcpConfig!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/config/tcp_config.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      _tcpConfig = TcpConfigData.fromJson(json);
      print('TCP config loaded successfully:');
      print('  Robot: ${_tcpConfig!.robotHost}:${_tcpConfig!.robotPort}');
      print('  Server: ${_tcpConfig!.serverHost}:${_tcpConfig!.serverPort}');
      return _tcpConfig!;
    } catch (e) {
      print('Failed to load TCP config: $e');
      print('Using default TCP config values');
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

  /// 메뉴 설정 로드
  static Future<List<MenuConfig>> loadMenuConfig() async {
    if (_menuConfigs != null) {
      return _menuConfigs!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/config/menu_config.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      final List<dynamic> menusJson = json['menus'] as List<dynamic>;
      _menuConfigs = menusJson.map((menuJson) => MenuConfig.fromJson(menuJson)).toList();
      
      return _menuConfigs!;
    } catch (e) {
      print('Failed to load menu config: $e');
      // 기본값 반환
      return [
        const MenuConfig(
          name: '테스트 메뉴',
          preFryTime: 5,
          cookTime: 20,
          shakeTime: 15,
          shapeTime: 5,
        ),
      ];
    }
  }

  /// 설정 캐시 초기화 (앱 재시작 시)
  static void clearCache() {
    _tcpConfig = null;
    _menuConfigs = null;
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

