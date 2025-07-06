# Kubernetes Dashboard Authentication with Keycloak

These steps configure the MicroK8s Kubernetes Dashboard to use Keycloak as an
OpenID Connect (OIDC) provider. They assume you already have a running Keycloak
instance and a MicroK8s cluster.

## 1. Enable the Dashboard

```bash
microk8s enable dashboard
```

## 2. Configure OIDC in the API Server

Stop MicroK8s and edit the API server arguments:

```bash
sudo microk8s stop
sudo vi /var/snap/microk8s/current/args/kube-apiserver
```

Add the following flags, adjusting the issuer URL and realm name for your
Keycloak installation:

```
--oidc-issuer-url=https://<keycloak-domain>/realms/<realm-name>
--oidc-client-id=kubernetes
--oidc-username-claim=preferred_username
--oidc-groups-claim=groups
```

Restart MicroK8s:

```bash
sudo microk8s start
```

## 3. Create a Client in Keycloak

1. In your realm, create a new client:
   - **Client ID**: `kubernetes`
   - **Protocol**: `openid-connect`
   - **Access Type**: `confidential`
   - **Valid Redirect URIs**: `https://<kube-apiserver>:<port>/*`
2. Define user groups in Keycloak that correspond to your desired Kubernetes
   RBAC roles.

## 4. Map RBAC Roles in Kubernetes

Create a role or cluster role binding referencing the Keycloak group. Example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: keycloak-admins
subjects:
- kind: Group
  name: admins # Matches Keycloak group
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
microk8s kubectl apply -f rbac-keycloak.yaml
```

## 5. Authenticate and Access the Dashboard

Users log into Keycloak and obtain a JWT token. This token can be pasted into
the Dashboard login screen under the **Token** option.

## Optional: Single Sign-On

For a smoother experience you can deploy `oauth2-proxy` in front of the
Dashboard. Configure it to use Keycloak as the provider and expose the
Dashboard through an Ingress that routes traffic via `oauth2-proxy`. Users will
be redirected to Keycloak for authentication and then returned to the Dashboard
with a session cookie.
