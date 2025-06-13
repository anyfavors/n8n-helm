# n8n Helm Chart
[![Lint](https://github.com/n8n-io/n8n-helm/actions/workflows/lint.yaml/badge.svg)](https://github.com/n8n-io/n8n-helm/actions/workflows/lint.yaml)


This repository contains a Kubernetes Helm chart for deploying [n8n](https://github.com/n8n-io/n8n), an extendable workflow automation tool. The chart is located in the `n8n/` directory.

## Usage

```bash
helm install my-n8n ./n8n
```

You can customise the deployment by editing the values in `n8n/values.yaml` or by supplying your own values file.


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

