#!/bin/bash

# Default values
PORT=8080
PASSWORD="password"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --port)
            PORT="$2"
            shift
            ;;
        --password)
            PASSWORD="$2"
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

#########################################
# Start Code-Server
#########################################
echo "Starting Code-Server ..."
# Create the config.yaml file for code-server
CONFIG_DIR="$HOME/.config/code-server"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<EOL
bind-addr: 0.0.0.0:$PORT
auth: password
password: $PASSWORD
cert: false
EOL

# Ensure Homebrew is in the PATH for the current session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Start Code-Server in the background and log its output
CODE_SERVER_LOG="/tmp/code-server.log"
code-server --config "$CONFIG_FILE" > "$CODE_SERVER_LOG" 2>&1 &

# Wait for Code-Server to fully run (adjust sleep as needed)
echo "Waiting for Code-Server to fully run ..."
sleep 5

# Check if "EADDRINUSE" error exists
if grep -q "error listen EADDRINUSE" "$CODE_SERVER_LOG"; then
    echo "Code-Server failed to start: Port $PORT is already in use."
    exit 1  # Stop script execution if Code-Server failed
else
    echo "Code-Server is running on URL: http://0.0.0.0:$PORT"
fi

#########################################
# Start Bore Tunnel
#########################################
echo "Starting Bore tunnel ..."
BORE_LOG="/tmp/bore.log"
# Run bore tunnel, hide its output in a log file
bore local $PORT --to bore.pub > "$BORE_LOG" 2>&1 &
# Wait for Bore to initialize (adjust sleep as needed)
sleep 5
# Capture Bore URL (e.g., bore.pub:38377)
BORE_URL=$(grep -o 'bore.pub:[0-9]*' "$BORE_LOG" | head -n 1)
if [ -n "$BORE_URL" ]; then
    echo "Bore tunnel is running"
    echo "Bore URL : http://$BORE_URL"
else
    echo "Bore tunnel failed to start."
fi

#########################################
# Start Cloudflared Tunnel
#########################################
echo "Starting Cloudflared tunnel ..."
CLOUDFLARED_LOG="/tmp/cloudflared.log"
# Run Cloudflared tunnel, hide its output in a log file
cloudflared tunnel --url http://localhost:$PORT > "$CLOUDFLARED_LOG" 2>&1 &
# Wait for Cloudflared to initialize (adjust sleep as needed)
sleep 5
# Capture Cloudflared URL (pattern: https://<unique-url>.trycloudflare.com)
CLOUDFLARED_URL=$(grep -o 'https://[a-z0-9.-]*\.trycloudflare\.com' "$CLOUDFLARED_LOG" | head -n 1)
if [ -n "$CLOUDFLARED_URL" ]; then
    echo "Cloudflared tunnel is running"
    echo "Cloudflared URL : $CLOUDFLARED_URL"
else
    echo "Cloudflared tunnel failed to start."
fi

# Optionally, wait for background processes to continue running
wait
