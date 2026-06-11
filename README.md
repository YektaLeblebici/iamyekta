# iamyekta

Source, posts, assets and the custom theme of my personal website,
<https://iamyekta.com>.

* Static site generated with [Hugo](https://gohugo.io/).
* Posts are written in Markdown under `content/post/`.
* Custom theme `iamyekta-terminal` — a terminal/editor look with a light/dark toggle.
* Built and deployed with Docker Compose, driven by a small Makefile.

## Dependencies

Only two, and identical on a dev machine and the server:

* **`docker`** with the **`docker compose`** plugin (Podman works too — the
  Makefile's `ENGINE` / `COMPOSE` variables are overridable).
* **`make`**

Hugo and exiftool both run inside containers, so neither needs to be installed
on the host.

## Build & serve

The same targets run unchanged on the dev VM and the server:

* `make build` — build the site image (Hugo runs minified inside the Dockerfile builder).
* `make up` — build if needed and serve nginx on port 80 with the production
  `baseURL` (`https://iamyekta.com/`).
* `make dev-up` — local preview: like `make up`, but serves on port 8001 with
  host-relative links (`WEB_PORT=8001 HUGO_BASEURL=/`) so navigation stays on your
  box instead of redirecting to the live site.
* `make down` — stop the container (keeps the image for a fast restart).
* `make clean` — full teardown (also removes the built image).
* `make prepare` — strip EXIF/metadata from images in `assets/assets/` (runs
  automatically before `build` / `up`).

## Overrides

`make up` and `make dev-up` cover production and local preview. To tweak directly,
two environment variables apply: `WEB_PORT` (host port, default 80) and
`HUGO_BASEURL` (empty = production `baseURL`; `/` = host-relative links). E.g. a
one-off `WEB_PORT=9000 make up`.

## Adding a post

* Create `content/post/<slug>.md` (front matter + Markdown body); keep drafts
  marked `draft: true` until ready.
* Put post images in `assets/assets/` (processed by Hugo Pipes).
* `make up` to preview, then commit.

## Reuse

To build a similar site: clone the repo, empty `content/`, adjust `config.yml`,
replace `static/favicon-*` and `static/profile.jpg`, then `make build`.

## Attribution

Twemoji — © Twitter, Inc. and other contributors, licensed under CC-BY 4.0.
<https://github.com/jdecked/twemoji> (active default)
