# Railway wrapper for Tandoor Recipes.
# Base: official image, digest-pinned to v2.7.2 (manifest digest, 2026-10-27).
# The wrapper only derives Railway-specific defaults from the runtime environment
# and then hands off to upstream's own boot.sh. No upstream files are modified.
FROM vabene1111/recipes@sha256:1b6d43c3c0f5d2888aa564d9daf29883212b79ad496f59f3c684c099eb1a57b9

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# Literal defaults baked as image ENV so the published template needs zero
# deploy-form prompts. Every one of these can be overridden per deployment.
# DB points at the sibling "Postgres" service via cross-service references
# (POSTGRES_HOST / POSTGRES_PASSWORD are set as template variables).
ENV DB_ENGINE=django.db.backends.postgresql \
    POSTGRES_DB=postgres \
    POSTGRES_USER=postgres \
    POSTGRES_PORT=5432 \
    TZ=UTC \
    GUNICORN_WORKERS=2 \
    GUNICORN_THREADS=2

# Keep tini as PID 1 exactly like upstream; only the entrypoint changes.
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/railway-entrypoint.sh"]

# Healthcheck: /accounts/login/ (dotless, 200 anonymous). Probe host is allow-listed by the entrypoint.
