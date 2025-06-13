# n8n Helm Chart

This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Installation

Add the chart repository and install the release:

```bash
helm repo add n8n https://example.com/charts
helm repo update

# install the chart with the default values
helm install my-n8n n8n/n8n
```

Customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.

### Example value overrides

Override the replica count and image tag directly on the command line:

```bash
helm install my-n8n n8n/n8n \
  --set replicaCount=3 \
  --set image.tag=1.0.0
```

### Enabling ingress

Ingress can be enabled and host names customised using Helm values:

```bash
helm install my-n8n n8n/n8n \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=n8n.example.com \
  --set ingress.hosts[0].paths[0].path=/
```

### Upgrade and uninstall

To upgrade the release when new chart versions are available:

```bash
helm upgrade my-n8n n8n/n8n -f values.yaml
```

To completely remove the deployment:

```bash
helm uninstall my-n8n
```
