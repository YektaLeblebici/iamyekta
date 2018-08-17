FROM nginx:alpine
LABEL maintainer "yekta@iamyekta.com"

# SSL terminated elsewhere.
EXPOSE 80/tcp

# Copy Hugo-generated static website dir.
COPY public/ /usr/share/nginx/html/

# Copy custom Nginx configuration.
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Configure permissions and nginx.
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN sed -i 's/#error_page/error_page/' /etc/nginx/conf.d/default.conf
