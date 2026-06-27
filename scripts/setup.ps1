# Setup SePay Payment Lab (Windows)
$ErrorActionPreference = "Stop"

Write-Host "=== SePay Payment Lab Setup ===" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter chua cai dat. Cai Flutter truoc: https://docs.flutter.dev/get-started" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path ".env") -and (Test-Path ".env.example")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Da tao .env tu .env.example" -ForegroundColor Green
    Write-Host "De test SePay API that: sua .env va them '.env' vao pubspec.yaml assets" -ForegroundColor Yellow
} else {
    Write-Host ".env da ton tai hoac thieu .env.example — bo qua copy" -ForegroundColor Gray
}

flutter pub get

Write-Host ""
Write-Host "Xong! Chay app:" -ForegroundColor Green
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Demo mode (mac dinh): bam 'Xac nhan da chuyen khoan (Demo)' tren app" -ForegroundColor Cyan
