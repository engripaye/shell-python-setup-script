param(
  [string]$Python = "python",
  [string]$VenvDir = "venv",
  [string]$RequirementsFile = "requirements.txt",
  [switch]$Recreate
)

function Log($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Err($m){ Write-Host "[ERR ] $m" -ForegroundColor Red }

Log "Checking Python..."
try {
  & $Python -V 2>$null
} catch {
  Err "Python not found. Install Python 3.8+ and ensure it's on PATH."
  exit 2
}

if ($Recreate -and (Test-Path $VenvDir)) {
  Log "Removing existing venv..."
  Remove-Item -Recurse -Force $VenvDir
}

if (-not (Test-Path $VenvDir)) {
  Log "Creating virtual environment..."
  & $Python -m venv $VenvDir
  Ok "Virtual env created at $VenvDir"
} else {
  Log "Virtual env already exists at $VenvDir"
}

$activate = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $activate) {
  Log "Activating venv..."
  & $activate
} else {
  Err "Activation script not found. Activate manually: $VenvDir\Scripts\Activate.ps1"
}

Log "Upgrading pip..."
& $Python -m pip install --upgrade pip setuptools wheel

if (Test-Path $RequirementsFile) {
  Log "Installing requirements from $RequirementsFile..."
  & $Python -m pip install -r $RequirementsFile
}

$lockFile = "requirements.lock.txt"
Log "Generating lock file $lockFile..."
& $Python -m pip freeze --all | Out-File -Encoding utf8 $lockFile

if (Get-Command pytest -ErrorAction SilentlyContinue) {
  Log "Running pytest..."
  pytest -q
  Ok "Tests completed."
} else {
  Log "pytest not installed. Install to run tests."
}

Ok "Setup complete. Activate with: .\\$VenvDir\\Scripts\\Activate.ps1"
