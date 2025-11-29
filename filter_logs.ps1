# Flutter 로그만 필터링하는 PowerShell 스크립트
# 사용법: .\filter_logs.ps1
# MESA 같은 시스템 로그는 숨기고 Flutter 앱 로그만 표시

flutter run 2>&1 | Where-Object { 
    # MESA 로그 제외
    $_ -notmatch "MESA" -and
    $_ -notmatch "exportSyncFdForQSRILocked" -and
    # Flutter 로그만 포함
    ($_ -match "I/flutter" -or 
     $_ -match "flutter" -or
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
     $_ -match "⚠️")
} | ForEach-Object { Write-Host $_ }

