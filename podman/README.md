# Podman Deployment

Sample configuration for running OpenHAB, Keycloak, Postgres, pgAdmin, Nginx, and Cloudflare Tunnel with Podman and systemd quadlet units.

## Usage

1. Create network and volumes:
   ```bash
   ./create-resources.sh
   ```
2. Copy quadlet files in `quadlet/` to `/etc/containers/systemd/` (or the user equivalent) and run:
   ```bash
   systemctl daemon-reload
   systemctl enable --now nginx.service keycloak.service postgres.service pgadmin.service
   ```
3. Install `cloudflared` via apt, place `cloudflared/config.yml` at `/etc/cloudflared/config.yml`, and start the tunnel:
   ```bash
   sudo systemctl enable --now cloudflared
   ```
4. Mount your Let's Encrypt certificates at `/etc/letsencrypt` on the host so they are available to the Nginx container.
5. Update placeholders such as database passwords, tunnel ID, and Cloudflare token before starting the services.
6. Import `keycloak/realm-export.json` into Keycloak to preconfigure clients and WebAuthn policy.
