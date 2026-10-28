# Carga documentos demo en Firestore (proyecto utebus-4435b).
# Requisito: `firebase login` en esta máquina o env/firebase-admin-sa.json

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $root "firebase\tools")

if (-not (Test-Path "node_modules")) {
  npm install
}

node seed-demo-data.mjs
