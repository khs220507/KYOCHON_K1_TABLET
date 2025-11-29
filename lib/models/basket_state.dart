import '../config/menu_config.dart';

class BasketState {
  final int basketNumber;
  MenuConfig? selectedMenu;
  bool isPreFrying; // 초벌 중
  bool isCooking; // 조리 중
  bool isShaking; // 흔들기 중
  bool isShaping; // 성형 중
  int preFryRemainingTime; // 초벌 남은 시간 (초)
  int cookRemainingTime; // 조리 남은 시간 (초)
  int shakeRemainingTime; // 흔들기 남은 시간 (초)
  int shapeRemainingTime; // 성형 남은 시간 (초)
  bool isWaiting; // 대기중 상태 (목적지 바스켓)
  int? pendingMoveTo; // 몇 번 바스켓으로 이동 예정인지 (출발지 바스켓)
  bool isMoving; // 이동중 상태 (1번 바스켓)
  bool isArrivingSoon; // 곧 도착 예정 상태 (목적지 바스켓)
  bool isUnavailable; // 사용불가 상태 (바스켓이 돌아오는 중)
  bool isOutputting; // 꺼내기중 상태

  BasketState({
    required this.basketNumber,
    this.selectedMenu,
    this.isPreFrying = false,
    this.isCooking = false,
    this.isShaking = false,
    this.isShaping = false,
    this.preFryRemainingTime = 0,
    this.cookRemainingTime = 0,
    this.shakeRemainingTime = 0,
    this.shapeRemainingTime = 0,
    this.isWaiting = false,
    this.pendingMoveTo,
    this.isMoving = false,
    this.isArrivingSoon = false,
    this.isUnavailable = false,
    this.isOutputting = false,
  });

  BasketState copyWith({
    MenuConfig? selectedMenu,
    bool? isPreFrying,
    bool? isCooking,
    bool? isShaking,
    bool? isShaping,
    int? preFryRemainingTime,
    int? cookRemainingTime,
    int? shakeRemainingTime,
    int? shapeRemainingTime,
    bool? isWaiting,
    int? pendingMoveTo,
    bool? isMoving,
    bool? isArrivingSoon,
    bool? isUnavailable,
    bool? isOutputting,
  }) {
    return BasketState(
      basketNumber: basketNumber,
      selectedMenu: selectedMenu ?? this.selectedMenu,
      isPreFrying: isPreFrying ?? this.isPreFrying,
      isCooking: isCooking ?? this.isCooking,
      isShaking: isShaking ?? this.isShaking,
      isShaping: isShaping ?? this.isShaping,
      preFryRemainingTime: preFryRemainingTime ?? this.preFryRemainingTime,
      cookRemainingTime: cookRemainingTime ?? this.cookRemainingTime,
      shakeRemainingTime: shakeRemainingTime ?? this.shakeRemainingTime,
      shapeRemainingTime: shapeRemainingTime ?? this.shapeRemainingTime,
      isWaiting: isWaiting ?? this.isWaiting,
      pendingMoveTo: pendingMoveTo ?? this.pendingMoveTo,
      isMoving: isMoving ?? this.isMoving,
      isArrivingSoon: isArrivingSoon ?? this.isArrivingSoon,
      isUnavailable: isUnavailable ?? this.isUnavailable,
      isOutputting: isOutputting ?? this.isOutputting,
    );
  }

  bool get isEmpty => selectedMenu == null;
}
