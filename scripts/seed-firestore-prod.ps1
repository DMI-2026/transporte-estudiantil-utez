# Seed demo en Firestore producción (utebus-4435b).
#
# Modo seguro (por defecto): usa credenciales de administrador (service account en
# env/firebase-admin-sa.json o GOOGLE_APPLICATION_CREDENTIALS). Las reglas no se tocan.
#
# Modo -AbrirReglas: SOLO si no hay service account. Abre Firestore a todo el mundo
# mientras corre el seed y restaura las reglas al final. Evitar en producción con datos reales.
param(
  [switch]$AbrirReglas
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$saPath = Join-Path $root "env\firebase-admin-sa.json"
$tieneAdmin = (Test-Path $saPath) -or ($env:GOOGLE_APPLICATION_CREDENTIALS -and (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS))

function Invoke-Seed {
  Push-Location (Join-Path $root "firebase\tools")
  try {
    if (-not (Test-Path "node_modules")) {
      npm install
    }
    node seed-demo-data.mjs
    if ($LASTEXITCODE -ne 0) { throw "seed-demo-data.mjs terminó con código $LASTEXITCODE" }
  }
  finally {
    Pop-Location
  }
}

if ($tieneAdmin -and -not $AbrirReglas) {
  Write-Host "Usando credenciales de administrador; las reglas no se modifican." -ForegroundColor Green
  Invoke-Seed
  exit 0
}

if (-not $AbrirReglas) {
  Write-Host "No hay service account (env/firebase-admin-sa.json o GOOGLE_APPLICATION_CREDENTIALS)." -ForegroundColor Yellow
  Write-Host "Descarga una en Firebase Console > Configuración > Cuentas de servicio y vuelve a ejecutar," -ForegroundColor Yellow
  Write-Host "o ejecuta con -AbrirReglas para abrir temporalmente las reglas (no recomendado con datos reales)." -ForegroundColor Yellow
  exit 1
}

$rules = Join-Path $root "firebase\firestore.rules"
$openRules = Join-Path $root "firebase\firestore.rules.seed-open"
$backup = Join-Path $root "firebase\firestore.rules.backup"

if (-not (Test-Path $openRules)) {
  throw "Falta firebase/firestore.rules.seed-open"
}

Write-Host "ADVERTENCIA: las reglas de Firestore quedarán abiertas durante el seed." -ForegroundColor Red
Copy-Item $rules $backup -Force
try {
  Copy-Item $openRules $rules -Force
  firebase deploy --only firestore:rules --project utebus-4435b --non-interactive
  Invoke-Seed
}
finally {
  Copy-Item $backup $rules -Force
  Remove-Item $backup -Force -ErrorAction SilentlyContinue
  Set-Location $root
  firebase deploy --only firestore:rules --project utebus-4435b --non-interactive
  Write-Host "Reglas de producción restauradas."
}
