// AIDEV-NOTE: default runtime config baked into every form image.
// Overridden at container start by render-config.sh when WEBHOOK_BASE_URL is set
// (used by the local/IP deployment). Domain images ship this default unchanged.
window.APP_CONFIG = { webhookBase: "https://webhook.flow-project.net" };
