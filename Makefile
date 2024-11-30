prepare:
	exiftool -r -all= -tagsfromfile @ -icc_profile -overwrite_original  ./static/assets/


build: clean prepare
	docker-compose build

up: prepare
	@echo ">> Starting up Docker container(s)."
	docker-compose up --build -d

clean:
	@echo ">> Removing container(s) and image(s)."
	docker-compose down --rmi all

.PHONY: build up clean
