prepare:
	exiftool -r -all= -orientation -overwrite_original ./static/assets/

build: clean prepare
	docker-compose build

up:
	@echo ">> Starting up Docker container(s)."
	docker-compose up --build -d

clean:
	@echo ">> Removing container(s) and image(s)."
	docker-compose down --rmi all

.PHONY: build up clean