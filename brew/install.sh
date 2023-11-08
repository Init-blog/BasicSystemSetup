#!/bin/bash

# Install Homebrew
echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" < /dev/null

# Enable the brew command
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install packages using the Brewfile
brew bundle --file=./brew/Brewfile

# Configure zsh autocomplete

# Create the .zshrc file if it doesn't exist
touch ~/.zshrc

# Append this line to the end of the ~/.zshrc file
echo 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh' > ~/.zshrc

# When installing any software from the internet
# Apple will warn you about it being unsafe teh first time you open it
# Add to the list below all the apps you want to declare as safe to skip the warnings
apps=(    
    "/Applications/Google Chrome.app"    
    # "/Applications/Visual Studio Code.app"
)

for app in "${apps[@]}"; do    
    # Remove the com.apple.quarantine attribute    
    sudo xattr -dr com.apple.quarantine "$app"
done