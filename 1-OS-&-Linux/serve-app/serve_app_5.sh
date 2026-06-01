#!/bin/sh

apt update
apt install -y nodejs npm

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

if [ -f "bootcamp-node-envvars-project-1.0.0.tgz" ]; then
    echo "Package already downloaded."
else
    echo "Downloading package..."
    curl -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz
fi

echo "Extracting package and starting server..."
tar -xzf bootcamp-node-envvars-project-1.0.0.tgz

LOG_DIR="$(pwd)/logs"
mkdir -p "$LOG_DIR"

# Set environment variables for the application - would optimally be done in a .env file or similar in a real application
export APP_ENV="dev"
export DB_USER="myuser"
export DB_PWD="mysecret"
export LOG_DIR="$LOG_DIR"

cd package
npm install
node server.js &

APP_PID=$!
echo "Server started with PID $APP_PID"

sleep 3

APP_PORT=$(netstat -ltnp 2>/dev/null | grep "$APP_PID/" | awk '{print $4}' | grep -oE '[0-9]+$')
echo "App is listening on port $APP_PORT"
