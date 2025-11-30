import 'package:flutter/material.dart';

class MoveConfirmationDialog extends StatelessWidget {
  final double scale;
  final String menuName;
  final int targetBasketNumber;

  const MoveConfirmationDialog({
    super.key,
    required this.scale,
    required this.menuName,
    required this.targetBasketNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Container(
        width: 600 * scale,
        padding: EdgeInsets.all(40 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '초벌 완료',
              style: TextStyle(
                fontSize: 50 * scale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              '$menuName 초벌이 완료되었습니다.\n$targetBasketNumber번 바스켓으로 이동하시겠습니까?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40 * scale,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 30 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 취소 버튼
                Expanded(
                  child: Container(
                    height: 80 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: const Color(0xFF000000), width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(false),
                        borderRadius: BorderRadius.circular(15 * scale),
                        child: Center(
                          child: Text(
                            '취소',
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
                ),
                SizedBox(width: 20 * scale),
                // 확인 버튼
                Expanded(
                  child: Container(
                    height: 80 * scale,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: const Color(0xFF000000), width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(true),
                        borderRadius: BorderRadius.circular(15 * scale),
                        child: Center(
                          child: Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 35 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      ),
    );
  }
}

