import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

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
  List<Widget>? _cachedPages;
  double? _cachedScale;

  List<Widget> _buildPages(double scale) {
    // 스케일이 변경되지 않았고 페이지가 이미 생성되어 있으면 재사용
    if (_cachedPages != null && _cachedScale == scale) {
      return _cachedPages!;
    }

    _cachedScale = scale;
    _cachedPages = [
      const HomePage(),
      SettingsPage(scale: scale),
      // TODO: 로그 데이터 페이지
      Container(
        color: const Color(0xFFFFFFFF),
        child: const Center(child: Text('로그 데이터')),
      ),
      // TODO: 예비 1 페이지
      Container(
        color: const Color(0xFFFFFFFF),
        child: const Center(child: Text('예비 1')),
      ),
      // TODO: 예비 2 페이지
      Container(
        color: const Color(0xFFFFFFFF),
        child: const Center(child: Text('예비 2')),
      ),
      // TODO: 예비 3 페이지
      Container(
        color: const Color(0xFFFFFFFF),
        child: const Center(child: Text('예비 3')),
      ),
    ];

    return _cachedPages!;
  }

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

    final pages = _buildPages(scale);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(
          effectiveWidth > targetWidth ? targetWidth : effectiveWidth,
          effectiveHeight > targetHeight ? targetHeight : effectiveHeight,
        ),
      ),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: _buildBottomNavigationBar(scale),
      ),
    );
  }

  Widget _buildBottomNavigationBar(double scale) {
    return Container(
      height: 92 * scale,
      decoration: const BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1F000000),
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
          _buildActionButton('비상정지', scale, isEmergency: true),
          _buildActionButton('프로그램종료', scale, isExit: true),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, int index, double scale) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
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
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    double scale, {
    bool isEmergency = false,
    bool isExit = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isEmergency) {
            // TODO: 비상정지 동작 구현 필요
            debugPrint('비상정지');
          } else if (isExit) {
            // TODO: 프로그램 종료 동작 구현 필요
            debugPrint('프로그램 종료');
          }
        },
        child: Container(
          height: 75 * scale,
          margin: EdgeInsets.symmetric(horizontal: 7.5 * scale),
          decoration: BoxDecoration(
            color: isEmergency
                ? const Color(0xFFF44336)
                : isExit
                ? const Color(0xFFFF9800)
                : const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 35 * scale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
