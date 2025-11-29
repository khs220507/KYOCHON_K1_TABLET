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
            basketState.isUnavailable 
                ? '사용불가\n(바스켓이 돌아오는 중)'
                : (basketState.selectedMenu?.name ?? '비어있음'),
            textAlign: basketState.isUnavailable ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: basketState.isUnavailable ? 30 * scale : 40 * scale,
              fontWeight: FontWeight.bold,
              color: basketState.isUnavailable 
                  ? Colors.red
                  : (basketState.isEmpty ? Colors.grey : Colors.black),
            ),
          ),
          // 이동중 상태 표시 (1번 바스켓)
          if (basketState.isMoving)
            Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Text(
                '이동중',
                style: TextStyle(
                  fontSize: 35 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          // 곧 도착 예정 상태 표시 (목적지 바스켓) - 메뉴가 없을 때만 표시
          if (basketState.isArrivingSoon && basketState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Text(
                '곧 도착 예정',
                style: TextStyle(
                  fontSize: 35 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          // 예약됨 상태 표시 (목적지 바스켓 - MOVE_START를 받았을 때)
          if (basketState.isWaiting && !basketState.isArrivingSoon && basketState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Text(
                  '예약됨\n(이동 예정)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ),
          // 대기중 상태 표시 (기타)
          if (basketState.isWaiting && !basketState.isArrivingSoon && !basketState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Text(
                '대기중',
                style: TextStyle(
                  fontSize: 35 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          // 이동 예정 상태 표시 (MOVE_MOTION_START 전)
          if (basketState.pendingMoveTo != null && !basketState.isMoving)
            Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Text(
                '${basketState.pendingMoveTo}번 바스켓으로\n이동 예정',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          // 꺼내기중 상태 표시
          if (basketState.isOutputting)
            Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Text(
                '꺼내기중',
                style: TextStyle(
                  fontSize: 35 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
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
          // 타이머 정보 (이동중이거나 사용불가가 아닐 때만 표시)
          if (basketState.selectedMenu != null && !basketState.isUnavailable)
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

