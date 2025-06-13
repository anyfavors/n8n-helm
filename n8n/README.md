# n8n Helm Chart

This directory contains the Helm chart for deploying [n8n](https://n8n.io), an extendable workflow automation tool.

## Quick start

Clone this repository and install the chart from the `n8n` directory:

```bash
git clone https://github.com/anyfavors/n8n-helm.git
cd n8n-helm
helm install my-n8n ./n8n
```

Customise the deployment by supplying your own `values.yaml` or overriding settings on the command line.

## Common configuration options

- **replicaCount** – number of pods to run.
- **image.tag** – n8n container image tag to deploy.
- **ingress.enabled** – expose the service using an ingress resource.
- **persistence.enabled** – store workflows on a persistent volume.
- **networkPolicy.enabled** – create a NetworkPolicy to restrict traffic.
- **pdb.enabled** – create a PodDisruptionBudget for the deployment.
- **rbac.create** – create Role and RoleBinding resources.
- **database.host** – connect to an external PostgreSQL database instead of the built in SQLite storage.
- **encryptionKeySecret.name** – Kubernetes secret providing `N8N_ENCRYPTION_KEY`.
- **extraEnv** – additional environment variables passed to the container.
- **extraSecrets** – mount additional Secrets inside the pod.
- **extraConfigMaps** – mount additional ConfigMaps inside the pod.
- **resources** – CPU and memory requests/limits. Defaults are conservative and
  should be tuned for production installations.

See `values.yaml` for all available settings.

## Security

By default the chart runs the n8n container as a non-root user and mounts the
root filesystem as read-only with privilege escalation disabled. These settings
are defined in `podSecurityContext` and `securityContext` in `values.yaml` and
can be adjusted if needed.

## Updating n8n versions

When a new n8n release is published, bump the `appVersion` field in
`Chart.yaml` and update the default `image.tag` in `values.yaml` to match.

## CPU and memory settings

The chart ships with minimal resource requests and limits suitable for test
deployments. For production workloads increase the values under the
`resources` block in your `values.yaml` file or via command line flags. For
example:

```bash
helm install my-n8n n8n/n8n \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi \
  --set resources.limits.cpu=1 \
  --set resources.limits.memory=1Gi
```
