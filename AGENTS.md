# AGENTS.md

This is a n8n environment with those features:

- docker compose files for multiple purposes in @docker-templates
- frontend forms for different services the n8n instance manages: preprocessing, inference, and evaluation.
- n8n workflows for the different tasks to import in the n8n UI.

It is the intention you can use this instance just by creating a proper .env file and running one or multiple of the docker compose files.
Which one you chose depends on your usecase:

- @docker-templates/docker-compose.n8n.yml for generic use and an existing traefik proxy (@docker-templates/docker-compose.traefik-proxy.yml to run that proxy server).
- @docker-templates/docker-compose.n8n.local.yml for the local use without domains. The API calls in n8n run via docker network - so the services need to be in the same docker network or reachable via LAN. The workflows are atm designed to work with docker networks.
- @docker-templates/docker-compose.mailserver.local.yml and @docker-templates/docker-compose.local.yml as override, if you don't want to use the mailjet solution but a simple mailserver container with DKIM keys. For this you need to change the workflows and activate the E-Mail nodes.

For the frontend properly working, you need to set the webhook base ip/url in @frontend-common/config.js. This webhook is the one provided by the n8n-workflows to trigger those workflows.

The services, which are called by the n8n-workflows have to be started via other docker compose files.
You can find the code of those in this GitHub repositories:

- Preprocessing service: https://github.com/The-Flow-Project/service-trocr-preprocess
- Inference/Evaluation service: https://github.com/The-Flow-Project/service-trocr-inference

## Conventions

- All variables are set in .env
- Workflows are imported by the admin via n8n interface
- In the simple variant, the admin needs a mailjet account, access to the domains DNS records, and add those credentials in n8n.
- In the mailserver variant, the admin needs access to the domains DNS records. And the outgoing port 25 needs to be open.
- The local variant is used in those cases:
  - If the ports 80 and 443 are not open in your network
  - You don't have a domain to run it with (then use a SMTP account to send emails - those nodes do not exist in the workflows)
  - For development / testing
- If you choose to run the URL based variant, you can set the domains/subdomains. Those should all have a DNS record (be aware of the update time of 48h)
- The admin can always change the URL/IPs of the endpoints for the API calls in the n8n workflows.

## Rules

- Do not use dashes in generated text!
- If you add code blocks or change methods/classes aso. significantly, put a short comment in front starting with "# AIDEV-NOTE:" and explaining the reason/function aso.

The documentation is generetad via mkdocs in this repository:
https://github.com/The-Flow-Project/flow-docs