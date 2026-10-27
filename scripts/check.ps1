# Sensor unico (C-04). Equivalente Windows de cafeteria scripts/check.sh
# Uso: .\scripts\check.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "==> flutter analyze" -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) {
  Write-Host "FALLO: flutter analyze" -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host "==> flutter test" -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) {
  Write-Host "FALLO: flutter test" -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host "=== check.ps1 OK ===" -ForegroundColor Green
exit 0
