import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final double scale;

  const HeaderWidget({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120 * scale,
      color: Colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 15 * scale,
      ),
      child: Row(
        children: [
          // 교촌 로고 (흰색)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: Image.asset(
              'assets/images/k1_logo.png',
              width: 300 * scale,
              height: 99 * scale,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 이미지가 없을 경우 대체 UI
                return Container(
                  width: 300 * scale,
                  height: 99 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Center(
                    child: Text(
                      '교촌 로고',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24 * scale,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          // A/S 정보
          Text(
            'A/S : 컴파스시스템 010-8647-0914',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
