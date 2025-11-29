import '../services/config_service.dart';

// 메뉴 설정 데이터
class MenuConfig {
  final String name;
  final int preFryTime; // 초벌 시간 (초) - 초벌만 하는 시간
  final int cookTime; // 조리 시간 (초) - 초벌 시간을 포함한 전체 조리 시간
  final int shapeTime; // 성형 시간 (초) - 성형을 하는 시간

  const MenuConfig({
    required this.name,
    required this.preFryTime,
    required this.cookTime,
    required this.shapeTime,
  });

  // JSON에서 생성 (전역 shakeTimePercent 사용)
  factory MenuConfig.fromJson(Map<String, dynamic> json, double globalShakeTimePercent) {
    return MenuConfig(
      name: json['name'] as String,
      preFryTime: json['preFryTime'] as int,
      cookTime: json['cookTime'] as int,
      shapeTime: json['shapeTime'] as int,
    );
  }

  // 전역 쉐이킹 시간 퍼센트 가져오기
  double get shakeTimePercent => ConfigService.getGlobalShakeTimePercent();

  // 초벌 후 추가 조리 시간 계산 (조리 시간 - 초벌 시간)
  int get additionalCookTime => cookTime - preFryTime;
  
  // 흔들기 시간 계산 (총 조리시간의 퍼센트)
  int get shakeTime => (cookTime * shakeTimePercent / 100).round();
}

// 메뉴 설정 데이터 저장소
class MenuConfigRepository {
  static List<MenuConfig>? _menus;

  /// 메뉴 목록 가져오기 (JSON에서 로드)
  static Future<List<MenuConfig>> getMenus() async {
    if (_menus != null) {
      return _menus!;
    }
    
    // ConfigService를 통해 로드
    _menus = await ConfigService.loadMenuConfig();
    return _menus!;
  }

  /// 동기 방식으로 메뉴 가져오기 (이미 로드된 경우)
  static List<MenuConfig> getMenusSync() {
    if (_menus == null) {
      throw Exception('Menus not loaded yet. Call getMenus() first.');
    }
    return _menus!;
  }

  static Future<MenuConfig?> getMenuByName(String name) async {
    final menus = await getMenus();
    try {
      return menus.firstWhere((menu) => menu.name == name);
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> getMenuNames() async {
    final menus = await getMenus();
    return menus.map((menu) => menu.name).toList();
  }

  /// 캐시 초기화
  static void clearCache() {
    _menus = null;
  }
}

