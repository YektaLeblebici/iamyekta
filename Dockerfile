# Builder image
FROM hugomods/hugo:0.163.0 AS builder

RUN mkdir -p /src

COPY ./ /src/

WORKDIR /src

# Generate public/ (minified, with resource GC). HUGO_BASEURL is empty in prod
# (uses config baseURL); dev passes "/" for host-relative links — see docker-compose.yml.
ARG HUGO_BASEURL=""
RUN hugo --gc --minify ${HUGO_BASEURL:+--baseURL "$HUGO_BASEURL"}

# Nginx image
FROM nginx:1.31-alpine
LABEL maintainer="yekta@iamyekta.com"

# SSL terminated elsewhere.
EXPOSE 80/tcp

# Copy Hugo-generated static website dir.
COPY --from=builder /src/public/ /usr/share/nginx/html

# Copy custom Nginx configuration.
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Configure permissions.
RUN chown -R nginx:nginx /usr/share/nginx/html
