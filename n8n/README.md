# n8n Helm Chart

This directory contains the Helm chart for deploying [n8n](https://n8n.io), an extendable workflow automation tool.

## Quick start

Add the chart repository and install with the default values:

```bash
helm repo add n8n https://example.com/charts
helm repo update
helm install my-n8n n8n/n8n
```

Customise the deployment by supplying your own `values.yaml` or overriding settings on the command line.

## Common configuration options

- **replicaCount** – number of pods to run.
- **image.tag** – n8n container image tag to deploy.
- **ingress.enabled** – expose the service using an ingress resource.
- **persistence.enabled** – store workflows on a persistent volume.
- **networkPolicy.enabled** – create a NetworkPolicy to restrict traffic.
- **database.host** – connect to an external PostgreSQL database instead of the built in SQLite storage.
- **extraEnv** – additional environment variables passed to the container.

See `values.yaml` for all available settings.

## Security

By default the chart runs the n8n container as a non-root user and mounts the
root filesystem as read-only with privilege escalation disabled. These settings
are defined in `podSecurityContext` and `securityContext` in `values.yaml` and
can be adjusted if needed.

## Updating n8n versions

When a new n8n release is published, bump the `appVersion` field in
`Chart.yaml` and update the default `image.tag` in `values.yaml` to match.
