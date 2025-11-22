import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';

// 타겟 해상도 상수 정의 (가로 모드: 2944 x 1840)
const double targetWidth = 2944.0;
const double targetHeight = 1840.0;

void main() {
  runApp(const K1App());
}

class K1App extends StatelessWidget {
  const K1App({super.key});

  @override
  Widget build(BuildContext context) {
    // 가로 모드로 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: '튀김조리시스템 K1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    // TODO: 제어 설정 페이지
    Container(
      color: Colors.white,
      child: const Center(child: Text('제어 설정')),
    ),
    // TODO: 로그 데이터 페이지
    Container(
      color: Colors.white,
      child: const Center(child: Text('로그 데이터')),
    ),
    // TODO: 주문 페이지
    Container(
      color: Colors.white,
      child: const Center(child: Text('주문')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // 가로 모드 강제: 세로가 더 길면 가로/세로를 교체
    final isPortrait = screenHeight > screenWidth;
    final effectiveWidth = isPortrait ? screenHeight : screenWidth;
    final effectiveHeight = isPortrait ? screenWidth : screenHeight;

    // 타겟 해상도 비율에 맞춰 스케일 계산
    final widthScale = effectiveWidth / targetWidth;
    final heightScale = effectiveHeight / targetHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(
          effectiveWidth > targetWidth ? targetWidth : effectiveWidth,
          effectiveHeight > targetHeight ? targetHeight : effectiveHeight,
        ),
      ),
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(scale),
      ),
    );
  }

  Widget _buildBottomNavigationBar(double scale) {
    return Container(
      height: 92 * scale,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton('홈', 0, scale),
          _buildNavButton('제어 설정', 1, scale),
          _buildNavButton('로그 데이터', 2, scale),
          _buildNavButton('예비 1', 3, scale),
          _buildNavButton('예비 2', 4, scale),
          _buildNavButton('예비 3', 5, scale),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, int index, double scale) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        child: Container(
          height: 75 * scale,
          margin: EdgeInsets.symmetric(horizontal: 7.5 * scale),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF888888)
                : const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 35 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
