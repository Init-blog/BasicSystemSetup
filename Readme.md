### Automate your entire Mac development setup with a one line command

When an ordinary person feels overwhelmed by life, they might quit their job, leave their partner, cut their hair, and change clothes.
For a developer, the equivalent is wiping out their computer and initiating a fresh installation, and iconless desktop with the default wallpaper feels as good as a new life on a new city.

Years ago, this process involved backing up all kinds of data, documents, bookmarks, photos, and music, only to realize in horror, post-formatting, that essential fonts had not been backed up. Fortunately, the advent of automatic cloud syncing has alleviated most of this issue. Now, wiping the HDD, reinstalling the system, and logging in ensures that everything is restored as it was.

But here's the catch: this process doesn't restore the plethora of installed software, especially the sneaky tools like NPM, MySQL, Composer, Yarn, and Node.js, which leave no shortcuts or any visible trace of its existence anywhere to be seen. After accumulating a mishmash of functional and dysfunctional software over several months, it's a naive expectation to remember and reinstall everything without ending up bloating the system right after the wipe.

So... señor pancho, is there a way to avoid this second-toughts-inducing scenario? Should we settle for what it is and reconsider how we are dealing with this while our ancestors dealt with mammoths and wolves?
Well, there is indeed a solution!

In this article, we'll explore how to create your own setup with all the Macos App Store apps, development software, dependencies, and even some configurations, using a single one-line script on your pristine terminal, nothing else.

#### Up-to-date check:

```
Article published in November 2023. 

Compatibility was tested on:
macOS Ventura 13.5

Software requirements:
Any terminal/console app running some ZSH shell
```

Not sure if you are using ZSH? Read this article on how to [Check and configure your shell for ZSH](wa)

#### What is the deal?

For years, we've relied on "Homebrew" as our go-to solution. This tool effortlessly downloads, installs, and keeps all your software up to date. However, let's not mistake it for magic. You still need to manually install Homebrew, which currently involves a step to enable the brew command.

After that, it's a matter of calling 'brew install' for each software piece. Sure, you can create a brewfile to manage your preferred software, but some items might require extra instructions to get them working. So, brace yourself for that Matrix-esque stream of text on your console, coming at you at light speed, to make sure everything ticks smoothly.

What i present you now is a solution to the solution, a script crafted from multiple files stored in a public repository. It downloads itself to your machine and takes charge of Homebrew's setup and configuration, installs the software listed in the "Brewfile," and executes those extra commands necessary for some packages to function properly.

And that's not all! You can even run extra scripts to tweak your Mac's behavior, all with just a simple one-liner.

#### Show me, dont tell me

So... you enjoy living on the edge? Are you unfazed by the "three-second rule" for food on the floor? You prodly wear mismatched socks to a wedding? You load Stack Overflow and shamelessly copy the highest voted answer's code into your own, like a true savage?
Well, while your bravery is commendable, it might not lead to a long life. As long as you're still sharing this world with the rest of us, go ahead, paste this line into your terminal, and see what happens:

*Im joking, never ever do such a senseless thing.*

This is what my current setup script looks like:

```shell
curl -sSL https://github.com/laikmosh/System-Setup/raw/main/install.sh | sh
```

That's it. I wipe the computer, log back in, and paste it directly into the default terminal. No other dependencies required. Voila!
Now, let's break down what this command is doing to your computer and how you can customize it for your own needs.
This isn't a Linux boot camp, but for the sake of my sanity, let me explain what this command does. We want to ensure it won't steal your passwords and email them to me for blackmailing my readers. Always assume any command you find online will attempt to do just that.

```shell

curl # Here, we're using 'curl' to grab content from a specific URL. Think of it as the ultimate data transfer wizard for the command line.

-s # This flag is like the 'silent mode' of curl. It keeps the operation hush-hush, hiding any progress, confirmations or error messages. Perfect for those scripted tasks.

-S # If something goes wrong during the download, this flag ensures curl speaks up and tells you about it. No secrets here!

-L # Don't you just hate it when a file has moved or redirected? Well, with this little '-L' flag, curl automatically tracks it down, following any redirects

-sSL # Now you can simply blend all the above superpowers into one with this.

https://github.com/laikmosh/System-Setup/raw/main/install.sh # This is the link to the raw script file on GitHub. Our download source, if you will.

| # And now, the pipe operator, it exists to pass the output of the previous command to the next command, in this case the downloaded file from the curl command will be passed to the sh command.

sh # Finally, the trusty 'sh' command steps in to execute the shell script from the GitHub URL. Let the magic unfold!
```

Fine, everything looks good to me, run it and let it rain! But wait, what in the lords name is the install.sh going to do?
Lets take a look:

install.sh

```shell
#!/bin/bash

# Prompt for sudo password, as it will be required for the installation
echo 'Password required for installation:'
if ! sudo -v; then
    echo "Failed to obtain sudo privileges. Exiting."
    exit 1
fi

# Setup a temporary folder to download the repository, exit script if filesystem is not writable
mkdir -p "$HOME/SystemSetupTmp"
cd "$HOME/SystemSetupTmp" || exit

# Download and unzip repository, exit script if download fails
curl -L -o master.zip https://github.com/laikmosh/System-Setup/archive/refs/heads/main.zip
unzip -o master.zip
cd System-Setup-main || exit

# Install brew and brewfile
sh brew/install.sh

# System custom settings
sh SysSettings/setup.sh

# Finally, remove the temporary directory and its contents recursively
rm -rf "$HOME/SystemSetupTmp"
echo "Temporary files removed successfully."
```

So it seems all that this script does is fetch the repository from github, download and unzip it to a temporary folder, and then execute two scripts within the repo, **brew/install.sh** and <strong>SysSettings/setup.sh</strong>, finally it deletes everything it has downloaded.
First lets check what brew/install.sh has in for us:

brew/install.sh

```shell
#!/bin/bash

# Install Homebrew
echo "Installing Homebrew"/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" < /dev/null

# Enable the brew command
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install packages using the Brewfile
brew bundle --file=./brew/Brewfile

# Configure zsh autocomplete
# Create the .zshrc file if it doesn't exist
touch ~/.zshrc
# Append this line to the end of the ~/.zshrc file
echo 'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
# Source the updated .zshrc file
source ~/.zshrc

# When installing any software from the internet
# Apple will warn you about it being unsafe teh first time you open it
# Add to the list below all the apps you want to declare as safe to skip the warnings
apps=(    
    "/Applications/Google Chrome.app"    
    # "/Applications/Visual Studio Code.app"
)

for app in "${apps[@]}"do    
    # Remove the com.apple.quarantine attribute    
    sudo xattr -dr com.apple.quarantine "$app"
done
```

It seems pretty self explanatory to me but of course i wrote it so it should make sense, in a nutshell it:

* installs and configures homebrew
* uses the brewfile in the repository to install all the software
* runs some configurations to enable the zsh autosuggetions for your terminal
* finally it tells your mac to trust some of the apps it has downloaded from the internet so it does not warn you about it when you open it.

So what comes in the brewfile? lets check

brew/Brewfile

```brewfile
# These pacakges provide the necessary information for Homebrew 
# to install and manage various software packages and applications.
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"

# Homebrew can manage 3 kind of apps
# 'brew' will be used for CLI software
# 'mas' will be used for Mac App Store software
# 'cask' will be used for all the apps not available on the app store

# The brew command will fetch and execute installation instructions from homebrew
# those instructions are called formulae
# "mas" stands for MacAppStore, this package allows homebrew to install apps from the mac store
brew "mas"
# "zsh-autosuggestions" will enable terminal suggestions based on you command history
# this formulae requires the ~/.zshrc to be modified, this repo includes a script
# that will automatically set up this.
brew 'zsh-autosuggestions'

# Once "mas" is installed we can use that command to install apps from the app store
# For this example we are only installing "The Unarchiver", 
# which is a file compressor/decompressor, like a Mac winzip

mas "The Unarchiver", id: 425424353
# mas "Keynote", id: 409183694
# mas "Numbers", id: 409203825
# mas "Pages", id: 409201541

# I have commented the other apps, but feel free to uncomment them and add your own
# The "app name string" is used for identification, while 
# the id ensures the correct app is installed from the Mac App Store via Homebrew.
# You can find the app id by looking for your app on the AppStore, sharing as a link
# and in the link you'll find a number, that is the app id
# Example: https://apps.apple.com/mx/app/keynote/id409183694

# Most of the cool apps are not available from the AppStore
# For those we use the cask command
# For this example we'll only install Chrome
cask "google-chrome"
# cask "visual-studio-code"
# cask "microsoft-edge"
# cask "docker"
# cask "zoom"
# cask "miro"
# cask "figma"

# Uncomment all that you want or you could also search for 
# any app you want on https://brew.sh/ to get the cask id
```

This Brewfile is 95% comments but on the remaining 5% it instructs homebrew to:

* download the latest definitions for available apps
* install the package to allow App Store installations
* install the zsh autosuggestions package
* install "The Unarchiver" from the mac store
* install Google Chrome

SysSettings/setup.sh

```brewfile
#!/bin/bash

# Set default folder for storing screenshots
# Create the directory if it doesn't exist
mkdir -p ~/Downloads 
# Sets it as default location for screenshots
defaults write com.apple.screencapture location ~/Downloads

# Install fonts
# Copy fonts to the Fonts directory
cp -a ./fonts/. ~/Library/Fonts 
```

In this case it sets a configuration to change the default location of the screenshots from the default desktop to the downloads folder, i like it this way because the downloads folder is right there in the dock, my desktop does not get cluttered with screenshots and and downloads folder doesnt get synced with icloud so im not wasting storage space on useless screenshots.

Also it installs to the system all the fonts stored in the repository's "fonts" folder, so its a way to backup your fonts

#### What now?

Now that we understand how this works, it's time for the fun part. Clone this repository from this [link](git), customize it as per your requirements, include your software (ensure no additional steps are necessary, and if there are, incorporate them into a script), identify any system configurations that can be adjusted via the terminal, save your modifications to your repository, and when you're prepared, execute your script in the terminal using the following command:

```shell
curl -sSL https://github.com/{YOUR_USERNAME}/{YOUR_REPOSITORY_NAME}/raw/main/install.sh | sh

# Dont forget to replace the {YOUR_USERNAME} and {YOUR_REPOSITORY_NAME} strings with your own values!
```

Sometimes curl will return a cached value, so if you are actively editing your scripts and testing them, you might not see your changes reflected, if this happens run your command explicity saying that you dont want to use cached files:

```shell
curl -H 'Cache-Control: no-cache' -sSL https://github.com/{YOUR_USERNAME}/{YOUR_REPOSITORY_NAME}/raw/main/install.sh | sh
```

#### TL:DR

Go to the repo in this [link](git), clone it, modify it to your needs and run it in your terminal like this

#### You are free to go

But before you do, i have been looking for terminal commands to tweak mor system configurations but there doesnt seem to be a comprehensive list of commands, do you know some other system configurations that could be included in this file?