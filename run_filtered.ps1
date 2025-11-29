# Flutter 실행 + 로그 필터링 (한 번에 실행)
# 사용법: .\run_filtered.ps1

Write-Host "🚀 Flutter 앱 실행 중... (MESA 로그 필터링됨)" -ForegroundColor Green
Write-Host ""

flutter run 2>&1 | Where-Object { 
    # 시스템 로그 제외
    $_ -notmatch "MESA" -and
    $_ -notmatch "exportSyncFdForQSRILocked" -and
    $_ -notmatch "^I/MESA" -and
    # Flutter 앱 로그만 포함
    ($_ -match "I/flutter" -or 
     $_ -match "Config loaded" -or
     $_ -match "Connected to server" -or
     $_ -match "Failed to connect" -or
     $_ -match "명령어 전송" -or
     $_ -match "Message sent" -or
     $_ -match "Server message" -or
     $_ -match "═══════" -or
     $_ -match "📤" -or
     $_ -match "✅" -or
     $_ -match "❌" -or
     $_ -match "⚠️" -or
     $_ -match "포트:" -or
     $_ -match "호스트:" -or
     $_ -match "명령어:")
} | ForEach-Object { Write-Host $_ }

