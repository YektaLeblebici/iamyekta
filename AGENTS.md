# Repository Guidelines

## Project Structure & Module Organization
`content/` holds Markdown posts generated via `hugo new post/<slug>.md`; keep drafts marked `draft: true` until ready. Layout overrides reside in `layouts/` while the upstream theme lives under `themes/iamyekta-lithium/`; keep local template tweaks isolated there to ease theme upgrades. Static assets go in `static/` (images under `static/assets/`), and `make prepare` will scrub EXIF data before packaging. Generated HTML lands in `public/` and is recreated by the Docker builder, so do not commit manual edits there.

## Build, Test, and Development Commands
- `make prepare` – strips metadata from `static/assets/` before bundling.
- `make build` – runs `docker-compose build`, executing Hugo inside the multi-stage Dockerfile and refreshing `public/`.
- `make up` – rebuilds as needed and launches the nginx container on port 80 for local smoke checks; stop with `docker-compose down`.
- `hugo server -D` – fast edit loop outside Docker; serves drafts and watches for changes.

## Coding Style & Naming Conventions
Markdown uses 80-character prose preferred, fenced code blocks with explicit language hints, and lowercase kebab-case filenames under `content/post/`. Front matter follows YAML with two-space indentation; ensure titles are sentence case and include `slug` only when deviating from filename. Hugo templates and Nginx configs follow two-space indentation; reuse partials in `themes/iamyekta-lithium/layouts/partials/` when adding new markup. Static assets should be `.webp` for photos when possible and named to match post slugs.

## Testing Guidelines
Run `make up` or `hugo server -D` to review pages and confirm navigation, images, and syntax highlighting. Watch the Hugo logs for warnings about missing resources; resolve before publishing. For performance checks, run `hugo --verbose --gc` locally and spot-check the regenerated `public/` output for unexpected artifacts.

## Commit & Pull Request Guidelines
Commit messages follow Conventional Commits (`feat:`, `fix:`, `chore:`) as seen in recent history; keep scope small and descriptive. Include the motivation and key files changed in the PR description, link related issues, and attach before/after screenshots or URLs for visual tweaks. Flag content changes that require asset updates or configuration adjustments so reviewers can validate deployments.

## Deployment & Operations Notes
Publishing relies on the Docker multi-stage build defined in `Dockerfile` and `docker-compose.yml`; keep base image tags current with the Hugo release in `FROM hugomods/hugo`. When updating nginx defaults, edit `nginx/default.conf` and verify the container rebuild succeeds locally. Secrets and environment-specific values are managed outside this repo; avoid committing credentials or TLS material.
