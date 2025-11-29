# 로그 필터링 가이드

MESA 및 기타 시스템 로그를 숨기고 Flutter 앱 로그만 보는 방법입니다.

## 방법 1: VS Code에서 필터링

VS Code의 터미널에서 다음 명령어를 사용하세요:

```bash
flutter run 2>&1 | findstr /V "MESA"
```

또는 PowerShell에서:
```powershell
flutter run 2>&1 | Where-Object { $_ -notmatch "MESA" }
```

## 방법 2: Android Studio Logcat 필터

1. Android Studio의 Logcat 창 열기
2. 필터 드롭다운에서 "Edit Filter Configuration" 선택
3. 새 필터 생성:
   - **Filter Name**: Flutter Only
   - **Log Tag**: `flutter`
   - **Log Level**: Info 이상
4. 또는 정규식 필터 사용:
   - **Log Tag Regex**: `^(?!.*MESA).*`

## 방법 3: adb logcat 필터링 (명령줄)

터미널에서 직접 실행:

```bash
# Flutter 로그만 보기
adb logcat -s flutter:I

# MESA 제외하고 보기
adb logcat | grep -v MESA

# Flutter와 특정 태그만 보기
adb logcat -s flutter:I *:E
```

## 방법 4: Flutter 로그만 보기

VS Code나 Android Studio에서 실행 시:
- Logcat 필터에 `package:com.example.flutter_k1_app` 또는 `tag:flutter` 입력

## 방법 5: VS Code 설정 (권장)

`.vscode/settings.json` 파일에 추가:

```json
{
  "dart.flutterRunLogFile": null,
  "dart.flutterAdditionalArgs": []
}
```

그리고 터미널에서:
```bash
flutter run 2>&1 | Select-String -Pattern "flutter|I/flutter" -Context 0,0
```

## 가장 간단한 방법 (권장)

**VS Code 터미널에서:**
```powershell
flutter run 2>&1 | Where-Object { $_ -notmatch "MESA" -and $_ -match "I/flutter" }
```

또는 더 정확하게:
```powershell
flutter run 2>&1 | Where-Object { $_ -notmatch "MESA" -and $_ -notmatch "exportSyncFdForQSRILocked" -and $_ -match "flutter" }
```

**필터링 스크립트 사용:**
```powershell
.\filter_logs.ps1
```

이렇게 하면 MESA 같은 시스템 로그는 숨기고 Flutter 앱 로그(명령어 전송 로그 포함)만 표시됩니다.

