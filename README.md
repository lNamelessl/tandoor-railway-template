# Tandoor Recipes — Railway Template

One-click [Tandoor Recipes](https://github.com/TandoorRecipes/recipes) (v2.7.2) deployment for Railway: the open-source recipe manager with URL import from thousands of cooking sites, recipe scaling, meal planning, and shopping lists.

**Deploy:** [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/tandoor-recipe-manager)

## What you get

| Service | Image | Persistence |
|---|---|---|
| **Tandoor** (this wrapper) | `vabene1111/recipes` pinned to the v2.7.2 manifest digest `sha256:1b6d43c3c0f5d2888aa564d9daf29883212b79ad496f59f3c684c099eb1a57b9` | volume on `/opt/recipes/mediafiles` (recipe images, exports) |
| **Postgres** | `postgres:16-alpine` pinned to `sha256:aa6cb33cf4c19c765cefcf48d96176258800870a9a1e930ad126200f9d825139` | volume on `/var/lib/postgresql` |

The official image bundles nginx + gunicorn (whitenoise serves static files); migrations and `collectstatic` run on every boot. Redis is not required by Tandoor v2 and is not deployed.

## First run

1. Open your Railway domain. With zero users, Tandoor redirects to its **native `/setup/` wizard**.
2. Create your admin account there — it also creates your first space. This wizard only exists while the database has no users, so nobody else can claim it.
3. Log in, then try **URL import**: paste any recipe site URL on the search page.

Public registration is disabled by default (`ENABLE_SIGNUP=0`); invite other users from your space settings.

## Variables (none required at deploy time)

| Variable | Set to | Purpose |
|---|---|---|
| `SECRET_KEY` | `${{secret(50)}}` (pre-configured) | Django signing key — generated per deployment, **never rotate it** (invalidates sessions/signed values) |
| `POSTGRES_HOST` | `${{Postgres.RAILWAY_PRIVATE_DOMAIN}}` (pre-configured) | private-network DB host |
| `POSTGRES_PASSWORD` | `${{Postgres.POSTGRES_PASSWORD}}` (pre-configured) | DB password |
| `ALLOWED_HOSTS` | *optional* | derived from your Railway domain + the platform probe host at boot; set explicitly when adding **custom domains** (comma-separated hosts) |
| `CSRF_TRUSTED_ORIGINS` | *optional* | derived as `https://<railway-domain>` at boot; set explicitly for custom domains (scheme included, comma-separated) |
| `TZ` | *optional* (default `UTC`) | IANA timezone, e.g. `Europe/Berlin` |
| `GUNICORN_WORKERS` / `GUNICORN_THREADS` | *optional* (default `2`/`2`) | scale for bigger instances |
| `ENABLE_SIGNUP` | *optional* (default `0`) | allow public self-registration |
| `S3_ACCESS_KEY`, `S3_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME`, `S3_REGION_NAME`, `S3_ENDPOINT_URL` | *optional* | store media in object storage instead of the volume |
| `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD` | *optional* | SMTP for password reset / share notifications |

The wrapper derives Railway-specific defaults at boot and then runs upstream's untouched `boot.sh` (Postgres wait, migrations, collectstatic, gunicorn).

## Upgrades and backups

Tandoor does not support database downgrades. Before upgrading, back up the Postgres volume **and** the mediafiles volume together (e.g. `railway ssh` + `pg_dump`, plus the volume files). To pin a different version, fork and edit the `FROM` digest in the `Dockerfile`.

## Repo layout

- `Dockerfile` — digest-pinned official image + Railway defaults (no upstream files modified)
- `railway-entrypoint.sh` — derives `TANDOOR_PORT` (from Railway's injected `PORT`), `ALLOWED_HOSTS`/`CSRF_TRUSTED_ORIGINS` (from `RAILWAY_PUBLIC_DOMAIN` + `healthcheck.railway.app`), then execs upstream `boot.sh`
- `railway.json` — Dockerfile builder + restart policy (no platform healthcheck: every Tandoor route that answers 200 to anonymous visitors pre-wizard redirects to `/setup/` until the first user exists, and Railway rejects dotted paths — the deploy goes active on container start instead; the entrypoint's `ALLOWED_HOSTS` handling still covers the `healthcheck.railway.app` probe host for anyone who re-enables a healthcheck)

License: AGPL-3.0 (Tandoor Recipes). This template is community-made and unaffiliated with the Tandoor project.
