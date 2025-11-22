import 'package:flutter/material.dart';
import 'slot_card.dart';

class SlotGrid extends StatelessWidget {
  final double scale;

  const SlotGrid({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    // 슬롯 개수 (예: 6개)
    const int slotCount = 6;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 조리 레이블
          Row(
            children: [
              Image.asset(
                'assets/images/조리.png',
                width: 80 * scale,
                height: 80 * scale,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80 * scale,
                    height: 80 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5D44C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 10 * scale),
              Text(
                '조리',
                style: TextStyle(
                  fontSize: 45 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          // 슬롯 그리드
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              slotCount,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < slotCount - 1 ? 10 * scale : 0,
                  ),
                  child: SlotCard(
                    slotNumber: index,
                    scale: scale,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

