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

# Install required packages
echo "Installing required packages..."
brew install cloudflared code-server bore-cli

# Verify installations
echo "Verifying installations..."
if command -v code-server &>/dev/null; then
    echo "✅ code-server installed successfully!"
else
    echo "❌ code-server installation failed."
fi

if command -v cloudflared &>/dev/null; then
    echo "✅ cloudflared installed successfully!"
else
    echo "❌ cloudflared installation failed."
fi

if command -v bore &>/dev/null; then
    echo "✅ bore-cli installed successfully!"
else
    echo "❌ bore-cli installation failed."
fi

echo "Installation complete! Use run.sh to start services."
