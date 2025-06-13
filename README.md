# n8n Helm Chart

This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Usage

```bash
helm install my-n8n ./n8n
```

You can customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.

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
