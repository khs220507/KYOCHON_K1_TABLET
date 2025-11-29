import 'dart:async';
import 'package:flutter/material.dart';
import '../models/basket_state.dart';
import '../services/config_service.dart';

class SlotCard extends StatefulWidget {
  final int slotNumber;
  final double scale;
  final BasketState basketState;

  const SlotCard({
    super.key,
    required this.slotNumber,
    required this.scale,
    required this.basketState,
  });

  @override
  State<SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> {
  Timer? _blinkTimer;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    // 오버쿡 중이고 한계에 도달했으면 깜박거림 시작
    if (widget.basketState.isOvercooking &&
        widget.basketState.selectedMenu != null) {
      final totalCookTime = widget.basketState.selectedMenu!.cookTime;
      final overcookPercent = ConfigService.getGlobalOvercookTimePercent();
      final overcookLimit = (totalCookTime * overcookPercent / 100).round();
      if (widget.basketState.overcookTime >= overcookLimit) {
        _startBlinking();
      }
    }
  }

  @override
  void didUpdateWidget(SlotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 오버쿡 상태가 변경되면 깜박거림 업데이트
    if (widget.basketState.isOvercooking &&
        widget.basketState.selectedMenu != null) {
      final totalCookTime = widget.basketState.selectedMenu!.cookTime;
      final overcookPercent = ConfigService.getGlobalOvercookTimePercent();
      final overcookLimit = (totalCookTime * overcookPercent / 100).round();
      if (widget.basketState.overcookTime >= overcookLimit) {
        if (!_isBlinking) {
          _startBlinking();
        }
      } else {
        _stopBlinking();
      }
    } else {
      _stopBlinking();
    }
  }

  void _startBlinking() {
    if (_blinkTimer != null) return;
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
      }
    });
  }

  void _stopBlinking({bool updateState = true}) {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    if (updateState && mounted) {
      setState(() {
        _isBlinking = false;
      });
    } else {
      _isBlinking = false;
    }
  }

  @override
  void dispose() {
    // dispose 시에는 setState를 호출하지 않음
    _blinkTimer?.cancel();
    _blinkTimer = null;
    _isBlinking = false;
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _calculateCookProgress() {
    if (widget.basketState.selectedMenu == null ||
        widget.basketState.cookRemainingTime == 0) {
      return 0;
    }
    final totalCookTime = widget.basketState.selectedMenu!.cookTime;
    final remainingTime = widget.basketState.cookRemainingTime;
    final progress = ((totalCookTime - remainingTime) / totalCookTime * 100)
        .round();
    return progress.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    // 오버쿡 한계 도달 여부 확인
    final bool isOvercookLimitReached =
        widget.basketState.isOvercooking &&
        widget.basketState.selectedMenu != null;

    if (isOvercookLimitReached) {
      final totalCookTime = widget.basketState.selectedMenu!.cookTime;
      final overcookPercent = ConfigService.getGlobalOvercookTimePercent();
      final overcookLimit = (totalCookTime * overcookPercent / 100).round();
      final isOverLimit = widget.basketState.overcookTime >= overcookLimit;
      // 한계 도달 시에만 깜박임
      if (isOverLimit && !_isBlinking) {
        _startBlinking();
      } else if (!isOverLimit && _isBlinking) {
        _stopBlinking();
      }
    }

    // 카드 색상 결정: 사용불가 > 메뉴 있음 > 비어있음
    final Color cardColor;
    if (widget.basketState.isUnavailable) {
      // 사용불가 상태: 비활성화 색상 (회색)
      cardColor = Colors.grey.shade400;
    } else if (!widget.basketState.isEmpty) {
      // 메뉴가 들어가 있으면 교촌 노란색
      cardColor = const Color(0xFFFFD700);
    } else {
      // 비어있으면 흰색
      cardColor = Colors.white;
    }

    return Container(
      width: double.infinity,
      height: 500 * widget.scale,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20 * widget.scale),
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: EdgeInsets.all(15 * widget.scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // 슬롯 번호
          Text(
            '${widget.slotNumber + 1}번 바스켓',
            style: TextStyle(
              fontSize: 30 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // 메뉴 정보
          Text(
            widget.basketState.isUnavailable
                ? '사용불가\n(바스켓이 돌아오는 중)'
                : (widget.basketState.selectedMenu?.name ?? '비어있음'),
            textAlign: widget.basketState.isUnavailable
                ? TextAlign.center
                : TextAlign.left,
            style: TextStyle(
              fontSize: widget.basketState.isUnavailable
                  ? 30 * widget.scale
                  : 40 * widget.scale,
              fontWeight: FontWeight.bold,
              color: widget.basketState.isUnavailable
                  ? Colors.red
                  : (widget.basketState.isEmpty ? Colors.grey : Colors.black),
            ),
          ),
          // 이동중 상태 표시 (1번 바스켓)
          if (widget.basketState.isMoving)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '이동중',
                style: TextStyle(
                  fontSize: 35 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          // 곧 도착 예정 상태 표시 (목적지 바스켓) - 메뉴가 없을 때만 표시
          if (widget.basketState.isArrivingSoon && widget.basketState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '곧 도착 예정',
                style: TextStyle(
                  fontSize: 35 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          // 예약됨 상태 표시 (목적지 바스켓 - MOVE_START를 받았을 때)
          if (widget.basketState.isWaiting &&
              !widget.basketState.isArrivingSoon &&
              widget.basketState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '예약됨\n(이동 예정)',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
          // 대기중 상태 표시 (기타)
          if (widget.basketState.isWaiting &&
              !widget.basketState.isArrivingSoon &&
              !widget.basketState.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '대기중',
                style: TextStyle(
                  fontSize: 35 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          // 이동 예정 상태 표시 (MOVE_MOTION_START 전)
          if (widget.basketState.pendingMoveTo != null &&
              !widget.basketState.isMoving)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '${widget.basketState.pendingMoveTo}번 바스켓으로\n이동 예정',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          // 꺼내기중 상태 표시
          if (widget.basketState.isOutputting)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '꺼내기중',
                style: TextStyle(
                  fontSize: 35 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          // 정리중 상태 표시
          if (widget.basketState.isInitializing)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Text(
                '정리중',
                style: TextStyle(
                  fontSize: 35 * widget.scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          const Spacer(),
          // 조리 진행률 (퍼센트) - 오버쿡 중이 아닐 때만 표시
          if (widget.basketState.selectedMenu != null &&
              widget.basketState.isCooking &&
              !widget.basketState.isOvercooking)
            Text(
              '${_calculateCookProgress()}%',
              style: TextStyle(
                fontSize: 50 * widget.scale,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          // 오버쿡 표시 (기준 넘어가면 깜박)
          if (widget.basketState.isOvercooking)
            Padding(
              padding: EdgeInsets.only(top: 10 * widget.scale),
              child: Builder(
                builder: (context) {
                  final totalCookTime =
                      widget.basketState.selectedMenu!.cookTime;
                  final overcookPercent =
                      ConfigService.getGlobalOvercookTimePercent();
                  final overcookLimit = (totalCookTime * overcookPercent / 100)
                      .round();
                  final shouldBlink =
                      widget.basketState.overcookTime >= overcookLimit;

                  return AnimatedOpacity(
                    opacity: shouldBlink && _isBlinking ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      '오버쿡 +${_formatTime(widget.basketState.overcookTime)}',
                      style: TextStyle(
                        fontSize: 45 * widget.scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  );
                },
              ),
            ),
          // 타이머 정보 (이동중이거나 사용불가가 아닐 때만 표시, 오버쿡 중이 아닐 때)
          if (widget.basketState.selectedMenu != null &&
              !widget.basketState.isUnavailable &&
              !widget.basketState.isOvercooking)
            Text(
              '초벌 : ${_formatTime(widget.basketState.preFryRemainingTime)} / 조리 : ${_formatTime(widget.basketState.cookRemainingTime)}',
              style: TextStyle(
                fontSize: 35 * widget.scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
