import 'package:flutter/material.dart';
import 'pre_fryer_card.dart';
import 'menu_selection_dialog.dart';
import '../config/menu_config.dart';
import '../models/fryer_state.dart';

class StatusPanel extends StatelessWidget {
  final double scale;
  final Function(MenuConfig)? onMenuSelected;
  final FryerState? manualFryerState;
  final bool isBasket1Empty;
  final List<String>? commandQueue; // 명령어 큐

  const StatusPanel({
    super.key,
    required this.scale,
    this.onMenuSelected,
    this.manualFryerState,
    this.isBasket1Empty = true,
    this.commandQueue,
  });

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
                  SizedBox(width: 20 * scale),
                  PreFryerCard(
                    title: '수동 조리 튀김기',
                    scale: scale,
                    width: 550 * scale,
                    fryerState: manualFryerState,
                    isBasket1Empty: isBasket1Empty,
                  ),
                  SizedBox(width: 20 * scale),
                  // 치킨 버튼과 사이드 버튼
                  Column(
                    children: [
                      // 치킨 버튼
                      Container(
                        width: 280 * scale,
                        height: 240 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => MenuSelectionDialog(
                                  scale: scale,
                                  onMenuSelected: (MenuConfig menu) {
                                    if (onMenuSelected != null) {
                                      onMenuSelected!(menu);
                                    }
                                  },
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20 * scale),
                            child: Center(
                              child: Text(
                                '치킨',
                                style: TextStyle(
                                  fontSize: 60 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      // 사이드 버튼
                      Container(
                        width: 280 * scale,
                        height: 240 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDDCDC),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: 사이드 버튼 동작
                            },
                            borderRadius: BorderRadius.circular(20 * scale),
                            child: Center(
                              child: Text(
                                '사이드',
                                style: TextStyle(
                                  fontSize: 60 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
              // 명령어 큐 대기열
              _buildCommandQueue(scale),
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
            ledColor,
            ledColor.withOpacity(0.8),
            ledColor.withOpacity(0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          // 미묘한 발광 효과 (번짐 최소화)
          BoxShadow(
            color: ledColor.withOpacity(0.3),
            blurRadius: 4 * scale,
            spreadRadius: 1 * scale,
          ),
          // 입체감을 주는 그림자
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 3 * scale,
            offset: Offset(0, 2 * scale),
          ),
          // 내부 그림자 효과
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 1 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 상단 왼쪽 하이라이트
          Positioned(
            top: 6 * scale,
            left: 6 * scale,
            child: Container(
              width: 12 * scale,
              height: 12 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandQueue(double scale) {
    final queue = commandQueue ?? [];
    
    return Container(
      width: 500 * scale,
      padding: EdgeInsets.all(15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '명령어 큐 대기열',
            style: TextStyle(
              fontSize: 35 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10 * scale),
          if (queue.isEmpty)
            Text(
              '대기 중인 명령어 없음',
              style: TextStyle(
                fontSize: 30 * scale,
                color: Colors.grey,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: queue.asMap().entries.map((entry) {
                final index = entry.key;
                final command = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 5 * scale),
                  child: Row(
                    children: [
                      Container(
                        width: 40 * scale,
                        height: 40 * scale,
                        decoration: BoxDecoration(
                          color: index == 0 ? Colors.orange : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 25 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Text(
                          command,
                          style: TextStyle(
                            fontSize: 30 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
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

