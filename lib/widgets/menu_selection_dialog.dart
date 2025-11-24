import 'package:flutter/material.dart';
import '../config/menu_config.dart';

class MenuSelectionDialog extends StatelessWidget {
  final double scale;
  final Function(MenuConfig) onMenuSelected;

  const MenuSelectionDialog({
    super.key,
    required this.scale,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final menus = MenuConfigRepository.menus;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Container(
        width: 800 * scale,
        padding: EdgeInsets.all(30 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              '메뉴 선택',
              style: TextStyle(
                fontSize: 50 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20 * scale),
            // 메뉴 리스트
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final menu = menus[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 15 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onMenuSelected(menu);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(15 * scale),
                        child: Padding(
                          padding: EdgeInsets.all(20 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu.name,
                                style: TextStyle(
                                  fontSize: 40 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10 * scale),
                              Row(
                                children: [
                                  _buildTimeInfo('초벌', menu.preFryTime, scale),
                                  SizedBox(width: 20 * scale),
                                  _buildTimeInfo('조리(전체)', menu.cookTime, scale),
                                  SizedBox(width: 20 * scale),
                                  _buildTimeInfo('흔들기', menu.shakeTime, scale),
                                  SizedBox(width: 20 * scale),
                                  _buildTimeInfo('성형', menu.shapeTime, scale),
                                ],
                              ),
                              SizedBox(height: 5 * scale),
                              Text(
                                '초벌 후 추가 조리: ${menu.additionalCookTime}초',
                                style: TextStyle(
                                  fontSize: 20 * scale,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20 * scale),
            // 취소 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30 * scale,
                      vertical: 15 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 35 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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

  Widget _buildTimeInfo(String label, int seconds, double scale) {
    return Text(
      '$label: ${seconds}초',
      style: TextStyle(
        fontSize: 25 * scale,
        color: Colors.black87,
      ),
    );
  }
}

