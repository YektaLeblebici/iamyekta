# Tiny image providing exiftool so neither the dev VM nor the server needs it
# installed on the host. `make prepare` builds this once (cached) then runs it.
# Build:  docker build -t iamyekta-exiftool:latest - < exiftool.Dockerfile
FROM docker.io/library/alpine:3.21

RUN apk add --no-cache exiftool

ENTRYPOINT ["exiftool"]
