# n8n Helm Chart

This directory contains the Helm chart for deploying [n8n](https://n8n.io), an extendable workflow automation tool.
Refer to the [changelog](../CHANGELOG.md) for release notes.

## Quick start

Add the chart repository and install the release:

```bash
helm repo add n8n https://anyfavors.github.io/n8n-helm
helm repo update

# install the chart with the default values
helm install my-n8n n8n/n8n --namespace my-n8n --create-namespace
```
All examples install into the `my-n8n` namespace which you can change as needed.

Customise the deployment by supplying your own `values.yaml` or overriding settings on the command line.

## Common configuration options

- **replicaCount** – number of pods to run.
- **image.tag** – n8n container image tag to deploy.
- **ingress.enabled** – expose the service using an ingress resource.
- **persistence.enabled** – store workflows on a persistent volume using a StatefulSet.
- **persistence.existingClaim** – mount an existing PersistentVolumeClaim.
- **persistence.accessModes** – list of access modes for the persistent volume claim.
- **networkPolicy.enabled** – create a NetworkPolicy to restrict traffic (disabled by default).
- **pdb.enabled** – create a PodDisruptionBudget for the deployment.
- **rbac.create** – create Role and RoleBinding resources.
- **serviceAccount.create** – create a ServiceAccount when `rbac.create` is enabled.
- **service.sessionAffinity** – session affinity policy for the service.
- **database.host** – connect to an external PostgreSQL database instead of the built in SQLite storage.
- **postgresql.enabled** – deploy a PostgreSQL database as part of the release.
- **encryptionKeySecret.name** – Kubernetes secret providing `N8N_ENCRYPTION_KEY`.
- **generateEncryptionKey** – automatically create a secret with a random encryption key.
- **generateDatabasePassword** – automatically create a secret with a random database password.
- **runners.enabled** – enable task runners to process executions.
- **webhookUrl** – external URL for webhook callbacks.
- **extraEnv** – additional environment variables passed to the container.
- **extraSecrets** – mount additional Secrets inside the pod.
- **extraConfigMaps** – mount additional ConfigMaps inside the pod.
- **initContainers** – additional init containers executed before the main pod.
- **extraContainers** – additional containers running alongside the main pod.
- **command** – override the container entrypoint.
- **args** – container arguments passed to the command.
- **lifecycle** – container lifecycle hooks such as preStop and postStart.
- **resources** – CPU and memory requests/limits. Defaults are conservative and
  should be tuned for production installations.

See `values.yaml` for all available settings.

## Security

By default the chart runs the n8n container as a non-root user and mounts the
root filesystem as read-only with privilege escalation disabled. These settings
are defined in `podSecurityContext` and `securityContext` in `values.yaml` and
can be adjusted if needed.

Recommended security values:

- `podSecurityContext.runAsUser`: `1000`
- `podSecurityContext.runAsGroup`: `1000`
- `podSecurityContext.fsGroup`: `1000`
- `podSecurityContext.fsGroupChangePolicy`: `OnRootMismatch`
- `podSecurityContext.seccompProfile.type`: `RuntimeDefault`

Automatic mounting of the ServiceAccount token is disabled via
`serviceAccount.automount` to limit access to the Kubernetes API and reduce the
attack surface.

The chart can also manage Pod Security Admission labels on the release
namespace. Specify the desired levels under the `podSecurity` block:

```yaml
podSecurity:
  enforce: restricted
  audit: restricted
  warn: restricted
```

## Updating n8n versions

When a new n8n release is published, bump the `appVersion` field in
`Chart.yaml` and update the default `image.tag` in `values.yaml` to match.

## CPU and memory settings

The chart ships with minimal resource requests and limits suitable for small
installations. The [official n8n docs](https://docs.n8n.io/) suggest the
following starting points:

- **Start**: 320Mi memory and 10m CPU
- **Pro (10k executions)**: 640Mi memory and 20m CPU
- **Pro (50k executions)**: 1280Mi memory and 80m CPU

Increase the values under the `resources` block in your `values.yaml` file or
override them on the command line for production workloads. For example:

```bash
helm install my-n8n n8n/n8n --namespace my-n8n --create-namespace \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi \
  --set resources.limits.cpu=1 \
  --set resources.limits.memory=1Gi
```

## Webhook URL example

Specify an external URL for webhook callbacks using `webhookUrl`:

```yaml
webhookUrl: https://my-n8n.example.com/
```

## Extra containers example

Additional sidecars can be defined via `extraContainers`:

```yaml
extraContainers:
  - name: sidecar
    image: busybox
    command: ["sh", "-c", "echo sidecar"]
```

## Network policy example

Enable `networkPolicy` to restrict traffic and define ingress/egress rules:

```yaml
networkPolicy:
  enabled: true
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: my-namespace
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
```

## Publishing

Chart packages are created automatically using [chart-releaser](https://github.com/helm/chart-releaser) when commits land on `main`.
Before the first release, create a `gh-pages` branch in the repository and configure GitHub Pages to serve from it (the branch can start with an empty `index.yaml`).
To cut a release, bump the version in `Chart.yaml` and push the change. The [`release.yaml`](../.github/workflows/release.yaml) workflow will upload the packaged chart to GitHub and update the index on `gh-pages`.
Users can then add <https://anyfavors.github.io/n8n-helm> as a Helm repository to install published versions.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| command | list | `[]` |  |
| database.database | string | `""` |  |
| database.host | string | `""` |  |
| database.password | string | `""` |  |
| database.passwordSecret.key | string | `"password"` |  |
| database.passwordSecret.name | string | `""` |  |
| database.port | int | `5432` |  |
| database.user | string | `""` |  |
| encryptionKeySecret.key | string | `"encryptionKey"` |  |
| encryptionKeySecret.name | string | `""` |  |
| extraConfigMaps | list | `[]` |  |
| extraContainers | list | `[]` |  |
| extraEnv[0].name | string | `"N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"` |  |
| extraEnv[0].value | string | `"true"` |  |
| extraSecrets | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| generateDatabasePassword | bool | `false` |  |
| generateEncryptionKey | bool | `true` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"n8nio/n8n"` |  |
| image.tag | string | `"1.99.1"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| initContainers | list | `[]` |  |
| lifecycle | object | `{}` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| metrics.annotations | object | `{}` |  |
| metrics.enabled | bool | `false` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.port | int | `5678` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| nameOverride | string | `""` |  |
| networkPolicy.egress | list | `[]` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress | list | `[]` |  |
| networkPolicy.policyTypes[0] | string | `"Ingress"` |  |
| networkPolicy.policyTypes[1] | string | `"Egress"` |  |
| nodeSelector | object | `{}` |  |
| pdb.enabled | bool | `false` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.size | string | `"8Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podAntiAffinity.hard | list | `[]` |  |
| podAntiAffinity.soft | list | `[]` |  |
| podLabels | object | `{}` |  |
| podSecurity.audit | string | `""` |  |
| podSecurity.enforce | string | `""` |  |
| podSecurity.warn | string | `""` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| podSecurityContext.runAsGroup | int | `1000` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| postgresql.auth.database | string | `"n8n"` |  |
| postgresql.auth.existingSecret | string | `""` |  |
| postgresql.auth.username | string | `"n8n"` |  |
| postgresql.enabled | bool | `false` |  |
| rbac.create | bool | `false` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"250m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"256Mi"` |  |
| runners.enabled | bool | `true` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `5678` |  |
| service.sessionAffinity | string | `"None"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `false` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| strategy.maxSurge | string | `"25%"` |  |
| strategy.maxUnavailable | string | `"25%"` |  |
| strategy.type | string | `"RollingUpdate"` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |
| webhookUrl | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
