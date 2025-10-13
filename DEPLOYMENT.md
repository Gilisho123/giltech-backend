Quick deployment guide

This repo contains a Node.js Express backend (`giltech-backend`) and a static frontend in the `GIL` folder.

Options to create a live link (pick one):

1) Render (recommended, easy)
- Create a new Web Service on Render.
- Connect your GitHub repo.
- Set the build and start commands (no build step needed):
  - Build command: (leave blank)
  - Start command: `node server.js`
- Set environment variables: `DATABASE_URL` or the usual MySQL envs (DB_HOST, DB_USER, DB_PASS, DB_NAME), `JWT_SECRET`, optionally `ADMIN_TOKEN`.
- Deploy. Render will give you a public URL.

2) Railway
- Create a new project, connect repo, set the start command to `node server.js`.
- Add a MySQL plugin or provide connection envs.

3) Docker (deploy anywhere)
- Build:
  docker build -t giltech-backend .
- Run (example):
  docker run -p 5000:5000 -e DB_HOST=... -e DB_USER=... -e DB_PASS=... -e DB_NAME=... -e JWT_SECRET=... giltech-backend

4) Heroku (legacy) or use the included Procfile.

Notes:
- Ensure your MySQL instance is reachable from the deployment environment and the `create_users.sql` migration is executed.
- For quick testing, you can also run locally and use ngrok to expose a live link:
  ngrok http 5000

If you tell me which provider you'd like (Render/Railway/Docker/ngrok), I can produce exact step-by-step commands and a small `render.yaml` or `docker-compose.yml` if you prefer.


---

## Docker Compose quickstart (local)

Copy the example env file and start the services (PowerShell):

```powershell
cp .env.compose .env
docker compose --env-file .env up --build
```

If `cp` isn't available on your system, use:

```powershell
Copy-Item .env.compose -Destination .env
```

To run the migration after the containers are up:

```powershell
# find the app container name
docker ps
# then exec into the app container and run the migration
docker exec -it <app_container_name> node scripts/run_create_users.js
```

Replace `<app_container_name>` with the name shown by `docker ps` (for example `giltech-backend_app_1`).

### Creating an admin user (HTTP helper)

If you don't want to run SQL manually you can create an admin user using the built-in admin tools route. This requires setting an environment variable `ADMIN_TOOL_TOKEN` to a secret value (only set it temporarily).

Example (PowerShell) after containers are up and `.env` includes ADMIN_TOOL_TOKEN:

```powershell
# create admin (replace token/email/password values)
curl -X POST http://localhost:5000/api/admin-tools/create-admin -H "Content-Type: application/json" -d '{"token":"my-secret-token","email":"admin@giltech.local","password":"ChangeMe@1234"}'
```

After creating the admin, remove `ADMIN_TOOL_TOKEN` from your env to disable the endpoint.

---

## Mapping a custom domain: www.giltechonlinecyber.co.ke

You can map your domain to the app after deploying. Below are two common options: Render (managed) or a VM/managed server.

1) Using Render (recommended for simplicity)

- Create a Web Service using `render.yaml` or through the Render UI and deploy your repo.
- In the Render dashboard, go to the service -> Settings -> Custom Domains -> Add Custom Domain.
- Add `www.giltechonlinecyber.co.ke`.
- Render will provide a short CNAME record value that you must add to your domain registrar DNS settings. In your DNS provider console, add a CNAME entry:

  Host: www
  Type: CNAME
  Value: <render-provided-cname>

- After DNS propagation (can take up to 24 hours but often much faster), Render will automatically provision HTTPS via Let's Encrypt.

2) Using your own server / VM (e.g., DigitalOcean, AWS EC2)

- Point an A record to your server's public IP:

  Host: @
  Type: A
  Value: <your-server-ip>

  Host: www
  Type: CNAME
  Value: @

- Install and configure a reverse proxy (nginx) to forward port 80/443 to your Node app running on port 5000.
- Use Certbot to obtain a Let's Encrypt certificate for `www.giltechonlinecyber.co.ke` and configure nginx to use it.

DNS tips
- TTL: set to 300 (5 minutes) while testing to speed up propagation.
- Use an online DNS check (e.g., dig, whatsmydns.net) to verify propagation.

Once the domain is pointed correctly and HTTPS is active, users can access the site at:

  https://www.giltechonlinecyber.co.ke

---

## Quick HTTPS demo with ngrok

If you want to test HTTPS immediately without buying DNS or waiting for SSL issuance, use ngrok to expose your local app via HTTPS.

1. Start your app locally (for example with `.
un-local.ps1` or `node server.js`). Ensure it listens on port 5000.
2. Install ngrok from https://ngrok.com/download and add it to your PATH.
3. Run the helper script included in this repo:

```powershell
.\expose-with-ngrok.ps1
```

The script will start ngrok and print an HTTPS public URL (like `https://abcd-12-34-56-78.ngrok.io`). Open it in your browser to test HTTPS and admin functionality.

Note: Using a custom domain with ngrok requires a paid plan; for full production you should map your domain to your hosting provider and configure HTTPS there.


