#!/bin/sh
set -eu

is_true() {
  case "${1:-}" in
    1|true|TRUE|True|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

if is_true "${OPENCLAW_USE_TAILSCALE:-false}"; then
  if command -v tailscaled >/dev/null 2>&1; then
    echo "[entrypoint] OPENCLAW_USE_TAILSCALE=true: starting tailscaled (userspace networking)" 1>&2
    OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
    TS_STATE_DIR="${OPENCLAW_STATE_DIR%/}/tailscale"
    mkdir -p "${TS_STATE_DIR}" || true
    tailscaled --tun=userspace-networking --state="${TS_STATE_DIR}/tailscaled.state" 1>&2 &
  else
    echo "[entrypoint] OPENCLAW_USE_TAILSCALE=true but tailscaled is not installed (image built without it); continuing" 1>&2
  fi
fi

exec "$@"

