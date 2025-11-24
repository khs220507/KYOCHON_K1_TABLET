import '../config/menu_config.dart';

class FryerState {
  MenuConfig? selectedMenu;
  bool isPreFrying; // 초벌 중
  bool isCooking; // 조리 중
  int preFryRemainingTime; // 초벌 남은 시간 (초)
  int cookRemainingTime; // 조리 남은 시간 (초)

  FryerState({
    this.selectedMenu,
    this.isPreFrying = false,
    this.isCooking = false,
    this.preFryRemainingTime = 0,
    this.cookRemainingTime = 0,
  });

  FryerState copyWith({
    MenuConfig? selectedMenu,
    bool? isPreFrying,
    bool? isCooking,
    int? preFryRemainingTime,
    int? cookRemainingTime,
  }) {
    return FryerState(
      selectedMenu: selectedMenu ?? this.selectedMenu,
      isPreFrying: isPreFrying ?? this.isPreFrying,
      isCooking: isCooking ?? this.isCooking,
      preFryRemainingTime: preFryRemainingTime ?? this.preFryRemainingTime,
      cookRemainingTime: cookRemainingTime ?? this.cookRemainingTime,
    );
  }

  bool get isEmpty => selectedMenu == null;
}

