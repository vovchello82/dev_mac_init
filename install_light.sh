#!/bin/bash
#if [[ "$(csrutil status | grep enabled)" != "" ]] ; then
#	echo "root muss freigeschaltet sein."
#	echo ""
#	echo "cmd + R beim booten drücken"
#	echo "danach in dem Terminal 'csrutil disable' und 'reboot' eingeben"
#	exit 1
#fi

LOCAL="$( cd "$(dirname "$0")" ; pwd -P )"

if (! which brew &> /dev/null) ; then
	echo 'install brew ===========>'
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/vzlobins/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install gnupg || brew upgrade gnupg

if (! which rvm &> /dev/null) ; then
	gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -sSL https://get.rvm.io | bash -s stable --ruby
	echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.zshenv
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

rvm reload
rvm install 2.7
rvm reload
rvm --default use "$(rvm list | grep -o 'ruby-2.7.[^ ]*' | tail -n 1)"

brew install openjdk@11 || brew upgrade openjdk@11

if ( which java &> /dev/null) ; then
 sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
 echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@11"' >>  ~/.zshenv
 echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >>  ~/.zshenv
 echo 'export CPPFLAGS="-I/opt/homebrew/opt/openjdk@11/include"' >> ~/.zshrc
fi

brew install maven || brew upgrade maven 

if ! [ -e ~/.ssh/id_rsa_github.pub ] ; then
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_github -P "" -C "" -q
	chmod 400  ~/.ssh/id_rsa_github.pub
	ssh-add -K ~/.ssh/id_rsa_github

	echo "your gitlab public key is: "
	cat ~/.ssh/id_rsa_github.pub
	cat ~/.ssh/id_rsa_github.pub | pbcopy

	echo ""
	echo "the key is copied in to the clipboard. Please login here:"
	echo ">  https://github.com"
	echo "and paste the key in your profile settings"
	echo "> https://github.com/settings/keys"
	echo ""
	echo -n "After just press the ENTER"
	read
fi

echo "installing the developer editors"
brew cask install intellij-idea || brew upgrade intellij-idea
brew cask install visual-studio-code || brew upgrade visual-studio-code
# Install Atom
if ! [ -e '/Applications/Atom.app' ] ; then
	curl -s -L https://atom.io/download/macinto -o /tmp/atom.zip
	unzip /tmp/atom.zip -d /Applications
	rm -f /tmp/atom.zip
fi

echo 'install other tools with brew ===========>'
brew install --cask iterm2 || brew upgrade iterm2
brew install bash-completion || brew upgrade bash-completion 
brew install kubectl || brew upgrade kubectl 
brew install --cask docker || brew upgrade docker 
brew install jq || brew upgrade jq
brew install pngpaste || brew upgrade pngpaste
brew install mas || brew upgrade mas
brew install --cask  google-chrome || brew upgrade google-chrome

# Install zsh
brew install zsh zsh-completions || brew upgrade zsh zsh-completions

# Install oh-my-zsh.sh
if ! [ -e ~/.oh-my-zsh ] ; then
#	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sed -i.bak 's/ZSH_THEME=.*/ZSH_THEME="agnoster"/g' "$HOME/.zshrc"
	sed -i.bak 's/plugins=.*/plugins=(git bundler docker osx)/g' "$HOME/.zshrc"
	sed -i.bak 's/#.*export.*PATH.*/export PATH=$HOME\/bin:\/usr\/local\/bin:$PATH/g' "$HOME/.zshrc"
fi

# Install Roboto Schriftart
if (ls ~/Library/Fonts/Roboto* &> /dev/null) ; then
	unzip -n RobotoMono.zip -d ~/Library/Fonts
fi

# Installieren und konfiguriere ITerm
if ! [ -e ~/Library/Preferences/com.googlecode.iterm2.plist ] ; then
	cp com.googlecode.iterm2.plist /tmp/com.googlecode.iterm2.plist
	sed -i -e "s/\$USER/$USER/g" /tmp/com.googlecode.iterm2.plist
	defaults import com.googlecode.iterm2 /tmp/com.googlecode.iterm2.plist
	rm -f /tmp/com.googlecode.iterm2.plist
fi
