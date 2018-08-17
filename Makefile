
build: clean hugo-build docker-up
	@echo ">> Built Hugo and started Docker container(s)."

build-local: clean hugo-build-local docker-up

hugo-build-local: clean
	@echo ">> Building Hugo pages for local testing. Reverting baseURL."
	@hugo --verbose -b http://localhost/

hugo-build: clean
	@echo ">> Building Hugo pages."
	@hugo --verbose

docker-up:
	@echo ">> Starting up Docker container(s)."
	@docker-compose up --build -d

clean:
	@echo ">> Removing public directory and container(s)."
	@rm -rf public/
	@docker-compose down

.PHONY: build build-local hugo-build hugo-build-local docker-up clean
