# n8n Helm Chart

This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Usage

```bash
helm install my-n8n ./n8n
```

You can customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.
### Resource configuration

You can set CPU and memory requests and limits by adjusting the `resources` section in `n8n/values.yaml`. By default it is empty (`resources: {}`). Remove the braces and specify your desired values.

Low-resource example:
```yaml
resources:
  limits:
    cpu: 100m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 256Mi
```

Production example:
```yaml
resources:
  limits:
    cpu: 1
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 1Gi
```

