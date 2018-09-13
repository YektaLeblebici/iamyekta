
build: clean clean-docker hugo-build docker-up
	@echo ">> Built Hugo and started Docker container(s)."

build-local: clean clean-docker hugo-build-local docker-up

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
	@echo ">> Removing public directory."
	@rm -rf public/

clean-docker:
	@echo ">> Removing container(s)."
	@docker-compose down

.PHONY: build build-local hugo-build hugo-build-local docker-up clean clean-docker
