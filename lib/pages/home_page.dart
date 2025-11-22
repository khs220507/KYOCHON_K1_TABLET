import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/status_panel.dart';
import '../widgets/slot_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 타겟 해상도 상수
  static const double targetWidth = 2944.0;
  static const double targetHeight = 1840.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // 타겟 해상도 비율에 맞춰 스케일 계산
    final widthScale = screenWidth / targetWidth;
    final heightScale = screenHeight / targetHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 검은색 헤더
          HeaderWidget(scale: scale),
          
          // 상단 현황판
          StatusPanel(scale: scale),
          
          // 메인 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // 슬롯 그리드
                  SlotGrid(scale: scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

