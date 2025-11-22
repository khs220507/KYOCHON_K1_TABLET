import 'package:flutter/material.dart';

class CompleteArea extends StatelessWidget {
  final double scale;

  const CompleteArea({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: Row(
        children: [
          // 원형 번호 + "완료" 텍스트
          _buildCircleNumberLabel(2, '완료', scale),
          SizedBox(width: 20 * scale),
          // 완료 바스켓
          Expanded(
            child: Container(
              height: 200 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(20 * scale),
                border: Border.all(color: Colors.black, width: 1),
              ),
              padding: EdgeInsets.all(15 * scale),
              child: Center(
                child: Text(
                  '완료 바스켓',
                  style: TextStyle(
                    fontSize: 40 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleNumberLabel(int number, String text, double scale) {
    return Row(
      children: [
        Container(
          width: 30 * scale,
          height: 30 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFF5D44C),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(width: 10 * scale),
        Text(
          text,
          style: TextStyle(
            fontSize: 45 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

