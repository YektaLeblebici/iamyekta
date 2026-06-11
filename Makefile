ENGINE   ?= docker
COMPOSE  ?= docker compose

# Local exiftool image
EXIFTOOL_IMG ?= iamyekta-exiftool:latest

# SELinux hosts (Fedora/RHEL) need :Z on bind mounts; it is a no-op on hosts
# without SELinux, so it is safe to leave on. Set MOUNT_OPT= to drop it.
MOUNT_OPT ?= :Z

prepare:
	$(ENGINE) build -t $(EXIFTOOL_IMG) - < exiftool.Dockerfile
	$(ENGINE) run --rm -v "$(CURDIR):/src$(MOUNT_OPT)" -w /src $(EXIFTOOL_IMG) \
		-r -all= -tagsfromfile @ -icc_profile -overwrite_original ./assets/assets/

build: clean prepare
	$(COMPOSE) build

up: prepare
	@echo ">> Building & serving nginx (host port WEB_PORT, default 80). Stop with: make down"
	$(COMPOSE) up --build -d

# Like up, but forces the dev profile inline: unprivileged port + host-relative links.
dev-up: prepare
	@echo ">> dev: serving nginx on :8001 with host-relative links. Stop with: make down"
	WEB_PORT=8001 HUGO_BASEURL=/ $(COMPOSE) up --build -d

down:
	$(COMPOSE) down

clean:
	@echo ">> Removing container(s) and image(s)."
	$(COMPOSE) down --rmi all

.PHONY: prepare build up dev-up down clean
