#!/bin/sh 

# --- System packages ------------------------------------------------------ 

apt update && apt install -y nodejs npm 
node_version=$(node -v) 
if [ -z "$node_version" ]; then 
    echo "Node.js installation failed." 
else 
    echo "Node.js $node_version is installed." 
fi 

npm_version=$(npm -v) 
if [ -z "$npm_version" ]; then 
    echo "npm installation failed." 
else 
    echo "npm $npm_version is installed." 
fi 

# --- Fetch the artifact ---------------------------------------------------- 

if [ -f "bootcamp-node-envvars-project-1.0.0.tgz" ]; then 
    echo "Package already downloaded." 
else 
    echo "Downloading package..." 
    curl -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz 
fi 

# --- Service user ---------------------------------------------------------- 

id <user> exits # non-zero when the user is missing, so this stays idempotent on re-runs. 
SERVICE_USER="myapp" 
if ! id "$SERVICE_USER" >/dev/null 2>&1; then 
    echo "Creating service user $SERVICE_USER..." 
    useradd --system --no-create-home --shell /usr/sbin/nologin "$SERVICE_USER" 
fi 

# --- Deploy to a location the service user can actually reach --------------- 

APP_DIR="/opt/node-envvars" 
LOG_DIR="$APP_DIR/logs" 

mkdir -p "$APP_DIR" 

echo "Extracting package to $APP_DIR..." 

tar -xzf bootcamp-node-envvars-project-1.0.0.tgz -C "$APP_DIR" --strip-components=1 

mkdir -p "$LOG_DIR" 

chown -R "$SERVICE_USER":"$SERVICE_USER" "$APP_DIR" 

echo "Installing dependencies as $SERVICE_USER..." 

sudo -u "$SERVICE_USER" sh -c "cd '$APP_DIR' && npm install" 

# --- Run the app ----------------------------------------------------------- 

APP_ENV="dev" 
DB_USER="myuser" 
DB_PWD="mysecret" 

echo "Starting the server as $SERVICE_USER..." 

sudo -u "$SERVICE_USER" \ APP_ENV="$APP_ENV" \ DB_USER="$DB_USER" \ DB_PWD="$DB_PWD" \ LOG_DIR="$LOG_DIR" \ sh -c "cd '$APP_DIR' && node server.js" & 

sleep 3 

APP_PID=$(pgrep -u "$SERVICE_USER" -f 'node server.js' | head -n 1) 

# --- Report ---------------------------------------------------------------- 

if [ -n "$APP_PID" ]; then 
    echo "Server running as $SERVICE_USER with PID $APP_PID" 
    APP_PORT=$(netstat -ltnp 2>/dev/null | grep "$APP_PID/" | awk '{print $4}' | grep -oE '[0-9]+$') 
    echo "App is listening on port $APP_PORT" 
else 
    echo "No app PID found — server didn't start. Check output above or logs in $LOG_DIR." 
fi