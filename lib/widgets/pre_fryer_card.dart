import 'package:flutter/material.dart';

class PreFryerCard extends StatelessWidget {
  final String title;
  final double scale;
  final double width;

  const PreFryerCard({
    super.key,
    required this.title,
    required this.scale,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isSideOnly = title == '사이드 전용';
    final backgroundColor = isSideOnly ? const Color(0xFFDDDCDC) : const Color(0xFFE5E5E5);

    return Container(
      width: width,
      height: 500 * scale,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.black, width: 1),
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
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5 * scale),
          // 비어있음 또는 메뉴 정보
          Text(
            '비어있음',
            style: TextStyle(
              fontSize: 50 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // 하단 정보 (조리 중일 때 표시)
          // TODO: 조리 상태에 따라 퍼센트, 시간 표시
        ],
      ),
    );
  }
}

