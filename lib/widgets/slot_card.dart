import 'package:flutter/material.dart';
import '../models/basket_state.dart';

class SlotCard extends StatelessWidget {
  final int slotNumber;
  final double scale;
  final BasketState basketState;

  const SlotCard({
    super.key,
    required this.slotNumber,
    required this.scale,
    required this.basketState,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _calculateCookProgress() {
    if (basketState.selectedMenu == null || basketState.cookRemainingTime == 0) {
      return 0;
    }
    final totalCookTime = basketState.selectedMenu!.cookTime;
    final remainingTime = basketState.cookRemainingTime;
    final progress = ((totalCookTime - remainingTime) / totalCookTime * 100).round();
    return progress.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 500 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: EdgeInsets.all(15 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // 슬롯 번호
          Text(
            '${slotNumber + 1}번 바스켓',
            style: TextStyle(
              fontSize: 30 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // 메뉴 정보
          Text(
            basketState.selectedMenu?.name ?? '비어있음',
            style: TextStyle(
              fontSize: 40 * scale,
              fontWeight: FontWeight.bold,
              color: basketState.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
          const Spacer(),
          // 조리 진행률 (퍼센트)
          if (basketState.selectedMenu != null && basketState.isCooking)
            Text(
              '${_calculateCookProgress()}%',
              style: TextStyle(
                fontSize: 50 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          // 타이머 정보
          if (basketState.selectedMenu != null)
            Text(
              '초벌 : ${_formatTime(basketState.preFryRemainingTime)} / 조리 : ${_formatTime(basketState.cookRemainingTime)}',
              style: TextStyle(
                fontSize: 35 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}

