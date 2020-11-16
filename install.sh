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
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew install gnupg || brew upgrade gnupg

if (! which rvm &> /dev/null) ; then
	gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -sSL https://get.rvm.io | bash -s stable --ruby

	echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc
	if [[ -f ~/.zshrc ]] ; then
		echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.zshrc
	fi
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

rvm reload
rvm install 2.7
rvm reload
rvm --default use "$(rvm list | grep -o 'ruby-2.7.[^ ]*' | tail -n 1)"

echo 'install openjdk11 ===========>'
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk11 || brew upgrade adoptopenjdk11 

sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

if [[ -f ~/.zshrc ]] ; then
		echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc
		echo 'export CPPFLAGS="-I/usr/local/opt/openjdk/include"' >> ~/.zshrc
		echo '> source ~/.zshrc'
	else
		echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.bashrc
		echo 'export CPPFLAGS="-I/usr/local/opt/openjdk/include"' >> ~/.bashrc
		echo '> source ~/.bashrc'
fi

brew install maven || brew upgrade maven 

if [[ -f ~/.zshrc ]] ; then
		echo "export M2_HOME=/usr/local/Cellar/maven/3.6.3_1/libexec" >> ~/.zshrc
		echo "export M2=${M2_HOME}/bin" >> ~/.zshrc
		echo 'export PATH="$M2_HOME/bin:$PATH"' >> ~/.zshrc
		echo 'export PATH=/usr/local/bin:$PATH'  >> ~/.zshrc
		echo 'export PATH=/usr/local/sbin:$PATH'  >> ~/.zshrc
		echo '> source ~/.zshrc'
	else
		echo "export M2_HOME=/usr/local/Cellar/maven/3.6.3_1/libexec" >> ~/.bashrc
		echo "export M2=${M2_HOME}/bin" >> ~/.bashrc
		echo 'export PATH="$M2_HOME/bin:$PATH"' >> ~/.bashrc	
		echo 'export PATH=/usr/local/bin:$PATH'  >> ~/.bashrc
		echo 'export PATH=/usr/local/sbin:$PATH'  >> ~/.bashrc
		echo '> source ~/.bashrc'
fi

ln -s /usr/local/opt/terraform@0.11/bin/terraform /usr/local/bin/terraform

if ! [ -e ~/.ssh/id_rsa_aws.pub ] ; then	
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_aws -P "" -C "" -q
	chmod 400  ~/.ssh/id_rsa_aws.pub
	ssh-add -K ~/.ssh/id_rsa_aws
fi

if ! [ -e ~/.ssh/id_rsa_gitlab.pub ] ; then
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_gitlab -P "" -C "" -q
	chmod 400  ~/.ssh/id_rsa_gitlab.pub
	ssh-add -K ~/.ssh/id_rsa_gitlab

	echo "your gitlab public key is: "
	cat ~/.ssh/id_rsa_gitlab.pub
	cat ~/.ssh/id_rsa_gitlab.pub | pbcopy

	echo ""
	echo "the key is copied in to the clipboard. Please login here:"
	echo ">  https://gitlab.com"
	echo "and paste the key in your profile settings"
	echo "> https://gitlab.com/profile/keys"
	echo ""
	echo -n "After just press the ENTER"
	read
fi

if ! [ -e ~/Applications/iTerm.app ] ; then
	curl -s -L https://www.iterm2.com/nightly/latest -o /tmp/iterm.zip
	unzip /tmp/iterm.zip -d ~/Applications
	rm -f /tmp/iterm.zip
fi

echo "installing the developer editors"
brew cask install intellij-idea || brew upgrade intellij-idea
brew cask install visual-studio-code || brew upgrade visual-studio-code
# Install Sublime
if ! [ -e '/Applications/Sublime Text.app' ] ; then
	curl -s -L https://download.sublimetext.com/Sublime%20Text%20Build%203211.dmg -o /tmp/sublime.zip
	unzip /tmp/sublime.zip -d /Applications
	rm -f /tmp/sublime.zip
fi

echo 'install other tools with brew ===========>'
brew install bash-completion || brew upgrade bash-completion 
brew install kubectl || brew upgrade kubectl 
brew cask install docker || brew upgrade docker 
brew install jq || brew upgrade jq
brew install awscli || brew upgrade awscli
brew install terraform@0.12 || brew upgrade terraform@0.12
brew install packer || brew upgrade packer
brew install pass || brew upgrade pass
brew install pass-otp || brew upgrade pass-otp
brew install zbar || brew upgrade zbar
brew install pngpaste || brew upgrade pngpaste
brew install mas || brew upgrade mas
brew install node || brew upgrade node
no N | npm install @angular/cli
brew cask install google-chrome || brew upgrade google-chrome

# Install zsh
brew install zsh zsh-completions || brew upgrade zsh zsh-completions

# Install oh-my-zsh.sh
if ! [ -e ~/.oh-my-zsh ] ; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	sed -i.bak 's/ZSH_THEME=.*/ZSH_THEME="agnoster"/g' "$HOME/.zshrc"
	sed -i.bak 's/plugins=.*/plugins=(git bundler osx rake ruby)/g' "$HOME/.zshrc"
	sed -i.bak 's/#.*export.*PATH.*/export PATH=$HOME\/bin:\/usr\/local\/bin:$PATH/g' "$HOME/.zshrc"
fi

# Install Roboto Schriftart
if (ls ~/Library/Fonts/Roboto* &> /dev/null) ; then
	unzip -n $LOCAL/RobotoMono.zip -d ~/Library/Fonts
fi

# Install Barlow Schriftart
if (ls ~/Library/Fonts/Barlow* &> /dev/null) ; then
	unzip -n $LOCAL/fontBarlow.zip -d ~/Library/Fonts
fi

# Installieren und konfiguriere ITerm
if ! [ -e ~/Library/Preferences/com.googlecode.iterm2.plist ] ; then
	cp $LOCAL/com.googlecode.iterm2.plist /tmp/com.googlecode.iterm2.plist
	sed -i -e "s/\$USER/$USER/g" /tmp/com.googlecode.iterm2.plist
	defaults import com.googlecode.iterm2 /tmp/com.googlecode.iterm2.plist
	rm -f /tmp/com.googlecode.iterm2.plist
fi