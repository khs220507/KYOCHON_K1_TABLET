import '../services/config_service.dart';

// TCP 통신 설정
class TcpConfig {
  static TcpConfigData? _config;

  /// 설정 로드 (JSON에서)
  static Future<TcpConfigData> loadConfig() async {
    if (_config != null) {
      return _config!;
    }
    _config = await ConfigService.loadTcpConfig();
    return _config!;
  }

  /// 동기 방식으로 설정 가져오기 (이미 로드된 경우)
  static TcpConfigData getConfigSync() {
    if (_config == null) {
      throw Exception('TCP config not loaded yet. Call loadConfig() first.');
    }
    return _config!;
  }

  // 편의 메서드들
  static Future<String> get robotHost async => (await loadConfig()).robotHost;
  static Future<int> get robotPort async => (await loadConfig()).robotPort;
  static Future<int> get robotFeedbackPort async =>
      (await loadConfig()).robotFeedbackPort;
  static Future<String> get serverHost async => (await loadConfig()).serverHost;
  static Future<int> get serverPort async => (await loadConfig()).serverPort;

  // 동기 버전 (로드 후 사용)
  static String get robotHostSync => getConfigSync().robotHost;
  static int get robotPortSync => getConfigSync().robotPort;
  static int get robotFeedbackPortSync => getConfigSync().robotFeedbackPort;
  static String get serverHostSync => getConfigSync().serverHost;
  static int get serverPortSync => getConfigSync().serverPort;

  /// 캐시 초기화
  static void clearCache() {
    _config = null;
  }
}
