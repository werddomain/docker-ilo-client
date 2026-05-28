# docker-ilo-client
Firefox client to HP ILO server

## Quick Start (docker-compose)

### 1. Download Java 1.5

Download the required legacy Java runtime: `jre-1_5_0_11-linux-i586.bin` from the internet (e.g. Oracle Archives or Archive.org) and place it in the root of this project folder, next to the `Dockerfile`.

### 2. Configure environment

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

### 2. Custom CA Certificates

Create an `app-data` folder in the project root and place your CA certificates (with a `.crt` extension, for example `homelabCA.crt`) inside it. The entire folder is mounted into the container at `/app-data/`, and all `.crt` files found will be installed as trusted CAs at startup.

```bash
mkdir app-data
cp /path/to/your/homelabCA.crt app-data/
```

### 3. Set up Basic Auth password

Generate an htpasswd file for the web VNC client. 

**Note for Windows/PowerShell users:** If your password contains a `$` (like `$Cmgrr4p8tb`), you must wrap it in single quotes so PowerShell doesn't treat it as a variable.

```bash
# Using Docker (outputs directly to htpasswd file)
docker run --rm httpd:alpine htpasswd -n -b admin 'YOUR_PASSWORD' > htpasswd
```

### 4. Start the stack

```bash
docker compose up -d
```

Access the VNC web client at **http://localhost:8443** (protected by the password you set above).

> To expose the VNC port directly (without the web client), uncomment the `ports` section on the `ilo-client` service in `docker-compose.yml`.

---

## Run standalone (without docker-compose)

```bash
docker run --rm --name ilo-client -p 5900:5900 \
  -v ./app-data:/app-data/ \
  -e HILO_HOST=https://ADDRESS_OF_YOUR_HOST \
  -e HILO_USER=SOME_USERNAME \
  -e HILO_PASS=SOME_PASSWORD \
  sshnaidm/docker-ilo-client
```

Then run any VNC client and point it to `vnc://localhost:5900`


