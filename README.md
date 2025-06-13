# n8n Helm Chart
[![Lint](https://github.com/anyfavors/n8n-helm/actions/workflows/lint.yaml/badge.svg)](https://github.com/anyfavors/n8n-helm/actions/workflows/lint.yaml)


This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.
See [n8n/README.md](n8n/README.md) for a quick start guide and common configuration options.


## Installation

Clone this repository and install the chart from the `n8n` directory:

```bash
git clone https://github.com/anyfavors/n8n-helm.git
cd n8n-helm
helm install my-n8n ./n8n
```

Customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.

### Example value overrides

Override the replica count and image tag directly on the command line:

```bash
helm install my-n8n ./n8n \
  --set replicaCount=3 \
  --set image.tag=1.0.0
```

### Enabling ingress

Ingress can be enabled and host names customised using Helm values:

```bash
helm install my-n8n ./n8n \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=n8n.example.com \
  --set ingress.hosts[0].paths[0].path=/
```

### Upgrade and uninstall

To upgrade the release when new chart versions are available:

```bash
helm upgrade my-n8n ./n8n -f values.yaml
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

Install with these settings from the command line:

```bash
helm install my-n8n ./n8n \
  --set persistence.enabled=true \
  --set persistence.size=8Gi \
  --set persistence.storageClass=standard
```


The chart also includes a `values.schema.json` file that defines the allowed structure of `values.yaml`. Helm uses this schema to validate any custom values supplied during installation or upgrades.

## Network policies

Set `networkPolicy.enabled` to `true` to create a `NetworkPolicy` resource that denies all traffic by default. Custom ingress and egress rules can be added under `networkPolicy.ingress` and `networkPolicy.egress`.

Example enabling the policy from the command line:

```bash
helm install my-n8n ./n8n \
  --set networkPolicy.enabled=true
```

To allow specific traffic, extend the policy in your values file:

```yaml
networkPolicy:
  enabled: true
  ingress:
    - from:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: 5678
  egress: []
```

## Pod disruption budgets

Create a PodDisruptionBudget to control the number of pods that may be
voluntarily evicted at once. Enable the budget and specify either
`pdb.minAvailable` or `pdb.maxUnavailable`:

```bash
helm install my-n8n ./n8n \
  --set pdb.enabled=true \
  --set pdb.minAvailable=1
```


## Role-based access control

Enable creation of a Role and RoleBinding for the service account by setting `rbac.create`:

```bash
helm install my-n8n ./n8n \
  --set rbac.create=true
```

## CPU and memory

The chart sets conservative resource requests and limits. For production
deployments edit the values under the `resources` block in `values.yaml` or
override them on the command line:

```bash
helm install my-n8n ./n8n \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi \
  --set resources.limits.cpu=1 \
  --set resources.limits.memory=1Gi
```

## Connecting to an external PostgreSQL database

To use an external PostgreSQL server instead of the built in SQLite
storage, populate the values under the `database` block. These map
directly to the connection fields:

- `database.host` – address of the database server
- `database.port` – listening port
- `database.user` – database user name
- `database.password` – user password
- `database.passwordSecret.name` – name of a secret containing the password
- `database.passwordSecret.key` – key within the secret (defaults to `password`)
- `database.database` – name of the database to connect to

n8n also requires the following environment variables:

- `DB_TYPE=postgresdb`
- `DB_POSTGRESDB_DATABASE` – should match `database.database`

Example snippet:

```yaml
database:
  host: postgres.example.com
  port: 5432
  user: n8n
  # password: mysecret
  passwordSecret:
    name: n8n-db
    key: password
  database: n8n

extraEnv:
  - name: DB_TYPE
    value: postgresdb
  - name: DB_POSTGRESDB_DATABASE
    value: n8n
```

Or supply the settings on the command line:

```bash
helm install my-n8n ./n8n \
  --set database.host=postgres.example.com \
  --set database.port=5432 \
  --set database.user=n8n \
  --set database.passwordSecret.name=n8n-db \
  --set database.passwordSecret.key=password \
  --set database.database=n8n \
  --set extraEnv[0].name=DB_TYPE \
  --set extraEnv[0].value=postgresdb \
  --set extraEnv[1].name=DB_POSTGRESDB_DATABASE \
  --set extraEnv[1].value=n8n
```

## Credential encryption

Generate a 256‑bit key and store it in a secret to encrypt credentials:

```bash
kubectl create secret generic n8n-key \
  --from-literal=encryptionKey=$(openssl rand -hex 32)
```

Reference the secret in your values:

```yaml
encryptionKeySecret:
  name: n8n-key
  key: encryptionKey
```

Or set it on the command line:

```bash
helm install my-n8n ./n8n \
  --set encryptionKeySecret.name=n8n-key
```

## Mounting additional Secrets and ConfigMaps

Existing Kubernetes resources can be mounted using the `extraSecrets` and
`extraConfigMaps` values:

```yaml
extraSecrets:
  - name: my-secret
    mountPath: /etc/secret
extraConfigMaps:
  - name: my-config
    mountPath: /etc/config
```

Install with command line flags:

```bash
helm install my-n8n ./n8n \
  --set extraSecrets[0].name=my-secret \
  --set extraSecrets[0].mountPath=/etc/secret \
  --set extraConfigMaps[0].name=my-config \
  --set extraConfigMaps[0].mountPath=/etc/config
```
## License

This project is licensed under the [MIT License](LICENSE).
