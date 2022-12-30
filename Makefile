build: clean clean-docker hugo-build docker-up
	@echo ">> Built Hugo and started Docker container(s)."

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

.PHONY: build hugo-build docker-up clean clean-docker
