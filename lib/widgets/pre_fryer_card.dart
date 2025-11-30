import 'package:flutter/material.dart';
import '../models/fryer_state.dart';

class PreFryerCard extends StatelessWidget {
  final String title;
  final double scale;
  final double width;
  final FryerState? fryerState;
  final bool isBasket1Empty;

  const PreFryerCard({
    super.key,
    required this.title,
    required this.scale,
    required this.width,
    this.fryerState,
    this.isBasket1Empty = true,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _calculateCookProgress() {
    if (fryerState?.selectedMenu == null || fryerState!.cookRemainingTime == 0) {
      return 0;
    }
    final totalCookTime = fryerState!.selectedMenu!.cookTime;
    final remainingTime = fryerState!.cookRemainingTime;
    final progress = ((totalCookTime - remainingTime) / totalCookTime * 100).round();
    return progress.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final isSideOnly = title == '사이드 전용';
    final hasMenu = fryerState?.selectedMenu != null;
    
    // 카드 색상 결정: 메뉴 있음 > 기본 색상
    final Color backgroundColor;
    if (hasMenu) {
      // 메뉴가 들어가 있으면 교촌 노란색
      backgroundColor = const Color(0xFFFFD700);
    } else {
      // 비어있으면 기본 색상
      backgroundColor = isSideOnly ? const Color(0xFFDDDCDC) : const Color(0xFFE5E5E5);
    }

    return Container(
      width: width,
      height: 500 * scale,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFF000000), width: 1),
      ),
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            title,
            style: TextStyle(
              fontSize: 35 * scale,
              color: const Color(0xFF000000),
            ),
          ),
          SizedBox(height: 5 * scale),
          // 비어있음 또는 메뉴 정보
          Text(
            fryerState?.selectedMenu?.name ?? '비어있음',
            style: TextStyle(
              fontSize: 50 * scale,
              fontWeight: FontWeight.bold,
              color: (fryerState?.isEmpty ?? true) ? Colors.black : Colors.black,
            ),
          ),
          const Spacer(),
          // 이동 대기중 메시지 (초벌 완료 + 1번 바스켓 비어있음) - 중간에 표시
          if (title == '수동 조리 튀김기' &&
              fryerState?.selectedMenu != null &&
              !fryerState!.isPreFrying &&
              fryerState!.preFryRemainingTime == 0 &&
              isBasket1Empty)
            Text(
              '이동 대기중',
              style: TextStyle(
                fontSize: 50 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          const Spacer(),
          // 조리 진행률 (퍼센트)
          if (fryerState?.selectedMenu != null && fryerState!.isCooking)
            Text(
              '${_calculateCookProgress()}%',
              style: TextStyle(
                fontSize: 60 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          // 타이머 정보
          if (fryerState?.selectedMenu != null)
            Text(
              '초벌 : ${_formatTime(fryerState!.preFryRemainingTime)} / 조리 : ${_formatTime(fryerState!.cookRemainingTime)}',
              style: TextStyle(
                fontSize: 40 * scale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),
        ],
      ),
    );
  }
}

