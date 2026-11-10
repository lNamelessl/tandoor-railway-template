#!/bin/sh
# Railway entrypoint wrapper for Tandoor Recipes.
# Derives Railway-specific defaults, then execs upstream boot.sh unchanged.
set -e

# Railway runtime-injects PORT (default 8080). Make the bundled nginx listen
# on the same port so the platform healthcheck probe (localhost:$PORT) and the
# public domain targetPort all line up. Locally (no PORT) fall back to 80.
: "${TANDOOR_PORT:=${PORT:-80}}"
export TANDOOR_PORT

export TZ="${TZ:-UTC}"

# Django rejects requests whose Host header is not in ALLOWED_HOSTS (empty
# default => only localhost is allowed). Railway's HTTP healthcheck probes
# localhost:$PORT with "Host: healthcheck.railway.app" (Tandoor upstream
# issue #3478), so the probe host must be allow-listed too. The public
# Railway domain covers real traffic. Any explicit value wins via ${VAR:-}.
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export ALLOWED_HOSTS="${ALLOWED_HOSTS:-$RAILWAY_PUBLIC_DOMAIN,healthcheck.railway.app,localhost,127.0.0.1}"
  export CSRF_TRUSTED_ORIGINS="${CSRF_TRUSTED_ORIGINS:-https://$RAILWAY_PUBLIC_DOMAIN}"
fi

# Hand off to upstream boot.sh: waits for Postgres, runs migrations,
# collectstatic, then starts gunicorn behind the bundled nginx.
exec /opt/recipes/boot.sh
