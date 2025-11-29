import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/config_service.dart';

class SettingsPage extends StatefulWidget {
  final double scale;

  const SettingsPage({
    super.key,
    required this.scale,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _shakeTimePercent = 0.83;
  double _overcookTimePercent = 10.0;
  String _operatingMode = 'recipe'; // 'production' 또는 'recipe'
  bool _isLoading = true;
  bool _hasChanges = false;
  
  // 초기값 상수
  static const double _defaultShakeTimePercent = 0.83;
  static const double _defaultOvercookTimePercent = 10.0;
  static const String _defaultOperatingMode = 'recipe';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 메뉴 설정을 먼저 로드하여 전역 설정 초기화
      await ConfigService.loadMenuConfig();
      
      // 현재 설정값 로드
      _shakeTimePercent = ConfigService.getGlobalShakeTimePercent();
      _overcookTimePercent = ConfigService.getGlobalOvercookTimePercent();
      _operatingMode = ConfigService.getOperatingMode();
    } catch (e) {
      print('설정 로드 실패: $e');
      // 로드 실패 시 기본값 사용
      _shakeTimePercent = _defaultShakeTimePercent;
      _overcookTimePercent = _defaultOvercookTimePercent;
      _operatingMode = _defaultOperatingMode;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetToDefaults() {
    setState(() {
      _shakeTimePercent = _defaultShakeTimePercent;
      _overcookTimePercent = _defaultOvercookTimePercent;
      _operatingMode = _defaultOperatingMode;
      _hasChanges = true;
      ConfigService.setGlobalShakeTimePercent(_defaultShakeTimePercent);
      ConfigService.setGlobalOvercookTimePercent(_defaultOvercookTimePercent);
      ConfigService.setOperatingMode(_defaultOperatingMode);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '초기값으로 리셋되었습니다.',
            style: TextStyle(fontSize: 30 * widget.scale),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      // ConfigService에 설정 저장
      ConfigService.setGlobalShakeTimePercent(_shakeTimePercent);
      ConfigService.setGlobalOvercookTimePercent(_overcookTimePercent);
      ConfigService.setOperatingMode(_operatingMode);
      
      // JSON 파일 업데이트
      final String jsonString = await rootBundle.loadString('assets/config/menu_config.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      if (!json.containsKey('globalSettings')) {
        json['globalSettings'] = {};
      }
      
      json['globalSettings']['shakeTimePercent'] = _shakeTimePercent;
      json['globalSettings']['overcookTimePercent'] = _overcookTimePercent;
      json['globalSettings']['operatingMode'] = _operatingMode;
      
      // 파일 저장은 Flutter에서 직접 할 수 없으므로, ConfigService에 저장된 값 사용
      // 실제 파일 저장은 앱 재시작 시 또는 별도 저장 기능 필요
      
      setState(() {
        _hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '설정이 저장되었습니다.',
              style: TextStyle(fontSize: 30 * widget.scale),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('설정 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '설정 저장에 실패했습니다: $e',
              style: TextStyle(fontSize: 30 * widget.scale),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(40 * widget.scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              '제어 설정',
              style: TextStyle(
                fontSize: 60 * widget.scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40 * widget.scale),
            
            // 글로벌 설정 섹션
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 운영 모드 선택
                    _buildOperatingModeCard(),
                    
                    SizedBox(height: 30 * widget.scale),
                    
                    // 쉐이킹 시간 퍼센트 설정
                    _buildSettingCard(
                      title: '흔들기 시간 설정',
                      description: '총 조리시간의 퍼센트로 흔들기 시간을 설정합니다.\n모든 메뉴에 동일하게 적용됩니다.',
                      value: _shakeTimePercent,
                      min: 0.0,
                      max: 100.0,
                      unit: '%',
                      onChanged: (value) {
                        setState(() {
                          _shakeTimePercent = value;
                          _hasChanges = true;
                          ConfigService.setGlobalShakeTimePercent(value);
                        });
                      },
                    ),
                    
                    SizedBox(height: 30 * widget.scale),
                    
                    // 오버쿡 시간 퍼센트 설정
                    _buildSettingCard(
                      title: '오버쿡 시간 설정',
                      description: '총 조리시간의 퍼센트로 오버쿡 한계를 설정합니다.\n이 시간만큼 지나면 E_OUTPUT 명령어가 자동으로 추가됩니다.',
                      value: _overcookTimePercent,
                      min: 0.0,
                      max: 100.0,
                      unit: '%',
                      onChanged: (value) {
                        setState(() {
                          _overcookTimePercent = value;
                          _hasChanges = true;
                          ConfigService.setGlobalOvercookTimePercent(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // 버튼들
            Padding(
              padding: EdgeInsets.only(top: 20 * widget.scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 초기값 리셋 버튼
                  ElevatedButton(
                    onPressed: _resetToDefaults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E5E5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 50 * widget.scale,
                        vertical: 20 * widget.scale,
                      ),
                    ),
                    child: Text(
                      '초기값으로 리셋',
                      style: TextStyle(
                        fontSize: 35 * widget.scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // 저장 버튼
                  if (_hasChanges)
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        padding: EdgeInsets.symmetric(
                          horizontal: 50 * widget.scale,
                          vertical: 20 * widget.scale,
                        ),
                      ),
                      child: Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 40 * widget.scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(30 * widget.scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20 * widget.scale),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            title,
            style: TextStyle(
              fontSize: 45 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15 * widget.scale),
          
          // 설명
          Text(
            description,
            style: TextStyle(
              fontSize: 30 * widget.scale,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 25 * widget.scale),
          
          // 슬라이더와 값 표시
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) * 10).round(),
                  label: '${value.toStringAsFixed(1)}$unit',
                  onChanged: onChanged,
                ),
              ),
              SizedBox(width: 20 * widget.scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 25 * widget.scale,
                  vertical: 15 * widget.scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10 * widget.scale),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    fontSize: 40 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingModeCard() {
    return Container(
      padding: EdgeInsets.all(30 * widget.scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20 * widget.scale),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '운영 모드 선택',
            style: TextStyle(
              fontSize: 45 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15 * widget.scale),
          
          // 설명
          Text(
            '명령어 처리 우선순위를 설정합니다.',
            style: TextStyle(
              fontSize: 30 * widget.scale,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 25 * widget.scale),
          
          // 조리시간 준수 모드
          RadioListTile<String>(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '조리시간 준수',
                  style: TextStyle(
                    fontSize: 35 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5 * widget.scale),
                Text(
                  '우선순위: INPUT → OUTPUT → MOVE → SHAPING → CLEAN',
                  style: TextStyle(
                    fontSize: 25 * widget.scale,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '레시피에 맞는 정확한 조리 시간을 준수합니다.',
                  style: TextStyle(
                    fontSize: 25 * widget.scale,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            value: 'recipe',
            groupValue: _operatingMode,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _operatingMode = value;
                  _hasChanges = true;
                  ConfigService.setOperatingMode(value);
                });
              }
            },
            activeColor: Colors.blue,
          ),
          
          SizedBox(height: 15 * widget.scale),
          
          // 생산량 위주 모드
          RadioListTile<String>(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '생산량 위주',
                  style: TextStyle(
                    fontSize: 35 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5 * widget.scale),
                Text(
                  '우선순위: E_OUTPUT(최우선) → INPUT → MOVE → OUTPUT → SHAPING → CLEAN',
                  style: TextStyle(
                    fontSize: 25 * widget.scale,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '생산량을 최우선으로 하여 효율적인 처리를 합니다.',
                  style: TextStyle(
                    fontSize: 25 * widget.scale,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            value: 'production',
            groupValue: _operatingMode,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _operatingMode = value;
                  _hasChanges = true;
                  ConfigService.setOperatingMode(value);
                });
              }
            },
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

