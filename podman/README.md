# Podman Deployment

This directory contains a sample Podman configuration for running
OpenHAB together with supporting services such as Keycloak, Postgres,
pgAdmin, Nginx, and a Cloudflare Tunnel.  The services are managed with
[systemd quadlet](https://docs.podman.io/en/latest/markdown/podman.systemd.unit.html)
units so that each container can be controlled with `systemctl` like a
regular service.

## Get Started

Follow the steps below to stand up the stack on a new host.

1. **Create network and volumes**

   ```bash
   ./create-resources.sh
   ```

2. **Install quadlet units**

   Copy the files in `quadlet/` along with their corresponding `.env`
   files to `/etc/containers/systemd/` (or the user equivalent) and
   reload systemd:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now nginx.service keycloak.service postgres.service pgadmin.service
   ```

3. **Configure the Cloudflare tunnel**

   Install `cloudflared` via `apt`, place `cloudflared/config.yml` at
   `/etc/cloudflared/config.yml`, and start the tunnel:

   ```bash
   sudo systemctl enable --now cloudflared
   ```

4. **Provide TLS certificates**

   Mount your Let's Encrypt or mkcert certificates at `/etc/letsencrypt`
   on the host so they are available to the Nginx, Keycloak, and pgAdmin
   containers.

5. **Adjust configuration**

   Update the values in the `.env` files (database passwords, tunnel ID,
   Cloudflare token, etc.) before starting the services.

6. **Import Keycloak realm**

   Import `keycloak/realm-export.json` into Keycloak to preconfigure
   clients and WebAuthn policy.

## Renewing mkcert Certificates

If you use [mkcert](https://github.com/FiloSottile/mkcert) to create
locally trusted certificates for development, regenerate them
periodically to avoid expiration:

1. Remove the existing certificate and key files from your certificate
   directory.
2. Run `mkcert` again for the desired hostnames. For example:

   ```bash
   mkcert -cert-file nginx/certs/openhab.local.pem \
          -key-file nginx/certs/openhab.local-key.pem \
          openhab.local
   ```

3. Restart the affected services so they load the new certificates.

## End-to-End HTTPS

Secure traffic to OpenHAB and Keycloak by running all requests through a
Cloudflare Tunnel that terminates at the Nginx reverse proxy:

1. Create DNS records in Cloudflare for the desired hostnames and
   configure `cloudflared/config.yml` so each hostname maps to the Nginx
   service over HTTPS.
2. Provide valid certificates for Nginx (for example from Let's Encrypt
   or mkcert) under `/etc/letsencrypt`.
3. In the Cloudflare dashboard set the SSL/TLS mode to **Full (strict)**
   so Cloudflare validates the Nginx certificate.
4. Start the `nginx` and `cloudflared` services. Requests to the public
   hostnames are now encrypted from the client through Cloudflare to
   Nginx.

## OpenHAB with Keycloak Authentication

OpenHAB can delegate authentication to Keycloak using OpenID Connect.

1. Import the provided Keycloak realm and ensure the `openhab` client
   includes your public redirect URI.
2. Configure OpenHAB to use OIDC by pointing it at the Keycloak realm
   (issuer URL, client ID, and client secret). This can be done through
   environment variables or by editing `runtime.cfg`.
3. Restart OpenHAB. Users accessing the UI will be redirected to
   Keycloak to log in before being returned to OpenHAB.
