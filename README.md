# n8n-workflows

Collection of used n8n workflows in the flow-project.net environment

## Sending email from workflows

The stack has an optional self-hosted mail relay (see "Outbound mail" in
`docker-templates/README.md`) that needs no external account, just DNS access for DKIM — but
it only covers n8n's own system emails (user invites, password resets), and it's opt-in, not
part of the base compose files. Workflows that send email do so via a node with its **own**
credential, independent of the docker setup entirely, so any workflow can use a different
sending method with no docker-compose changes at all:

- **Mailjet** — create a Mailjet account, verify `${DOMAIN_NAME}` there (they give you the DNS
  records to add), then use n8n's
  [Mailjet credential](https://docs.n8n.io/integrations/builtin/credentials/mailjet/) in the
  workflow's email node. Still needs DNS access for domain verification, but no local
  DKIM/Postfix setup.
- **Gmail** — reuse an existing Gmail account via n8n's
  [Gmail credential](https://docs.n8n.io/integrations/builtin/credentials/send-email/gmail/), OAuth
  login only. No DNS or domain work at all, so this is the option for managed networks or
  anyone without access to the domain's DNS — at the cost of sending from a `@gmail.com`
  address rather than `${DOMAIN_NAME}`.
