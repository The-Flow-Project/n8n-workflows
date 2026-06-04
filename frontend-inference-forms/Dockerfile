FROM nginx:alpine

COPY workflows-inference/form/inference-index.html /usr/share/nginx/html/index.html
COPY workflows-inference/form/style.css /usr/share/nginx/html/style.css
COPY workflows-inference/form/TheFlow_white.png /usr/share/nginx/html/TheFlow_white.png
COPY workflows-inference/form/favicon.ico /usr/share/nginx/html/favicon.ico

COPY workflows-inference /usr/share/nginx/html/workflows-inference
COPY workflows-write-rawxml /usr/share/nginx/html/workflows-write-rawxml
COPY workflows-evaluation /usr/share/nginx/html/workflows-evaluation