#!/bin/bash

# Set default folder for storing screenshots
# Create the directory if it doesn't exist
mkdir -p ~/Downloads 
# Sets it as default location for screenshots
defaults write com.apple.screencapture location ~/Downloads

# Install fonts
# Copy fonts to the Fonts directory
cp -a ./fonts/. ~/Library/Fonts 