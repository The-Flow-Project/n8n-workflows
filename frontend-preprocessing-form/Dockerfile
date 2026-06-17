FROM nginx:alpine

# AIDEV-NOTE: build context must be the repo root (same structure as frontend-inference-forms/).
# Serves the preprocessing form at the root URL on its own subdomain.
COPY workflows-preprocessing/form/preprocessing-index.html /usr/share/nginx/html/index.html
COPY workflows-preprocessing/form/style.css                /usr/share/nginx/html/style.css
COPY workflows-preprocessing/form/favicon.ico              /usr/share/nginx/html/favicon.ico
COPY workflows-preprocessing/form/TheFlow_white.png        /usr/share/nginx/html/TheFlow_white.png

# AIDEV-NOTE: default runtime config (webhookBase); form fetches /config.js. Public-domain default.
# Building from the repo root lets this share the single frontend-common/config.js (no duplicate).
COPY frontend-common/config.js                             /usr/share/nginx/html/config.js
