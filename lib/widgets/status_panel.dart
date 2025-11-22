import 'package:flutter/material.dart';
import 'pre_fryer_card.dart';

class StatusPanel extends StatelessWidget {
  final double scale;

  const StatusPanel({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 판교 본사점과 1 투입, 사이드 전용, 수동 조리 튀김기
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 판교 본사점
              Text(
                '판교 본사점',
                style: TextStyle(
                  fontSize: 60 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10 * scale),
              // 1 투입
              _buildCircleNumberLabel(1, '투입', scale),
              SizedBox(height: 10 * scale),
              // 사이드 전용과 수동 조리 튀김기
              Row(
                children: [
                  PreFryerCard(
                    title: '사이드 전용',
                    scale: scale,
                    width: 350 * scale,
                  ),
                  SizedBox(width: 2 * scale),
                  PreFryerCard(
                    title: '수동 조리 튀김기',
                    scale: scale,
                    width: 550 * scale,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // 오른쪽: 로봇 상태와 완료 영역
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 로봇 상태
              Row(
                children: [
                  Text(
                    '로봇 상태 : ',
                    style: TextStyle(
                      fontSize: 40 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // 입체감 있는 LED 인디케이터
                  _buildLEDIndicator(scale),
                  SizedBox(width: 15 * scale),
                  Text(
                    '(스크립트 실행중)',
                    style: TextStyle(
                      fontSize: 40 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00C853), // LED와 동일한 색상
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * scale),
              // 완료 영역
              _buildCompleteArea(scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleNumberLabel(int number, String text, double scale) {
    return Row(
      children: [
        // '투입'일 경우 이미지 사용, 그 외에는 숫자 표시
        text == '투입'
            ? Image.asset(
                'assets/images/투입.png',
                width: 80 * scale,
                height: 80 * scale,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 이미지가 없을 경우 기존 숫자 표시
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
                        number.toString(),
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
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

  Widget _buildLEDIndicator(double scale) {
    const Color ledColor = Color(0xFF00C853); // 녹색 LED
    
    return Container(
      width: 40 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ledColor.withOpacity(0.9),
            ledColor.withOpacity(0.7),
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          // 부드러운 발광 효과
          BoxShadow(
            color: ledColor.withOpacity(0.4),
            blurRadius: 8 * scale,
            spreadRadius: 2 * scale,
          ),
          // 깊이감을 주는 그림자
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteArea(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 완료 레이블 (숫자 없이 이미지만)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/완료.png',
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
                );
              },
            ),
            SizedBox(width: 10 * scale),
            Text(
              '완료',
              style: TextStyle(
                fontSize: 45 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        // 완료 바스켓
        Container(
          width: 400 * scale,
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
      ],
    );
  }
}

