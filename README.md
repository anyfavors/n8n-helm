# n8n Helm Chart
[![Lint](https://github.com/anyfavors/n8n-helm/actions/workflows/lint.yaml/badge.svg)](https://github.com/anyfavors/n8n-helm/actions/workflows/lint.yaml)


This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.
See [n8n/README.md](n8n/README.md) for a quick start guide and common configuration options.
See [CHANGELOG.md](CHANGELOG.md) for release notes.


## Installation

Add the chart repository and install the release:

```bash
helm repo add n8n https://anyfavors.github.io/n8n-helm
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

### Example using cert-manager

Annotate the ingress with your issuer to have cert-manager obtain the
certificate automatically:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
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

Create the ClusterIssuer itself:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: you@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt
    solvers:
      - http01:
          ingress:
            class: nginx
```

Optionally use a hook Job to apply a Certificate after installation:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: n8n-cert-provision
  annotations:
    helm.sh/hook: post-install
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: kubectl
          image: bitnami/kubectl:latest
          command: ["kubectl", "apply", "-f", "/manifests/certificate.yaml"]
```
## Service types

Set `service.type` to expose n8n using a Kubernetes LoadBalancer or NodePort service.

Example using a LoadBalancer:

```bash
helm install my-n8n n8n/n8n \
  --set service.type=LoadBalancer
```

Watch for the external IP to appear:

```bash
kubectl get svc --namespace default -w my-n8n
```

Example using a NodePort:

```bash
helm install my-n8n n8n/n8n \
  --set service.type=NodePort
```

Retrieve the address:

```bash
NODE_PORT=$(kubectl get svc --namespace default my-n8n -o jsonpath="{.spec.ports[0].nodePort}")
NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

## Persistence

Set `persistence.enabled` to `true` to deploy a StatefulSet that stores workflows and other n8n data on a persistent volume. The claim size and storage class can be adjusted with the `size` and `storageClass` values, or supply `existingClaim` to mount a pre-created PersistentVolumeClaim. Data is mounted at `/home/node/.n8n` inside the pod.

```yaml
persistence:
  enabled: true
  size: 8Gi
  storageClass: standard
  existingClaim: my-data
```

Install with these settings from the command line:

```bash
helm install my-n8n n8n/n8n \
  --set persistence.enabled=true \
  --set persistence.size=8Gi \
  --set persistence.storageClass=standard
```


The chart also includes a `values.schema.json` file that defines the allowed structure of `values.yaml`. Helm uses this schema to validate any custom values supplied during installation or upgrades.

## Network policies

`networkPolicy.enabled` defaults to `true`, creating a `NetworkPolicy` that
denies all ingress and egress traffic. Extend the policy under
`networkPolicy.ingress` and `networkPolicy.egress` to permit connections.
Disable the policy entirely by setting `networkPolicy.enabled=false`.

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

## Pod Security Standards

The chart runs n8n with a non-root user, drops all capabilities and mounts the
root filesystem read-only. These defaults align with the "restricted" Pod
Security Standard. To enforce this profile on your namespace add the
`pod-security.kubernetes.io/*` labels:

```bash
kubectl label --overwrite namespace my-n8n \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

Alternatively, apply the labels via a manifest:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-n8n
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

You can also have the chart manage these labels automatically by setting the
`podSecurity` values at install time:

```bash
helm install my-n8n n8n/n8n \
  --set podSecurity.enforce=restricted \
  --set podSecurity.audit=restricted \
  --set podSecurity.warn=restricted
```

## Pod disruption budgets

Create a PodDisruptionBudget to control the number of pods that may be
voluntarily evicted at once. Enable the budget and specify either
`pdb.minAvailable` or `pdb.maxUnavailable`:

```bash
helm install my-n8n n8n/n8n \
  --set pdb.enabled=true \
  --set pdb.minAvailable=1
```


## Role-based access control

Enable creation of a Role and RoleBinding for the service account by setting `rbac.create`:

```bash
helm install my-n8n n8n/n8n \
  --set rbac.create=true
```

## CPU and memory

The chart ships with minimal CPU and memory requests and limits suitable for
small installations. According to the [official n8n documentation](https://docs.n8n.io/),
typical starting points are:

- **Start**: 320Mi memory and 10m CPU
- **Pro (10k executions)**: 640Mi memory and 20m CPU
- **Pro (50k executions)**: 1280Mi memory and 80m CPU

Increase these values for larger workloads by editing the `resources` block in
`values.yaml` or overriding them on the command line:

```bash
helm install my-n8n n8n/n8n \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi \
  --set resources.limits.cpu=1 \
  --set resources.limits.memory=1Gi
```

## Autoscaling

Set `autoscaling.enabled` to `true` to create a HorizontalPodAutoscaler using
the manifest in [n8n/templates/hpa.yaml](n8n/templates/hpa.yaml). Configure
`minReplicas` and `maxReplicas` to control the scaling range and optionally set
`targetCPUUtilizationPercentage` or `targetMemoryUtilizationPercentage` for
resource based scaling.

Example enabling the autoscaler:

```bash
helm install my-n8n n8n/n8n \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=5 \
  --set autoscaling.targetCPUUtilizationPercentage=70
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
helm install my-n8n n8n/n8n \
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
helm install my-n8n n8n/n8n \
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
helm install my-n8n n8n/n8n \
  --set extraSecrets[0].name=my-secret \
  --set extraSecrets[0].mountPath=/etc/secret \
  --set extraConfigMaps[0].name=my-config \
  --set extraConfigMaps[0].mountPath=/etc/config
```
## Publishing

Chart releases are handled automatically by [chart-releaser](https://github.com/helm/chart-releaser).
To publish a new version:

1. Ensure a branch named `gh-pages` exists in the repository and configure GitHub Pages to use it. The branch can start with an empty `index.yaml` file.
2. Update the `version` (and optionally `appVersion`) fields in `n8n/Chart.yaml`.
3. Record the changes in `CHANGELOG.md`.
4. Commit the change to the `main` branch.
5. Push the commit to GitHub. The [`release.yaml`](.github/workflows/release.yaml) workflow packages the chart from the `n8n` directory and uploads it to a GitHub release.
6. Once the workflow completes, the repository index on the `gh-pages` branch is updated at <https://anyfavors.github.io/n8n-helm>.

## Verifying chart signatures

Chart packages are signed using [cosign](https://docs.sigstore.dev/cosign/overview/). The corresponding `cosign.pub` public key is attached to each GitHub release.

Download `cosign.pub` from the release assets and verify a package with:

```bash
cosign verify-blob --key cosign.pub --signature n8n-<version>.tgz.sig n8n-<version>.tgz
```

## License

This project is licensed under the [MIT License](LICENSE).
