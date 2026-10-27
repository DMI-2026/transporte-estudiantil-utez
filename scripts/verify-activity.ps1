# Verificación por actividad — Transporte Estudiantil UTEZ
# Uso: .\scripts\verify-activity.ps1 -Tipo base|feature|firebase|rules|full [-Feature nombre]

param(
    [ValidateSet('base', 'feature', 'firebase', 'rules', 'full')]
    [string]$Tipo = 'base',
    [string]$Feature = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "FALLO: $msg" -ForegroundColor Red; exit 1 }
function Ok($msg) { Write-Host "OK: $msg" -ForegroundColor Green }

Write-Host "verify-activity.ps1 | Tipo=$Tipo | Feature=$Feature | cwd=$root"

# --- Secretos obvios en archivos staged/working (heurística) ---
Write-Step "Comprobando patrones de secretos en diff"
$diff = git diff --name-only 2>$null
$diff += git diff --cached --name-only 2>$null
$diff = $diff | Select-Object -Unique
$badPatterns = @('api_key', 'API_KEY', 'private_key', 'BEGIN PRIVATE', 'mercadopago', 'sk_live', 'sk_test', 'client_secret\s*[:=]\s*[''"][^''"]+[''"]', 'refresh_token\s*[:=]\s*[''"][^''"]+[''"]')
$scanExt = @('.dart', '.json', '.yaml', '.yml', '.properties', '.plist', '.env', '.kt', '.swift', '.js', '.mjs', '.cjs', '.ts', '.ps1', '.sh')
foreach ($f in $diff) {
    if (-not $f) { continue }
    if ($f -match 'google-services\.json|firebase_options\.dart|env/dev\.json|env/prod\.json') {
        Fail "Archivo sensible en diff: $f (no debe commitearse)"
    }
    if ($f -replace '\\','/' -match '^docs/') { continue }
    $ext = [System.IO.Path]::GetExtension($f)
    if ($scanExt -notcontains $ext) { continue }
    if ($f -match 'example\.json|env/example') { continue }
    if ($f -replace '\\','/' -match 'scripts/verify-activity\.ps1$') { continue }
    if (Test-Path $f) {
        $content = Get-Content $f -Raw -ErrorAction SilentlyContinue
        foreach ($p in $badPatterns) {
            if ($content -match $p) {
                Fail "Posible secreto '$p' en $f"
            }
        }
    }
}
Ok "Sin secretos obvios en diff"

# --- Flutter (sensor C-04) ---
Write-Step "scripts/check.ps1"
& (Join-Path $root "scripts\check.ps1")
if ($LASTEXITCODE -ne 0) { Fail "check.ps1" }
Ok "analyze + test"

if ($Tipo -eq 'feature' -or $Tipo -eq 'full') {
    if (-not $Feature) { Fail "Tipo feature/full requiere -Feature <nombre>" }
    $featPath = Join-Path $root "lib\src\features\$Feature"
    if (-not (Test-Path $featPath)) { Fail "No existe carpeta feature: $featPath" }
    Ok "Feature folder: $Feature"
}

if ($Tipo -eq 'firebase' -or $Tipo -eq 'full') {
    Write-Step "Firebase / Functions"
    $rules = Join-Path $root "firebase\firestore.rules"
    if (-not (Test-Path $rules)) {
        Write-Host "AVISO: falta firebase/firestore.rules (crear en tarea Alison)" -ForegroundColor Yellow
    } else {
        Ok "firestore.rules presente"
    }
    $fn = Join-Path $root "functions\package.json"
    if (Test-Path $fn) {
        Push-Location (Join-Path $root "functions")
        if (Test-Path "package.json") {
            npm run lint --if-present 2>$null
            npm test --if-present 2>$null
        }
        Pop-Location
        Ok "functions npm scripts (si existen)"
    } else {
        Write-Host "AVISO: functions/ aún no creado" -ForegroundColor Yellow
    }
}

if ($Tipo -eq 'rules' -or $Tipo -eq 'full') {
    Write-Step "Reglas Firestore/Storage"
    foreach ($r in @('firebase\firestore.rules', 'firebase\storage.rules')) {
        if (-not (Test-Path (Join-Path $root $r))) {
            Fail "Falta $r"
        }
    }
    Ok "Archivos de reglas presentes"
    $rulesTest = Join-Path $root "firebase\tests"
    if (-not (Test-Path (Join-Path $rulesTest "package.json"))) {
        Fail "Falta firebase/tests/package.json"
    }
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Host "AVISO: Java no encontrado; el emulador de Firebase no puede arrancar. Pruebas de reglas omitidas." -ForegroundColor Yellow
    } else {
        Push-Location $rulesTest
        try {
            if (-not (Test-Path "node_modules")) { npm install }
            npm run test:emulator
            if ($LASTEXITCODE -ne 0) { Fail "pruebas de reglas Firestore/Storage" }
        } finally {
            Pop-Location
        }
        Ok "pruebas de reglas Firestore/Storage (emulador)"
    }
}

if ($Tipo -eq 'full') {
    Write-Step "integration_test"
    $it = Join-Path $root "integration_test"
    if (-not (Test-Path $it)) {
        Fail "Falta integration_test/"
    }
    # flutter-tester: no requiere celular ni Windows desktop.
    flutter test integration_test -d flutter-tester
    if ($LASTEXITCODE -ne 0) { Fail "integration_test" }
    Ok "integration_test"
}

Write-Host "`n=== VERIFICACION COMPLETADA ($Tipo) ===" -ForegroundColor Green
exit 0
