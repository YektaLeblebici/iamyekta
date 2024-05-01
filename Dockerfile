# Builder image
FROM hugomods/hugo:0.125.4 AS builder

RUN mkdir -p /src

COPY ./ /src/

WORKDIR /src

# Generate public/ directory from Hugo templates
RUN hugo --verbose

# Nginx image
FROM nginx:alpine
LABEL maintainer "yekta@iamyekta.com"

# SSL terminated elsewhere.
EXPOSE 80/tcp

# Copy Hugo-generated static website dir.
COPY --from=builder /src/public/ /usr/share/nginx/html

# Copy custom Nginx configuration.
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Configure permissions.
RUN chown -R nginx:nginx /usr/share/nginx/html
