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

echo "Starting Code-Server on port $PORT"

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

# Start Code-Server in the background and suppress its output
code-server --config "$CONFIG_FILE" > /dev/null 2>&1 &

# Wait a moment to ensure Code-Server is running
sleep 3

##############################
# Start Bore Tunnel (First)
##############################
echo "Starting Bore tunnel to expose port $PORT..."
BORE_LOG="/tmp/bore.log"
# Run bore tunnel, hide its output in a log file
bore local $PORT --to bore.pub > "$BORE_LOG" 2>&1 &

# Give Bore some time to initialize and print the URL
sleep 5

# Capture Bore URL from its log file (example pattern: bore.pub:12345)
BORE_URL=$(grep -o 'bore.pub:[0-9]*' "$BORE_LOG" | head -n 1)
if [ -n "$BORE_URL" ]; then
    echo "URL alternative (Bore): http://$BORE_URL"
else
    echo "Bore tunnel failed to start."
fi

#################################
# Now Start Cloudflared Tunnel
#################################
echo "Starting Cloudflared tunnel to expose port $PORT..."
CLOUDFLARED_LOG="/tmp/cloudflared.log"
# Redirect Cloudflared output to a log file
cloudflared tunnel --url http://localhost:$PORT > "$CLOUDFLARED_LOG" 2>&1 &

# Allow Cloudflared some time to initialize
sleep 5

# Capture the Cloudflared tunnel URL from its log file
CLOUDFLARED_URL=$(grep -o 'https://[a-z0-9.-]*\.trycloudflare\.com' "$CLOUDFLARED_LOG" | head -n 1)
if [ -n "$CLOUDFLARED_URL" ]; then
    echo "Code-Server is running. Use Cloudflared's tunnel URL to access it: $CLOUDFLARED_URL"
else
    echo "Cloudflared tunnel failed to start."
fi

# Optionally: Wait for the tunnels to keep running
wait