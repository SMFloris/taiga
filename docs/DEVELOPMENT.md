# Development

## Local Docker stack

From the monorepo root, with Docker and the Compose plugin installed:

```sh
docker compose up --build -d --wait
```

The first build installs Python and frontend dependencies and can take several minutes. Open `http://localhost:9000` and log in as `admin` with password `admin`. The backend and frontend images compile this checkout; supporting services use published images.

Mail is delivered to the local Mailpit inbox at `http://localhost:8025`. PostgreSQL and RabbitMQ are only accessible inside the Compose network. Published ports bind to `127.0.0.1`. This configuration uses development credentials and is intended for local testing.

Optional configuration:

```sh
cp .env.example .env
# Edit ports and the initial administrator credentials, then start Compose.
```

`TAIGA_PORT` changes the app port and the frontend/backend URLs together. `MAIL_PORT` changes the inbox port. Administrator environment variables are used only when that username does not exist; changing the password variable does not reset an existing account.

Source changes require rebuilding their image; this setup does not hot reload:

```sh
# After frontend changes:
docker compose up -d --build front

# After backend changes (also reruns initialization/migrations):
docker compose up -d --build init back async
```

After recreating either application container, restart the gateway so nginx refreshes its container addresses:

```sh
docker compose restart gateway
```

Useful commands:

```sh
docker compose ps -a
docker compose logs -f back async
docker compose exec back python manage.py shell
docker compose exec back python manage.py changepassword admin
docker compose down
```

Database, uploads, static assets, and queue data use named volumes. To **delete all local data** and start over:

```sh
docker compose down -v
docker compose up --build -d --wait
```

This stack is independent of production and does not import production data.

## Repository layout

Edit UI code under `taiga-front/` and API code under `taiga-back/`. There are no nested Git repositories or submodules. Preserve each project's dependency files and license notices.

The original forks' `.github/workflows/` directories remain inside their subtrees for reference. GitHub only executes workflows in the monorepo root's `.github/workflows/`; root CI has not been configured yet.

## Frontend

The imported project uses AngularJS, CoffeeScript, Jade, Sass, and Gulp. Use Node **16.19.1**, matching `taiga-front/.nvmrc` and its existing CI, when working on this baseline.

```sh
cd taiga-front
nvm install
nvm use
npm ci
npm start
```

The development server runs at `http://localhost:9001/`. Review `conf/conf.example.json` for API and event endpoints. Gulp generates `dist/conf.json`; point it at a local or isolated development backend before exercising writes.

From the monorepo root, `make front-build` compiles the local source and `make front-test` runs the project's CI command, which requires Chrome/Chromium.

## Backend

Use Python **3.11**, matching the project's Docker runtime, and a dedicated PostgreSQL database.

```sh
python3.11 -m venv .venv
. .venv/bin/activate
make back-install
make back-test ARGS='tests/unit'
```

The test configuration is `taiga-back/tests/config.py`. It expects PostgreSQL on localhost:5432 with database/user/password `taiga`; the user must be allowed to create the test database. Pass individual pytest paths through `ARGS`.

For the development server, review `taiga-back/settings/common.py` and create the ignored `taiga-back/settings/config.py` using `settings/config.py.dev.example` as a starting point. Set `DJANGO_SETTINGS_MODULE=settings.config` explicitly when running management commands:

```sh
cd taiga-back
DJANGO_SETTINGS_MODULE=settings.config python manage.py migrate
DJANGO_SETTINGS_MODULE=settings.config python manage.py loaddata initial_project_templates
DJANGO_SETTINGS_MODULE=settings.config python manage.py createsuperuser
DJANGO_SETTINGS_MODULE=settings.config python manage.py runserver 127.0.0.1:8000
```

## Updating from the forks

Use the `frisbo` branch for our changes. The fork branches are also named `frisbo`; upstream repositories continue to use `main`.

After Git initialization, these remotes are available:

| Remote | Repository |
| --- | --- |
| `front` | `https://github.com/SMFloris/taiga-front.git` |
| `back` | `https://github.com/SMFloris/taiga-back.git` |
| `upstream-front` | `https://github.com/taigaio/taiga-front.git` |
| `upstream-back` | `https://github.com/taigaio/taiga-back.git` |

With a clean working tree, import later fork changes using the same full-history subtree strategy:

```sh
git subtree pull --prefix=taiga-front front frisbo
git subtree pull --prefix=taiga-back back frisbo
```

Upstream changes can be imported using the corresponding upstream remote. Review and test those changes before deploying.

To prepare a frontend branch for the separate fork:

```sh
git subtree split --prefix=taiga-front -b front-frisbo
```

Review that branch, then publish it to the frontend fork's `frisbo` branch when ready:

```sh
git push front front-frisbo:frisbo
```

Use `--prefix=taiga-back` and remote `back` for backend changes. The monorepo needs its own GitHub repository before configuring an `origin`; it should not be pushed wholesale into either component fork.

## Future fork deployment

The imported backend Dockerfile builds local source:

```sh
docker build -f taiga-back/docker/Dockerfile -t taiga-back:local taiga-back
```

The imported `taiga-front/docker/Dockerfile` downloads a prebuilt upstream release. Building that Dockerfile directly does **not** include frontend edits. The local Compose stack instead uses `docker/local/frontend.Dockerfile`, which compiles this checkout and packages the result with its runtime configuration. Optional contrib plugins are not bundled in the local image.

Production runs at `https://taiga.frisbo.ro` on `95.216.72.50`, with its deployment in `/root/taiga-docker`. This monorepo setup does not deploy local code. Production deployment configuration and credentials are not copied into this repository.
