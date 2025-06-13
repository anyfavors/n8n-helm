# n8n Helm Chart
[![Lint](https://github.com/n8n-io/n8n-helm/actions/workflows/lint.yaml/badge.svg)](https://github.com/n8n-io/n8n-helm/actions/workflows/lint.yaml)


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

## Ingress

To expose n8n using a Kubernetes ingress controller, enable the `ingress` block in your values and provide host and path information:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: n8n.example.com
      paths:
        - path: /
          pathType: Prefix
```

If your cluster does not provide a default ingress class, ensure `ingress.className` matches your ingress controller.

TLS certificates can be configured via the `ingress.tls` section. When using [cert-manager](https://cert-manager.io/), reference the secret created for your certificate:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: n8n.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: n8n-tls
      hosts:
        - n8n.example.com
```
## Persistence

Set `persistence.enabled` to `true` to store workflows and other n8n data on a persistent volume. The claim size and storage class can be adjusted with the `size` and `storageClass` values. Data is mounted at `/home/node/.n8n` inside the pod.

```yaml
persistence:
  enabled: true
  size: 8Gi
  storageClass: standard
```


The chart also includes a `values.schema.json` file that defines the allowed structure of `values.yaml`. Helm uses this schema to validate any custom values supplied during installation or upgrades.

## Connecting to an external PostgreSQL database

To use an external database instead of the default SQLite storage you can
provide the connection details in `values.yaml`:

```yaml
database:
  host: postgres.example.com
  port: 5432
  user: n8n
  password: mysecret

# Additional environment variables required by n8n
extraEnv:
  - name: DB_TYPE
    value: postgresdb
  - name: DB_POSTGRESDB_DATABASE
    value: n8n
```
## License

This project is licensed under the [MIT License](LICENSE).
