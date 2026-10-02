$ErrorActionPreference = "Stop"

$DriftVersion = "2.35.1"
$BaseUrl = "https://github.com/simolus3/drift/releases/download/drift-$DriftVersion"
$WebDir = Join-Path $PSScriptRoot "..\web"

New-Item -ItemType Directory -Force -Path $WebDir | Out-Null

Invoke-WebRequest -Uri "$BaseUrl/sqlite3.wasm" -OutFile (Join-Path $WebDir "sqlite3.wasm")
Invoke-WebRequest -Uri "$BaseUrl/drift_worker.js" -OutFile (Join-Path $WebDir "drift_worker.js")

Write-Host "Drift web assets are ready in $WebDir"
Write-Host "Run: flutter pub get"
Write-Host "Then: flutter test"
Write-Host "Then: flutter run -d chrome"