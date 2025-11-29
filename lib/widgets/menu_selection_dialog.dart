import 'package:flutter/material.dart';
import '../config/menu_config.dart';
import '../services/config_service.dart';

class MenuSelectionDialog extends StatefulWidget {
  final double scale;
  final Function(MenuConfig) onMenuSelected;

  const MenuSelectionDialog({
    super.key,
    required this.scale,
    required this.onMenuSelected,
  });

  @override
  State<MenuSelectionDialog> createState() => _MenuSelectionDialogState();
}

class _MenuSelectionDialogState extends State<MenuSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuConfig>>(
      future: MenuConfigRepository.getMenus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(30 * widget.scale),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(30 * widget.scale),
              child: Text(
                '메뉴를 불러올 수 없습니다.',
                style: TextStyle(fontSize: 30 * widget.scale),
              ),
            ),
          );
        }

        final menus = snapshot.data!;
        final globalShakeTimePercent = ConfigService.getGlobalShakeTimePercent();

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * widget.scale),
          ),
          child: Container(
            width: 900 * widget.scale,
            padding: EdgeInsets.all(30 * widget.scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  '메뉴 선택',
                  style: TextStyle(
                    fontSize: 50 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20 * widget.scale),
                // 메뉴 리스트
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      final calculatedShakeTime = (menu.cookTime * globalShakeTimePercent / 100).round();
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 15 * widget.scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(15 * widget.scale),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onMenuSelected(menu);
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(15 * widget.scale),
                            child: Padding(
                              padding: EdgeInsets.all(20 * widget.scale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.name,
                                    style: TextStyle(
                                      fontSize: 40 * widget.scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10 * widget.scale),
                                  Row(
                                    children: [
                                      _buildTimeInfo(
                                        '초벌',
                                        menu.preFryTime,
                                        widget.scale,
                                      ),
                                      SizedBox(width: 20 * widget.scale),
                                      _buildTimeInfo(
                                        '조리(전체)',
                                        menu.cookTime,
                                        widget.scale,
                                      ),
                                      SizedBox(width: 20 * widget.scale),
                                      _buildTimeInfo(
                                        '흔들기',
                                        calculatedShakeTime,
                                        widget.scale,
                                      ),
                                      SizedBox(width: 20 * widget.scale),
                                      _buildTimeInfo(
                                        '성형',
                                        menu.shapeTime,
                                        widget.scale,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5 * widget.scale),
                                  Text(
                                    '초벌 후 추가 조리: ${menu.additionalCookTime}초',
                                    style: TextStyle(
                                      fontSize: 20 * widget.scale,
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
                SizedBox(height: 20 * widget.scale),
                // 취소 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30 * widget.scale,
                          vertical: 15 * widget.scale,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(10 * widget.scale),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 35 * widget.scale,
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
      },
    );
  }

  Widget _buildTimeInfo(String label, int seconds, double scale) {
    return Text(
      '$label: $seconds초',
      style: TextStyle(fontSize: 25 * scale, color: Colors.black87),
    );
  }
}
