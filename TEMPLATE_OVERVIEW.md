Deploy [Tandoor Recipes](https://github.com/TandoorRecipes/recipes) — the most popular self-hosted recipe manager (5,200+ GitHub stars, AGPL-3.0) — on Railway in one click. This template is pinned to the latest upstream release (v2.7.2) by image digest, requires **zero variables from you** (secrets and database wiring are generated per deployment), and boots straight into Tandoor's native setup wizard so you can create your admin account on the very first visit. Recipes, recipe imports from any recipe website, meal plans, shopping lists, and a food database — all self-hosted, all yours.

**What you get:**

- **recipes** service — upstream Tandoor v2.7.2, served by gunicorn (2 workers x 2 threads) behind the bundled nginx, with a persistent volume for uploaded recipe images at /opt/recipes/mediafiles. The wrapper entrypoint auto-wires your Railway domain into ALLOWED_HOSTS and CSRF_TRUSTED_ORIGINS, including the healthcheck.railway.app probe host (a known upstream gotcha, issue #3478), and forwards Railway's PORT to the bundled nginx.
- **Postgres** service — postgres 16 (alpine), digest-pinned, with a persistent volume for the database. Connection details are referenced automatically; nothing to type.

**First steps after deploying:** open your Railway domain, and Tandoor's /setup/ wizard asks for a space name and admin password — that creates your account. Then hit **New recipe → Import website** and paste the URL of any recipe online: Tandoor parses ingredients, steps, and images automatically. Registration is disabled by default; invite family or friends from your space settings.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/tandoor-recipe-manager)

# Deploy and Host

Click the deploy button and Railway provisions both services — the Tandoor application (with its media volume) and PostgreSQL (with its data volume) — wires the database connection and a per-deployment SECRET_KEY automatically, and assigns a public domain. There is nothing to fill in: the deploy form has zero prompts. When the deploy finishes, open the domain and complete the two-field setup wizard (space name + admin password). Migrations run automatically on every boot, so upgrades are just a redeploy — but see the backup note below before upgrading.

## About Hosting

Hosting Tandoor yourself means your recipes, photos, meal plans, and shopping lists live in your own PostgreSQL database and media volume — no third-party recipe SaaS, no ads, no lock-in. This template runs the official upstream image with a thin entrypoint wrapper that adapts it to Railway: it listens on Railway's assigned port, derives ALLOWED_HOSTS and CSRF_TRUSTED_ORIGINS from your domain (so logins and form submissions work out of the box), and lets the upstream boot script handle nginx, migrations, and static files exactly as upstream intended. The app is tuned for small instances: 2 gunicorn workers x 2 threads (about 600 MB RSS total; set GUNICORN_WORKERS=1 on the smallest plan if you like).

## Why Deploy

- **Zero-prompt deploy**: secrets (SECRET_KEY, database password) are generated per deployment via Railway's secret generator — nothing to invent, nothing to leak, and every deployment gets distinct credentials.
- **Digest-pinned upstream**: the image is pinned to the exact v2.7.2 digest, so a deploy today and a deploy next year build the same working version — no surprise upstream breakage mid-cooking.
- **Setup-wizard bootstrap**: no CLI, no shell, no management commands to run — the first page you see creates your admin account.
- **Persistent by design**: your recipe photos live on a dedicated volume and the database on its own volume, so redeploys keep everything.
- **Railway-networking-safe**: the wrapper listens on Railway's assigned port and pre-authorizes your domain plus Railway's internal probe host in ALLOWED_HOSTS (upstream issue #3478), so the app never rejects Railway's own requests.

## Common Use Cases

- **Family recipe hub**: import recipes from any recipe website by URL, keep them forever, and share the space with household members (invite-only by default).
- **Meal planning**: plan weeks of meals and auto-generate shopping lists grouped by supermarket aisle.
- **Personal cookbook**: tag, search, and scale recipes; track nutrition per serving; store your own photos.
- **Content creators / food bloggers**: keep a private staging cookbook and export or share selected recipes.
- **Offline-first cooking**: Tandoor's PWA works on phones and tablets in the kitchen, even with flaky Wi-Fi.

## Dependencies for

Tandoor is a Django application backed by a relational database and local (or S3) media storage.

### Deployment Dependencies

- **PostgreSQL 16** — provisioned by this template as a second service with its own persistent volume; the recipes service references its host and password automatically.
- **Persistent volume for media** — mounted at /opt/recipes/mediafiles for uploaded recipe images.
- **Python 3.14 + nginx runtime** — both are inside the official upstream image; nothing else to install.
- Optional: S3-compatible object storage (set the S3_* variables) if you prefer media in object storage instead of the volume; optional SMTP variables for outgoing email.

**Backup note:** Tandoor does not support database downgrades. Before upgrading, back up the PostgreSQL volume and the media volume together so database rows and files stay consistent.

**License note:** Tandoor Recipes is AGPL-3.0; this template packages the official upstream image unchanged and is not affiliated with the Tandoor project.
