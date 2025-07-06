# oh-expose

This repository contains configuration to deploy [OpenHAB](https://www.openhab.org/)
and supporting applications (Mosquitto, InfluxDB, PostgreSQL, Keycloak and
HashiCorp Vault) on a local [microk8s](https://microk8s.io/) cluster. Their
operators are installed through the Operator Lifecycle Manager (OLM), which
must be installed manually. The
deployment is packaged as a Helm chart under [`microk8s/charts/openhab-stack`](microk8s/charts/openhab-stack).

## Getting Started

1. Install microk8s and ensure it is running.
2. Symlink the microk8s Helm client so the `helm` command is available:
   ```bash
   sudo ln -s $(which microk8s.helm) /usr/local/bin/helm
   ```
3. Enable the following add-ons **one at a time**:
   - `cert-manager` – manages TLS certificates
   - `dashboard` – provides the Kubernetes dashboard web UI
   - `hostpath-storage` – basic persistent volume support
   - `rbac` – enables role-based access control
   - `registry` – local container image registry
   - `ingress` – NGINX Ingress controller for exposing services
   - `observability` – Prometheus/Grafana stack for metrics
4. Install the Operator Lifecycle Manager manually, as microk8s does not provide an OLM add-on. Follow the [OLM installation guide](https://github.com/operator-framework/operator-lifecycle-manager#installing-olm).
5. Deploy the stack with Helm or use the provided Argo CD Application:
   ```bash
   helm install openhab-stack microk8s/charts/openhab-stack
   ```
   Alternatively apply `microk8s/argocd-app.yaml` if using Argo CD.

See [`microk8s/README.md`](microk8s/README.md) for detailed instructions.
