# setup.sh  (Bash — Linux/macOS)
Save as `setup.sh` and `chmod +x setup.sh`.
```bash
#!/usr/bin/env bash
set -euo pipefail

# Config
PYTHON=${PYTHON:-python3}
VENV_DIR=${VENV_DIR:-venv}
REQUIREMENTS_FILE=${REQUIREMENTS_FILE:-requirements.txt}
LOCK_FILE=${LOCK_FILE:-requirements.lock.txt}
RECREATE=${RECREATE:-false}

log() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }
ok()  { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }

# Helpers
which_python() {
  if command -v "$PYTHON" >/dev/null 2>&1; then
    command -v "$PYTHON"
  else
    command -v python >/dev/null 2>&1 && echo "python" || return 1
  fi
}

main() {
  log "Using python command: ${PYTHON}"
  if ! which_python >/dev/null 2>&1; then
    err "Python not found. Install Python 3.8+ and retry."
    exit 2
  fi

  if [[ "${RECREATE}" == "true" && -d "${VENV_DIR}" ]]; then
    log "Recreate requested. Removing existing ${VENV_DIR}"
    rm -rf "${VENV_DIR}"
  fi

  if [[ ! -d "${VENV_DIR}" ]]; then
    log "Creating virtual environment in ${VENV_DIR}..."
    "$PYTHON" -m venv "${VENV_DIR}"
    ok "Virtual environment created."
  else
    log "Virtual environment already exists at ${VENV_DIR}"
  fi

  # shellcheck disable=SC1091
  source "${VENV_DIR}/bin/activate"

  log "Upgrading pip, wheel, setuptools..."
  python -m pip install --upgrade pip setuptools wheel

  if [[ -f "${REQUIREMENTS_FILE}" ]]; then
    log "Installing dependencies from ${REQUIREMENTS_FILE}..."
    pip install -r "${REQUIREMENTS_FILE}"
  else
    log "No ${REQUIREMENTS_FILE} found — skipping pip install."
  fi

  # create a deterministic lock (freeze)
  log "Generating ${LOCK_FILE}..."
  pip freeze --all > "${LOCK_FILE}"
  ok "Lockfile written to ${LOCK_FILE}."

  # Run tests
  if command -v pytest >/dev/null 2>&1; then
    log "Running pytest..."
    pytest -q
    ok "Tests passed."
  else
    log "pytest not available. Install pytest to run tests."
  fi

  ok "Setup complete. Activate environment with: source ${VENV_DIR}/bin/activate"
}

# Run main
main "$@"