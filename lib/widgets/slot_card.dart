import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final int slotNumber;
  final double scale;

  const SlotCard({
    super.key,
    required this.slotNumber,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400 * scale,
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
          // 메뉴 정보 (비어있음 또는 조리 중)
          Text(
            '비어있음',
            style: TextStyle(
              fontSize: 40 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          // 타이머 정보 (조리 중일 때 표시)
          // TODO: 타이머 표시
        ],
      ),
    );
  }
}

