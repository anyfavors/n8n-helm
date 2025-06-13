# n8n Helm Chart

This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Usage

```bash
helm install my-n8n ./n8n
```

You can customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.

## Persistence

Set `persistence.enabled` to `true` to store workflows and other n8n data on a persistent volume. The claim size and storage class can be adjusted with the `size` and `storageClass` values. Data is mounted at `/home/node/.n8n` inside the pod.

```yaml
persistence:
  enabled: true
  size: 8Gi
  storageClass: standard
```
