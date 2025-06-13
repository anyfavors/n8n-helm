# n8n Helm Chart

This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Usage

```bash
helm install my-n8n ./n8n
```

You can customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.

### Example: Mounting credentials from a Secret

Create a secret containing the desired environment variables:

```bash
kubectl create secret generic n8n-secret \
  --from-literal=N8N_BASIC_AUTH_USER=user \
  --from-literal=N8N_BASIC_AUTH_PASSWORD=pass
```

Then reference the secret using `extraEnvFrom` in your values file:

```yaml
extraEnvFrom:
  - secretRef:
      name: n8n-secret
```
