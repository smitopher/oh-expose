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
