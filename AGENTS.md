# Repository Guidelines

## Project Structure & Module Organization
`content/` holds Markdown posts; keep drafts marked `draft: true` until ready. Layout overrides reside in `layouts/`, while the custom theme lives under `themes/iamyekta-terminal/`; keep template tweaks isolated there. Post images live in `assets/assets/` (processed by Hugo Pipes); other static files (favicons, `profile.jpg`) go in `static/`. `make prepare` scrubs EXIF data from `assets/assets/` via a containerized exiftool. Generated HTML lands in `public/` and is recreated by the Docker builder, so do not commit manual edits there.

## Build, Test, and Development Commands
The same targets run unchanged on the dev VM and the server; both only need `docker`, `docker compose`, and `make` (Hugo and exiftool run in containers).
- `make prepare` – strip metadata from `assets/assets/` (containerized exiftool, built on first use). Runs automatically before `build`/`up`.
- `make build` – `docker compose build`: runs Hugo (minified, with GC) inside the multi-stage Dockerfile and bakes the result into the nginx image.
- `make up` – build if needed and serve nginx on host port `WEB_PORT` (default 80) with the production `baseURL`. Stop with `make down`.
- `make dev-up` – local preview: like `make up` but serves on 8001 with host-relative links (`WEB_PORT=8001 HUGO_BASEURL=/`), so nav links and self-hosted fonts stay on the dev box instead of pointing at the live site (assets/CSS are already host-relative via Hugo Pipes' `.RelPermalink`).
- `make clean` – full teardown, also removing the built image.
The container engine and compose command are the overridable `ENGINE` / `COMPOSE` Make variables (default `docker` / `docker compose`).

## Coding Style & Naming Conventions
Markdown uses 80-character prose preferred, fenced code blocks with explicit language hints, and lowercase kebab-case filenames under `content/post/`. Front matter follows YAML with two-space indentation; ensure titles are sentence case and include `slug` only when deviating from filename. Hugo templates and Nginx configs follow two-space indentation; reuse partials in `themes/iamyekta-terminal/layouts/partials/` (and the project-level `layouts/partials/`) when adding new markup. Post images should be `.webp` for photos when possible and named to match post slugs.

## Testing Guidelines
Run `make up` to review pages and confirm navigation, images, and syntax highlighting. Watch the build logs for Hugo warnings about missing resources; resolve before publishing. The Dockerfile already builds with `--gc --minify`; spot-check the served output for unexpected artifacts before deploying.

## Commit & Pull Request Guidelines
Commit messages follow Conventional Commits (`feat:`, `fix:`, `chore:`) as seen in recent history; keep scope small and descriptive. Include the motivation and key files changed in the PR description, link related issues, and attach before/after screenshots or URLs for visual tweaks. Flag content changes that require asset updates or configuration adjustments so reviewers can validate deployments.

## Deployment & Operations Notes
Publishing relies on the Docker multi-stage build defined in `Dockerfile` and `docker-compose.yml`; keep the base image tag current with the Hugo release in `FROM hugomods/hugo`. The build context is trimmed by `.dockerignore`. When updating nginx defaults, edit `nginx/default.conf` and verify the container rebuild succeeds locally. Secrets and environment-specific values are managed outside this repo; avoid committing credentials or TLS material.
