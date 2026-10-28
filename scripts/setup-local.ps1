# Prepara archivos locales minimos (no sustituye FlutterFire ni google-services.json).
param(
  [switch]$RunFlutterfire
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$devJson = Join-Path $root "env\dev.json"
$exampleJson = Join-Path $root "env\example.json"
if (-not (Test-Path $devJson)) {
  Copy-Item $exampleJson $devJson
  Write-Host "Creado env/dev.json desde example.json"
} else {
  Write-Host "env/dev.json ya existe"
}

$options = Join-Path $root "lib\firebase_options.dart"
$exampleOptions = Join-Path $root "lib\firebase_options.example.dart"
if (-not (Test-Path $options)) {
  Copy-Item $exampleOptions $options
  Write-Host "Creado lib/firebase_options.dart desde plantilla."
} else {
  Write-Host "lib/firebase_options.dart ya existe"
}

if (Test-Path $devJson) {
  $raw = Get-Content $devJson -Raw
  if ($raw -match '"USE_FIREBASE"\s*:\s*false') {
    $raw = $raw -replace '"USE_FIREBASE"\s*:\s*false', '"USE_FIREBASE": true'
    Set-Content -Path $devJson -Value $raw -NoNewline -Encoding utf8
    Write-Host "Actualizado env/dev.json: USE_FIREBASE=true"
  }
}

function Invoke-FlutterfireConfigure {
  $flutterfire = Get-Command flutterfire -ErrorAction SilentlyContinue
  Push-Location $root
  try {
    if ($flutterfire) {
      & flutterfire configure --project=utebus-4435b --yes
    } elseif (Get-Command dart -ErrorAction SilentlyContinue) {
      dart pub global run flutterfire_cli:flutterfire configure --project=utebus-4435b --yes
    } else {
      Write-Host "AVISO: instala Dart/Flutter y ejecuta: dart pub global activate flutterfire_cli" -ForegroundColor Yellow
      return
    }
    if ($LASTEXITCODE -ne 0) {
      Write-Host "flutterfire configure fallo. Prueba: firebase login" -ForegroundColor Yellow
    }
  } finally {
    Pop-Location
  }
}

Write-Host ""
Write-Host "Listo. Pasos manuales si faltan:" -ForegroundColor Cyan
Write-Host "  dart pub global activate flutterfire_cli"
Write-Host "  PATH += %LOCALAPPDATA%\Pub\Cache\bin"
Write-Host "  .\scripts\setup-local.ps1 -RunFlutterfire"
Write-Host "  flutter run --dart-define-from-file=env/dev.json"
Write-Host "  docs/estado.md"
Write-Host ""

if ($RunFlutterfire) {
  Invoke-FlutterfireConfigure
}
