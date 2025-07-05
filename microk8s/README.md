# OpenHAB on microk8s

This directory contains Kubernetes manifests to deploy OpenHAB and a few
supporting applications on a local [microk8s](https://microk8s.io/) cluster.

## Components

- **OpenHAB** – home automation platform
- **Mosquitto** – MQTT broker
- **InfluxDB** – time-series database
- **Grafana** – dashboard for visualization

Persistent storage is provided via `PersistentVolumeClaim`s. NodePort services
expose the OpenHAB and Grafana web interfaces. Mosquitto and InfluxDB are
available via ClusterIP services within the cluster.

## Usage

1. Ensure microk8s is installed and running:
   ```bash
   sudo snap install microk8s --classic
   microk8s status --wait-ready
   ```
2. Enable the necessary add-ons **one at a time** so microk8s has a chance to
   configure each component:
   ```bash
   microk8s enable cert-manager
   microk8s enable dashboard
   microk8s enable hostpath-storage
   microk8s enable rbac
   microk8s enable registry
   microk8s enable observability
   ```
3. Deploy the manifests:
   * Directly with `kubectl`:
     ```bash
     microk8s kubectl apply -k manifests
     ```
   * Using [Argo CD](https://argo-cd.readthedocs.io/):
     ```bash
     microk8s kubectl apply -f argocd-app.yaml
     ```
4. Access services:
   - OpenHAB: <http://NODE_IP:30080>
   - Grafana: <http://NODE_IP:30300>

Replace `NODE_IP` with the IP address of your microk8s host.
