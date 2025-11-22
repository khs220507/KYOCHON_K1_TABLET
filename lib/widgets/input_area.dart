import 'package:flutter/material.dart';
import 'pre_fryer_card.dart';

class InputArea extends StatelessWidget {
  final double scale;

  const InputArea({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: Row(
        children: [
          SizedBox(width: 40 * scale), // 1 투입 이미지와 텍스트 너비만큼 공간 확보
          SizedBox(width: 20 * scale),
          // 초벌 프라이어 영역
          Expanded(
            child: Row(
              children: [
                // 사이드 전용 카드
                PreFryerCard(
                  title: '사이드 전용',
                  scale: scale,
                  width: 350 * scale,
                ),
                SizedBox(width: 2 * scale),
                // 수동 조리 튀김기 카드
                PreFryerCard(
                  title: '수동 조리 튀김기',
                  scale: scale,
                  width: 550 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

