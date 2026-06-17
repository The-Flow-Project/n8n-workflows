FROM nginx:alpine

# AIDEV-NOTE: consolidated forms image for the LOCAL / no-domain deployment.
# Build context = repo root. Serves a landing menu at / and every form under a sub-path,
# so users reach everything from a single http://<server-ip>/ entry point (no per-form port).
# Static HTML under sub-paths is safe because every form references its assets relatively.
# Webhook base is injected at container start via render-config.sh (WEBHOOK_BASE_URL).

# --- Landing menu at / ---
COPY frontend-forms/landing-index.html              /usr/share/nginx/html/index.html
COPY workflows-inference/form/favicon.ico           /usr/share/nginx/html/favicon.ico
COPY workflows-inference/form/TheFlow_white.png     /usr/share/nginx/html/TheFlow_white.png
COPY workflows-inference/form/TheFlow_black.png     /usr/share/nginx/html/TheFlow_black.png

# --- Preprocessing form ---
COPY workflows-preprocessing/form/preprocessing-index.html /usr/share/nginx/html/workflows-preprocessing/index.html
COPY workflows-preprocessing/form/style.css                /usr/share/nginx/html/workflows-preprocessing/style.css
COPY workflows-preprocessing/form/favicon.ico              /usr/share/nginx/html/workflows-preprocessing/favicon.ico
COPY workflows-preprocessing/form/TheFlow_white.png        /usr/share/nginx/html/workflows-preprocessing/TheFlow_white.png
COPY workflows-preprocessing/form/TheFlow_black.png        /usr/share/nginx/html/workflows-preprocessing/TheFlow_black.png

# --- Inference form ---
COPY workflows-inference/form/inference-index.html  /usr/share/nginx/html/workflows-inference/index.html
COPY workflows-inference/form/style.css             /usr/share/nginx/html/workflows-inference/style.css
COPY workflows-inference/form/favicon.ico           /usr/share/nginx/html/workflows-inference/favicon.ico
COPY workflows-inference/form/TheFlow_black.png     /usr/share/nginx/html/workflows-inference/TheFlow_black.png
COPY workflows-inference/form/TheFlow_white.png     /usr/share/nginx/html/workflows-inference/TheFlow_white.png

# --- Write raw XML form ---
COPY workflows-write-rawxml/form/write-rawxml-index.html /usr/share/nginx/html/workflows-write-rawxml/index.html
COPY workflows-write-rawxml/form/style.css               /usr/share/nginx/html/workflows-write-rawxml/style.css
COPY workflows-write-rawxml/form/favicon.ico             /usr/share/nginx/html/workflows-write-rawxml/favicon.ico
COPY workflows-write-rawxml/form/TheFlow_black.png       /usr/share/nginx/html/workflows-write-rawxml/TheFlow_black.png
COPY workflows-write-rawxml/form/TheFlow_white.png       /usr/share/nginx/html/workflows-write-rawxml/TheFlow_white.png

# --- Evaluation form ---
COPY workflows-evaluation/form/evaluation-index.html /usr/share/nginx/html/workflows-evaluation/index.html
COPY workflows-evaluation/form/style.css             /usr/share/nginx/html/workflows-evaluation/style.css
COPY workflows-evaluation/form/favicon.ico           /usr/share/nginx/html/workflows-evaluation/favicon.ico
COPY workflows-evaluation/form/TheFlow_black.png     /usr/share/nginx/html/workflows-evaluation/TheFlow_black.png
COPY workflows-evaluation/form/TheFlow_white.png     /usr/share/nginx/html/workflows-evaluation/TheFlow_white.png

# --- Runtime config (webhookBase) ---
# Default baked in; render-config.sh regenerates /config.js from $WEBHOOK_BASE_URL at start.
COPY frontend-common/config.js        /usr/share/nginx/html/config.js
COPY frontend-common/render-config.sh /docker-entrypoint.d/40-render-config.sh
RUN chmod +x /docker-entrypoint.d/40-render-config.sh
