#!/bin/sh
# AIDEV-NOTE: regenerates /config.js from $WEBHOOK_BASE_URL at container start.
# Dropped into /docker-entrypoint.d/ so the official nginx image runs it before
# starting the server. Lets one image serve any deployment (domain or local/IP)
# by only changing an env var — no rebuild, no editing the form HTML.
set -e

: "${WEBHOOK_BASE_URL:=https://webhook.flow-project.net}"

cat > /usr/share/nginx/html/config.js <<EOF
window.APP_CONFIG = { webhookBase: "${WEBHOOK_BASE_URL}" };
EOF

echo "[render-config] config.js -> webhookBase=${WEBHOOK_BASE_URL}"
