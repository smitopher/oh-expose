# oh-expose

This repository contains configuration to deploy [OpenHAB](https://www.openhab.org/)
and supporting applications on a local [microk8s](https://microk8s.io/) cluster.
The manifests are located in [`microk8s/manifests`](microk8s/manifests).

## Getting Started

1. Install microk8s and ensure it is running.
2. Enable the following add-ons **one at a time**:
   `cert-manager`, `dashboard`, `hostpath-storage`, `rbac`, `registry`, and
   `observability`.
3. Deploy the manifests using `microk8s kubectl` or apply the
   provided Argo CD application (`microk8s/argocd-app.yaml`).

See [`microk8s/README.md`](microk8s/README.md) for detailed instructions.
