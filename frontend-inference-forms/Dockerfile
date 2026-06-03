FROM nginx:alpine

# AIDEV-NOTE: build context must be the repo root; each form's HTML is renamed to
# index.html so nginx serves it as the directory default at its subpath.
COPY workflows-inference/form/inference-index.html      /usr/share/nginx/html/workflows-inference/index.html
COPY workflows-inference/form/style.css                 /usr/share/nginx/html/workflows-inference/style.css
COPY workflows-inference/form/favicon.ico               /usr/share/nginx/html/workflows-inference/favicon.ico
COPY workflows-inference/form/TheFlow_black.png         /usr/share/nginx/html/workflows-inference/TheFlow_black.png
COPY workflows-inference/form/TheFlow_white.png         /usr/share/nginx/html/workflows-inference/TheFlow_white.png

COPY workflows-write-rawxml/form/write-rawxml-index.html /usr/share/nginx/html/workflows-write-rawxml/index.html
COPY workflows-write-rawxml/form/style.css               /usr/share/nginx/html/workflows-write-rawxml/style.css
COPY workflows-write-rawxml/form/favicon.ico             /usr/share/nginx/html/workflows-write-rawxml/favicon.ico
COPY workflows-write-rawxml/form/TheFlow_black.png       /usr/share/nginx/html/workflows-write-rawxml/TheFlow_black.png
COPY workflows-write-rawxml/form/TheFlow_white.png       /usr/share/nginx/html/workflows-write-rawxml/TheFlow_white.png

COPY workflows-evaluation/form/evaluation-index.html    /usr/share/nginx/html/workflows-evaluation/index.html
COPY workflows-evaluation/form/style.css                /usr/share/nginx/html/workflows-evaluation/style.css
COPY workflows-evaluation/form/favicon.ico              /usr/share/nginx/html/workflows-evaluation/favicon.ico
COPY workflows-evaluation/form/TheFlow_black.png        /usr/share/nginx/html/workflows-evaluation/TheFlow_black.png
COPY workflows-evaluation/form/TheFlow_white.png        /usr/share/nginx/html/workflows-evaluation/TheFlow_white.png
