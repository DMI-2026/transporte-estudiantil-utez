# Suite mínima local (enunciado DMI) — extender cuando haya más tests
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

Write-Host "test.ps1: analyze + unit/widget + reglas (si existen)"
flutter analyze
if ($LASTEXITCODE -ne 0) { exit 1 }

flutter test
if ($LASTEXITCODE -ne 0) { exit 1 }

if (Test-Path "integration_test") {
    flutter test integration_test
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

$rulesTest = Join-Path $root "firebase\tests"
if (Test-Path $rulesTest) {
    Push-Location $rulesTest
    npm test 2>$null
    Pop-Location
}

Write-Host "test.ps1: OK"
exit 0
