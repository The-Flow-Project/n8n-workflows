# n8n-workflows

Collection of used n8n workflows in the flow-project.net environment.  
Also have a look at the [Flow environment documentation](https://docs.flow-project.net).

## Deployment variants

Two ways to run the same stack (n8n + Garage S3-compatible storage + the workflow forms).
Pick one; they don't replace each other. The self-hosted mailserver is a separate, optional
add-on on top of either — see "Outbound mail" below.

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
docker network create preprocess-network   # shared network, see "Docker networks" below
docker compose -f docker-compose.traefik-proxy.yml up -d
docker compose -f docker-compose.n8n.yml up -d
# add -f docker-compose.mailserver.yml for self-hosted outbound mail — see "Outbound mail" below
```

## Local / no-domain variant

No domain, no Traefik, no TLS — reach everything by the server's LAN IP over HTTP.
Intended for a trusted internal network.

```bash
docker network create inference-network    # shared networks for local API containers (see below)
docker network create preprocess-network
cp .env.local.example .env                 # set SERVER_IP and secrets
docker compose -f docker-compose.n8n.local.yml up -d
# add -f docker-compose.mailserver.local.yml for self-hosted outbound mail — see "Outbound mail" below
```

### Calling local APIs from workflows

n8n joins two shared external networks, `inference-network` and `preprocess-network`, in
addition to the stack's private `n8n-local`. To let a workflow call an API that runs in
**another compose stack** on the same host, have that stack join whichever of the two fits
and reach it by container name:

```yaml
# in the API's compose file
services:
  my-api:
    networks: [preprocess-network]   # or inference-network
networks:
  preprocess-network:
    external: true
```

Then the workflow calls `http://my-api:<port>`. APIs on **other LAN machines** work with no
setup (`http://<ip>:<port>`); for an API on the **host itself**, add
`extra_hosts: ["host.docker.internal:host-gateway"]` to the n8n service and call
`http://host.docker.internal:<port>`.

| Service         | URL                                            |
| --------------- | ---------------------------------------------- |
| n8n             | `http://<SERVER_IP>:5678`                      |
| Forms (landing) | `http://<SERVER_IP>/`                          |
| └ preprocessing | `http://<SERVER_IP>/workflows-preprocessing/`  |
| └ inference     | `http://<SERVER_IP>/workflows-inference/`      |
| └ write raw XML | `http://<SERVER_IP>/workflows-write-rawxml/`   |
| └ evaluation    | `http://<SERVER_IP>/workflows-evaluation/`     |

Users only need to remember the IP — the landing page links to every form. Garage (the S3
storage, see below) publishes no ports to the host, so it has no `<SERVER_IP>` URL — it's
only reachable from other containers.

## Outbound mail

Self-hosted mail (Postfix + OpenDKIM) is optional and lives in its own compose file, not
either base stack — it only covers n8n's own instance emails (user invites, password
resets). Workflow-level email uses a node credential instead (Mailjet, Gmail — see
`../README.md`), independent of any of this.

- **Self-hosted, own domain** — apply `docker-compose.mailserver.yml` /
  `docker-compose.mailserver.local.yml` on top of the matching base stack:

  ```bash
  docker compose -f docker-compose.n8n.local.yml -f docker-compose.mailserver.local.yml up -d
  ```

  Needs DNS access to `${DOMAIN_NAME}` to publish the DKIM TXT record — see that file's
  header comment. It delivers direct-to-MX over outbound port 25, which most managed or
  secured networks block, so this only works reliably on an open network.

- **No self-hosting at all** — skip both mailserver compose files entirely and use Mailjet
  or Gmail as the workflow's email credential instead — see `../README.md`. The right choice
  on a managed/secured network, since neither depends on outbound port 25.

## Storage (Garage)

Garage replaced MinIO as the S3-compatible store; both compose files run it as a single
`garage` container in single-node mode, backed by one `garage-data` volume. On first boot it
creates `BUCKET_NAME` and an access key with read/write on it automatically (no manual setup).
It's reachable two ways, both internal-only — no public route, no host-published ports:

1. **S3 API, SigV4-authenticated** — for n8n's S3 nodes and anything else that can hold
   credentials: `http://garage:3900/<bucket>/<key>`, region `garage`, force-path-style,
   using the `GARAGE_ACCESS_KEY`/`GARAGE_SECRET_KEY` from `.env`.
2. **Anonymous GET** — for services that only take a plain URL and can't do S3 auth (e.g. a
   preprocessing API fetching an uploaded file server-side). Garage's anonymous access is
   Host-header-routed rather than path-style, so `garage` carries a network alias on
   `preprocess-network` matching its bucket: `http://<bucket>.web.garage.internal:3902/<key>`.
   A second container, `garage-public-access-init`, enables this on the bucket automatically
   on first boot (see the compose files' comments for why it's a separate container — the
   image has no shell, and there's no server startup flag for it like there is for bucket
   creation).

## Docker networks

| Network | Created by | Purpose |
| --- | --- | --- |
| `traefik-public` | you, once (domain variant) | Traefik ingress; n8n, the forms, and garage's S3 API sit on it. |
| `n8n-local` | compose (local variant) | Private bridge for the local stack's own containers. |
| `inference-network` | you, once | Shared with sibling compose stacks so n8n can call an inference API by container name. |
| `preprocess-network` | you, once | Shared with sibling compose stacks so n8n can call a preprocessing API by container name — and the network garage uses for its anonymous-GET alias (see Storage above). |

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
