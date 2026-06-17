# n8n environment — deployment variants

Two ways to run the same stack (n8n + MinIO + send-only mailserver + the workflow forms).
Pick one; they don't replace each other.

|               | Domain variant                              | Local / no-domain variant       |
| ------------- | ------------------------------------------- | ------------------------------- |
| Compose file  | `docker-compose.n8n.yml`                    | `docker-compose.n8n.local.yml`  |
| Env template  | `.env.example`                              | `.env.local.example`            |
| Reverse proxy | Traefik (`docker-compose.traefik-proxy.yml`)| none                            |
| Reached via   | subdomains (`n8n.example.com`, …)           | server LAN IP + port            |
| TLS           | Let's Encrypt                               | plain HTTP (trusted LAN)        |
| Forms         | one container per subdomain                 | one container, sub-paths        |

## Domain variant (public/Traefik)

Subdomain routing + TLS. Requires a Traefik instance on the `traefik-public` network.
For a **closed LAN with a public domain**, switch Traefik from the HTTP-01 to the **DNS-01**
ACME challenge (so certs issue without inbound ports) and point a public wildcard
`*.domain → <LAN IP>` record at the host. See `docker-compose.traefik-proxy.yml`.

```bash
docker network create traefik-public
docker compose -f docker-compose.traefik-proxy.yml up -d
docker compose -f docker-compose.n8n.yml up -d
```

## Local / no-domain variant

No domain, no Traefik, no TLS — reach everything by the server's LAN IP over HTTP.
Intended for a trusted internal network.

```bash
docker network create flow-apis            # shared network for local API containers (see below)
cp .env.local.example .env                 # set SERVER_IP and secrets
docker compose -f docker-compose.n8n.local.yml up -d
```

### Calling local APIs from workflows

n8n joins a shared external network `flow-apis` in addition to the stack's private
`n8n-local`. To let a workflow call an API that runs in **another compose stack** on the
same host, have that stack join the same network and reach it by container name:

```yaml
# in the API's compose file
services:
  my-api:
    networks: [flow-apis]
networks:
  flow-apis:
    external: true
```

Then the workflow calls `http://my-api:<port>`. APIs on **other LAN machines** work with no
setup (`http://<ip>:<port>`); for an API on the **host itself**, add
`extra_hosts: ["host.docker.internal:host-gateway"]` to the n8n service and call
`http://host.docker.internal:<port>`.

| Service         | URL                                            |
| --------------- | ---------------------------------------------- |
| n8n             | `http://<SERVER_IP>:5678`                      |
| MinIO console   | `http://<SERVER_IP>:9001`                      |
| MinIO S3 API    | `http://<SERVER_IP>:9000`                      |
| Forms (landing) | `http://<SERVER_IP>/`                          |
| └ preprocessing | `http://<SERVER_IP>/workflows-preprocessing/`  |
| └ inference     | `http://<SERVER_IP>/workflows-inference/`      |
| └ write raw XML | `http://<SERVER_IP>/workflows-write-rawxml/`   |
| └ evaluation    | `http://<SERVER_IP>/workflows-evaluation/`     |

Users only need to remember the IP — the landing page links to every form.

## How the forms find the webhook (`config.js`)

The form HTML does **not** hardcode the n8n webhook host. At container start each forms
image writes `/config.js`:

```js
window.APP_CONFIG = { webhookBase: "<base>" };
```

and every form builds its endpoint as `webhookBase + "/webhook/<name>"`.

- **Domain images** ship the default (`https://webhook.<domain>`) baked in — see
  `frontend-common/config.js`.
- **Local image** overrides it at start from `WEBHOOK_BASE_URL` (set to
  `http://<SERVER_IP>:5678` in the compose) via `frontend-common/render-config.sh`.

So the same form HTML works in every deployment by changing one env var — no rebuild,
no editing HTML. If `/config.js` is ever missing, the HTML falls back to the public domain.
