# OpenHAB on microk8s

This directory contains a Helm chart to deploy OpenHAB and supporting
applications on a local [microk8s](https://microk8s.io/) cluster. Operators are
managed by the Operator Lifecycle Manager (OLM), which must be installed
manually as microk8s does not provide an OLM add-on.

## Components

- **OpenHAB** – home automation platform
- **Mosquitto** – MQTT broker
- **InfluxDB** – time-series database
- **PostgreSQL** – relational database used by OpenHAB
- **Keycloak** – identity and access management
- **HashiCorp Vault** – secrets management
- Operators for PostgreSQL, Keycloak, Vault and InfluxDB (managed by OLM)

Persistent storage is provided via `PersistentVolumeClaim`s. The OpenHAB web
interface is exposed through an Ingress provided by the microk8s `ingress`
add-on while the remaining applications are
available through ClusterIP services. OpenHAB metrics are scraped by
Prometheus via the `ServiceMonitor` in this repository.

## Usage

1. Ensure microk8s is installed and running:
   ```bash
   sudo snap install microk8s --classic
   microk8s status --wait-ready
   ```
1. Symlink the microk8s Helm client so the `helm` command is available:
   ```bash
   sudo ln -s $(which microk8s.helm) /usr/local/bin/helm
   ```
1. Enable the necessary add-ons **one at a time** so microk8s has a chance to
   configure each component:
   ```bash
   microk8s enable cert-manager        # automatic certificate management
   microk8s enable dashboard           # Kubernetes dashboard web UI
   microk8s enable hostpath-storage    # basic persistent volumes
   microk8s enable rbac                # role-based access control
   microk8s enable registry            # local image registry
   microk8s enable ingress             # NGINX Ingress controller
   microk8s enable observability       # Prometheus and Grafana stack
   ```
1. Install the Operator Lifecycle Manager manually. Follow the [OLM installation guide](https://github.com/operator-framework/operator-lifecycle-manager#installing-olm).
1. Deploy the stack with Helm:
   ```bash
   helm install openhab-stack microk8s/charts/openhab-stack
   ```
   Or deploy with [Argo CD](https://argo-cd.readthedocs.io/) using
   `argocd-app.yaml`.
1. Access services:
   - OpenHAB UI: <http://openhab.local>

Map the `openhab.local` hostname to the IP address of your microk8s host or
adjust the Ingress definition with your preferred hostname.

## Securing the Kubernetes Dashboard

MicroK8s ships with the Kubernetes Dashboard add-on. To authenticate against
Keycloak using OIDC, follow the steps in
[dashboard-keycloak.md](dashboard-keycloak.md).
