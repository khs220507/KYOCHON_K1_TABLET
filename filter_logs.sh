#!/bin/bash
# Flutter 로그만 필터링하는 스크립트 (Mac/Linux)
# 사용법: chmod +x filter_logs.sh && ./filter_logs.sh
# MESA 같은 시스템 로그는 숨기고 Flutter 앱 로그만 표시

flutter run 2>&1 | grep -v "MESA" | grep -v "exportSyncFdForQSRILocked" | grep -E "I/flutter|flutter|Config loaded|Connected to server|Failed to connect|명령어 전송|Message sent|Server message|═══════|📤|✅|❌|⚠️|포트:|호스트:|명령어:"

