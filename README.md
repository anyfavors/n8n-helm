# n8n Helm Chart

This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Usage

```bash
helm install my-n8n ./n8n
```

You can customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.

The chart also includes a `values.schema.json` file that defines the allowed structure of `values.yaml`. Helm uses this schema to validate any custom values supplied during installation or upgrades.
