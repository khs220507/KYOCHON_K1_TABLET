// 메뉴 설정 데이터
class MenuConfig {
  final String name;
  final int preFryTime; // 초벌 시간 (초) - 초벌만 하는 시간
  final int cookTime; // 조리 시간 (초) - 초벌 시간을 포함한 전체 조리 시간
  final int shakeTime; // 흔들기 시간 (초) - 흔들기를 하는 시간
  final int shapeTime; // 성형 시간 (초) - 성형을 하는 시간

  const MenuConfig({
    required this.name,
    required this.preFryTime,
    required this.cookTime,
    required this.shakeTime,
    required this.shapeTime,
  });

  // 초벌 후 추가 조리 시간 계산 (조리 시간 - 초벌 시간)
  int get additionalCookTime => cookTime - preFryTime;
}

// 메뉴 설정 데이터 저장소
class MenuConfigRepository {
  static final List<MenuConfig> menus = [
    const MenuConfig(
      name: '테스트 메뉴',
      preFryTime: 5, // 5초
      cookTime: 20, // 20초 (초벌 5초 포함)
      shakeTime: 15, // 15초
      shapeTime: 5, // 5초
    ),
    const MenuConfig(
      name: '후라이드 치킨',
      preFryTime: 300, // 5분
      cookTime: 600, // 10분
      shakeTime: 5, // 5초
      shapeTime: 30, // 30초
    ),
    const MenuConfig(
      name: '양념 치킨',
      preFryTime: 300, // 5분
      cookTime: 600, // 10분
      shakeTime: 5, // 5초
      shapeTime: 30, // 30초
    ),
    const MenuConfig(
      name: '간장 치킨',
      preFryTime: 300, // 5분
      cookTime: 600, // 10분
      shakeTime: 5, // 5초
      shapeTime: 30, // 30초
    ),
    const MenuConfig(
      name: '마늘 치킨',
      preFryTime: 300, // 5분
      cookTime: 600, // 10분
      shakeTime: 5, // 5초
      shapeTime: 30, // 30초
    ),
    // 추가 메뉴는 여기에 추가
  ];

  static MenuConfig? getMenuByName(String name) {
    try {
      return menus.firstWhere((menu) => menu.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<String> getMenuNames() {
    return menus.map((menu) => menu.name).toList();
  }
}

