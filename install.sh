#!/bin/bash

# Install Homebrew (if not already installed)
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Add Homebrew to the PATH permanently in .bashrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
else
    echo "Homebrew is already installed."
fi

# Ensure Homebrew is in the PATH for the current session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install required packages silently
echo "Installing required packages..."
PACKAGES=("cloudflared" "code-server" "bore-cli")

for PACKAGE in "${PACKAGES[@]}"; do
    if brew list --versions "$PACKAGE" &>/dev/null; then
        echo "✅ $PACKAGE is already installed."
    else
        echo "Installing $PACKAGE..."
        brew install "$PACKAGE" > /dev/null 2>&1
        if brew list --versions "$PACKAGE" &>/dev/null; then
            echo "✅ $PACKAGE installed successfully!"
        else
            echo "❌ Failed to install $PACKAGE."
        fi
    fi
done

echo "Installation complete! Use start.sh to start services."
