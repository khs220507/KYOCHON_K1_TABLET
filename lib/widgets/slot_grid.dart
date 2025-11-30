import 'package:flutter/material.dart';
import 'slot_card.dart';
import '../models/basket_state.dart';

class SlotGrid extends StatelessWidget {
  final double scale;
  final List<BasketState> basketStates;

  const SlotGrid({
    super.key,
    required this.scale,
    required this.basketStates,
  });

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
                      border: Border.all(color: const Color(0xFF000000), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
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
                  color: const Color(0xFF000000),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          // 슬롯 그리드 (각 바스켓과 버튼들)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              slotCount,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < slotCount - 1 ? 20 * scale : 0,
                  ),
                  child: Column(
                    children: [
                      // 바스켓 카드
                      SlotCard(
                        slotNumber: index,
                        scale: scale,
                        basketState: basketStates[index],
                        shouldBlink: basketStates[index].isMoving || 
                            basketStates[index].isArrivingSoon,
                      ),
                      SizedBox(height: 10 * scale),
                      // 각 바스켓 아래 버튼들 (세로로)
                      _buildBasketButtons(index, scale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBasketButtons(int basketIndex, double scale) {
    return Column(
      children: [
        // 튀김기 청소 버튼
        Container(
          width: double.infinity,
          height: 80 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: const Color(0xFF000000), width: 1),
          ),
          child: Material(
            color: const Color(0x00000000),
            child: InkWell(
              onTap: () {
                // TODO: ${basketIndex + 1}번 바스켓 튀김기 청소 동작 구현 필요
              },
              borderRadius: BorderRadius.circular(20 * scale),
              child: Center(
                child: Text(
                  '튀김기 청소',
                  style: TextStyle(
                    fontSize: 35 * scale,
                    fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        // 바스켓 흔들기 버튼
        Container(
          width: double.infinity,
          height: 80 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: const Color(0xFF000000), width: 1),
          ),
          child: Material(
            color: const Color(0x00000000),
            child: InkWell(
              onTap: () {
                // TODO: ${basketIndex + 1}번 바스켓 흔들기 동작 구현 필요
              },
              borderRadius: BorderRadius.circular(20 * scale),
              child: Center(
                child: Text(
                  '바스켓 흔들기',
                  style: TextStyle(
                    fontSize: 35 * scale,
                    fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        // 오버쿡 / 즉시 완료 버튼
        Container(
          width: double.infinity,
          height: 80 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: const Color(0xFF000000), width: 1),
          ),
          child: Material(
            color: const Color(0x00000000),
            child: InkWell(
              onTap: () {
                // TODO: ${basketIndex + 1}번 바스켓 오버쿡 / 즉시 완료 동작 구현 필요
              },
              borderRadius: BorderRadius.circular(20 * scale),
              child: Center(
                child: Text(
                  '오버쿡 / 즉시 완료',
                  style: TextStyle(
                    fontSize: 35 * scale,
                    fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

