FROM nginx:1.31.6-alpine3.24

COPY index.html /usr/share/nginx/html/

# Regenerated on every container start by the entrypoint script below; this
# build-time default keeps the page working if the script never runs.
RUN printf 'window.DASH0_CONFIG = { authToken: "" };\n' > /usr/share/nginx/html/dash0-config.js

COPY docker-entrypoint.d/30-dash0-web-sdk.sh /docker-entrypoint.d/30-dash0-web-sdk.sh
RUN chmod +x /docker-entrypoint.d/30-dash0-web-sdk.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
