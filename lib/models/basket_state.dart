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
    );
  }

  bool get isEmpty => selectedMenu == null;
}

