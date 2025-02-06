#!/bin/bash

# Ensure Homebrew is in the PATH before checking
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Check if Homebrew is installed
if brew --version &>/dev/null; then
    echo "✅ Homebrew is already installed."
else
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2>&1

    # Reload shell environment to detect Homebrew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Verify installation
    if brew --version &>/dev/null; then
        echo "✅ Homebrew installed successfully!"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    else
        echo "❌ Homebrew installation failed."
        exit 1
    fi
fi

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
