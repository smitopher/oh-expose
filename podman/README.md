# Podman Deployment

This directory contains a sample Podman configuration for running
OpenHAB together with supporting services such as Keycloak, Postgres,
pgAdmin, optional Nginx reverse proxy, and a Cloudflare Tunnel.  The
services are managed with
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
   sudo systemctl enable --now keycloak.service postgres.service
   # Optional services if you also want Nginx or pgAdmin
   sudo systemctl enable --now nginx.service pgadmin.service
   ```

3. **Configure the Cloudflare tunnel**

   Install `cloudflared` via `apt`, create a new tunnel in your
   Cloudflare account, and place an updated copy of
   `cloudflared/config.yml` at `/etc/cloudflared/config.yml`. The sample
   configuration routes `keycloak.cjssolutions.com` directly to the
   Keycloak container listening on port 8080. Review the active
   configuration and credentials to confirm they match your tunnel:

   ```bash
   sudo cat /etc/cloudflared/config.yml
   sudo ls /etc/cloudflared/*.json
   ```

   When the service has been disabled previously, re-enable it after the
   configuration is updated:

   ```bash
   sudo systemctl enable --now cloudflared
   sudo systemctl status cloudflared
   ```

4. **Provide TLS certificates (optional)**

   If you plan to run the Nginx or pgAdmin containers, mount your Let's
   Encrypt or mkcert certificates at `/etc/letsencrypt` on the host so
   they are available to those services. Keycloak can be exposed through
   Cloudflare without Nginx by using the HTTP origin in the tunnel
   configuration.

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

## Expose Keycloak with Cloudflare (no Nginx)

If only the Keycloak container is running, you can publish it directly
through a Cloudflare Tunnel:

1. Create a DNS record such as `keycloak.cjssolutions.com` that points to
   the tunnel you created for Keycloak.
2. Copy `cloudflared/config.yml` to `/etc/cloudflared/config.yml` and
   replace the placeholder tunnel ID and credentials file name with the
   values from your Cloudflare account. The provided example maps the
   hostname straight to `http://keycloak:8080` on the Podman network.
3. Start (or restart) the `cloudflared` service. External requests will
   be proxied from Cloudflare to the Keycloak container without the
   intermediate Nginx layer.

## End-to-End HTTPS via Nginx

If you prefer to terminate TLS with Nginx before requests reach other
services, keep the Nginx container running and update the tunnel
configuration accordingly:

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
