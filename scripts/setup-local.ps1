# Prepara la app para correr en local.
# Sin -RunFlutterfire solo copia plantillas (la app compila y muestra el aviso de Firebase).
# Con -RunFlutterfire genera firebase_options.dart, google-services.json y GoogleService-Info.plist.
param(
  [switch]$RunFlutterfire
)

$ErrorActionPreference = "Stop"
$mobile = Join-Path (Split-Path -Parent $PSScriptRoot) "apps\mobile"
$devJson = Join-Path $mobile "env\dev.json"
$exampleJson = Join-Path $mobile "env\example.json"
$options = Join-Path $mobile "lib\firebase_options.dart"
$exampleOptions = Join-Path $mobile "lib\firebase_options.example.dart"
$googleServices = Join-Path $mobile "android\app\google-services.json"
$iosPlist = Join-Path $mobile "ios\Runner\GoogleService-Info.plist"
$flutterFireConfig = Join-Path $mobile "firebase.json"

function Set-UseFirebaseFlag {
  param([bool]$Enabled)
  if (-not (Test-Path $devJson)) { return }
  $raw = Get-Content $devJson -Raw
  $value = if ($Enabled) { "true" } else { "false" }
  $updated = [regex]::Replace(
    $raw,
    '"USE_FIREBASE"\s*:\s*(true|false)',
    ('"USE_FIREBASE": {0}' -f $value)
  )
  if ($updated -ne $raw) {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($devJson, ($updated.TrimEnd() + [Environment]::NewLine), $utf8)
    Write-Host "apps/mobile/env/dev.json: USE_FIREBASE=$value"
  }
}

function Test-FirebaseOptionsReady {
  if (-not (Test-Path $options)) { return $false }
  return -not (Select-String -Path $options -Pattern "REEMPLAZAR" -Quiet)
}

if (-not (Test-Path $devJson)) {
  Copy-Item $exampleJson $devJson
  Write-Host "Creado apps/mobile/env/dev.json desde example.json"
}

if (-not (Test-Path $options)) {
  Copy-Item $exampleOptions $options
  Write-Host "Creado apps/mobile/lib/firebase_options.dart desde plantilla."
}

function Get-FlutterFireAppId {
  param([string]$PlatformName)
  if (-not (Test-Path $flutterFireConfig)) { return $null }
  $cfg = Get-Content $flutterFireConfig -Raw | ConvertFrom-Json
  if ($PlatformName -eq "android") {
    return $cfg.flutter.platforms.android.default.appId
  }
  $dart = $cfg.flutter.platforms.dart
  $entry = $dart.PSObject.Properties["lib/firebase_options.dart"]
  if (-not $entry) { return $null }
  return $entry.Value.configurations.ios
}

function Invoke-SdkConfig {
  param(
    [string]$PlatformName,
    [string]$AppId,
    [string]$OutFile
  )
  if ((Test-Path $OutFile) -or [string]::IsNullOrWhiteSpace($AppId)) { return }
  $outDir = Split-Path -Parent $OutFile
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
  & firebase apps:sdkconfig $PlatformName $AppId --project=utebus-4435b -o $OutFile
  if (-not (Test-Path $OutFile)) {
    Write-Host "No se pudo escribir $OutFile" -ForegroundColor Yellow
    exit 1
  }
}

function Invoke-FlutterfireConfigure {
  $firebase = Get-Command firebase -ErrorAction SilentlyContinue
  if (-not $firebase) {
    Write-Host "Falta Firebase CLI. Instala con: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
  }

  $login = & firebase login:list 2>&1 | Out-String
  if ($login -notmatch "Logged in as") {
    Write-Host "No hay sesion de Firebase. Ejecuta: firebase login" -ForegroundColor Yellow
    exit 1
  }

  dart pub global activate flutterfire_cli | Out-Host
  if ($LASTEXITCODE -ne 0) {
    Write-Host "No se pudo activar flutterfire_cli." -ForegroundColor Yellow
    exit $LASTEXITCODE
  }

  Push-Location $mobile
  try {
    dart pub global run flutterfire_cli:flutterfire configure `
      --project=utebus-4435b `
      --yes `
      --platforms=android,ios,web `
      --android-package-name=mx.edu.utez.transporte_estudiantil `
      --ios-bundle-id=mx.edu.utez.transporteEstudiantil `
      --android-out=android/app/google-services.json `
      --ios-out=ios/Runner/GoogleService-Info.plist `
      --overwrite-firebase-options
    if ($LASTEXITCODE -ne 0) {
      Write-Host "flutterfire configure fallo. Revisa firebase login y el acceso al proyecto utebus-4435b." -ForegroundColor Yellow
      exit $LASTEXITCODE
    }
  } finally {
    Pop-Location
  }

  Invoke-SdkConfig -PlatformName "ANDROID" -AppId (Get-FlutterFireAppId "android") -OutFile $googleServices
  Invoke-SdkConfig -PlatformName "IOS" -AppId (Get-FlutterFireAppId "ios") -OutFile $iosPlist
}

if ($RunFlutterfire) {
  Invoke-FlutterfireConfigure
}

$ready = (Test-Path $googleServices) -and (Test-Path $iosPlist) -and (Test-FirebaseOptionsReady)
Set-UseFirebaseFlag -Enabled $ready

if ($ready) {
  Write-Host ""
  Write-Host "Firebase local listo (utebus-4435b)." -ForegroundColor Green
  Write-Host "  cd apps/mobile"
  Write-Host "  flutter devices"
  Write-Host "  flutter run --dart-define-from-file=env/dev.json"
  Write-Host "  flutter run -d chrome --dart-define-from-file=env/dev.json"
} else {
  Write-Host ""
  Write-Host "Firebase aun no esta generado. La app compila y muestra el aviso de login." -ForegroundColor Yellow
  Write-Host "  firebase login"
  Write-Host "  .\scripts\setup-local.ps1 -RunFlutterfire"
}
