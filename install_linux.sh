#!/usr/bin/env bash

MYDIR=$(pwd)
HOMEDIR="/home/$USER"
GIT_USERNAME="Philipp Witzmann"
GIT_EMAIL="philipp.witzmann@sh.de"

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

headline () {
  printf '%s\n' ----------------------------------------------------------------------
  echo -e "${GREEN}${1}${NOCOLOR}";
  printf '%s\n' ----------------------------------------------------------------------
}

apt_install () {
  local PACKAGE_NAME=$1

  headline "Install $PACKAGE_NAME"
  if [[ $(dpkg -l | cut -d " " -f 3 |  grep $PACKAGE_NAME) == "$PACKAGE_NAME"* ]];
  then
          echo "$PACKAGE_NAME installed"
  else
          sudo apt-get install -y $PACKAGE_NAME
  fi
}

snap_install () {
  local PACKAGE_NAME=$1
  headline "Install $PACKAGE_NAME"
  if [[ $(snap list | cut -d " " -f 1 |  grep $PACKAGE_NAME) == *"$PACKAGE_NAME"* ]];
  then
          echo "$PACKAGE_NAME installed"
  else
          sudo snap install $PACKAGE_NAME --classic
  fi
}

pip3_install () {
  local PACKAGE_NAME=$1
  headline "Install $PACKAGE_NAME"
  if [[ $(pip3 list --format=columns | grep "$PACKAGE_NAME") == *"$PACKAGE_NAME"* ]];
  then
          echo "$PACKAGE_NAME installed"
  else
    sudo pip3 install $PACKAGE_NAME
  fi
}

dpkg_install () {
  local PACKAGE_NAME=$1
  local DEB_PATH=$2
  headline "Install $PACKAGE_NAME"
  if [[ $(dpkg -l | cut -d " " -f 3 | grep "$PACKAGE_NAME") == *"$PACKAGE_NAME"* ]];
  then
    echo "$PACKAGE_NAME is installed"
  else
    wget $DEB_PATH -O "/tmp/$PACKAGE_NAME.deb"
    sudo dpkg -i "/tmp/$PACKAGE_NAME.deb"
          rm "/tmp/$PACKAGE_NAME.deb"
  fi
}

gem_install () {
 local PACKAGE_NAME=$1
 headline "Install $PACKAGE_NAME"
 if [[ $(gem list -i "^$PACKAGE_NAME$") == "true" ]];
 then
  echo "$PACKAGE_NAME installed"
 else
  sudo gem install $PACKAGE_NAME
 fi
}


# Installation Script for zsh config

apt_install "git";
apt_install "vim";
apt_install "htop";
apt_install "curl";
apt_install "zsh";
apt_install "python3-dev";
apt_install "python3-pip";
apt_install "python3-setuptools";

# docker
apt_install "apt-transport-https"
apt_install "ca-certificates"
apt_install "gnupg-agent"
apt_install "software-properties-common"
apt_install "docker-ce"
apt_install "docker-ce-cli"
apt_install "containerd.io"
apt_install "docker-compose"
apt_install "ruby-dev"

snap_install "spotify"
snap_install "phpstorm"
snap_install "hiri"
snap_install "rambox"
snap_install "kubectl"

mkdir -p ~/.oh-my-zsh/completions
chmod -R 755 ~/.oh-my-zsh/completions

sudo wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx
sudo chmod +x /usr/local/bin/kubectx
wget https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.zsh -O ~/.oh-my-zsh/completions/_kubectx.zsh

sudo wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens
sudo chmod +x /usr/local/bin/kubens
wget https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.zsh -O ~/.oh-my-zsh/completions/_kubens.zsh

dpkg_install "bat" "https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb"
dpkg_install "google-chrome-stable" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

gem_install colorls

pip3_install thefuck

echo 'Set chrome as default browser'
if [[ $(ls -la /etc/alternatives/x-www-browser | cut -d " " -f 11) == *"google-chrome-stable"* ]];
then
        echo 'Google chrome as default browser set'
else
	sudo update-alternatives --config x-www-browser
fi

dpkg_install "zoom" "https://www.zoom.us/client/latest/zoom_amd64.deb"

echo 'Install fzf'
if [ -d "$HOMEDIR/.fzf" ];
then
	echo 'Fzf installed'
else
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi

echo 'Install diff-so-fancy'
if [ -f "/usr/local/bin/diff-so-fancy" ];
then
	echo 'Diff-so-fancy installed'
else
	sudo wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -O /usr/local/bin/diff-so-fancy
	sudo chmod +x /usr/local/bin/diff-so-fancy
	sudo chown philipp:philipp /usr/local/bin/diff-so-fancy


	git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
	git config --global color.ui true
	git config --global color.diff-highlight.oldNormal    "red bold"
	git config --global color.diff-highlight.oldHighlight "red bold 52"
	git config --global color.diff-highlight.newNormal    "green bold"
	git config --global color.diff-highlight.newHighlight "green bold 22"
	git config --global color.diff.meta       "yellow"
	git config --global color.diff.frag       "magenta bold"
	git config --global color.diff.commit     "yellow bold"
	git config --global color.diff.old        "red bold"
	git config --global color.diff.new        "green bold"
	git config --global color.diff.whitespace "red reverse"
fi

echo 'Set git config'
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

echo "Add .idea folder to global gitignore"
echo "" > ~/.gitignore_global
echo ".idea/" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# create docker group and assign user to group
echo "Create docker group and assign current user to it"
if [[ $(cut -d: -f1 /etc/group | grep docker) != "docker" ]]; then
	sudo groupadd docker
fi
if groups $USER | grep -q '\bdocker\b'; then
	sudo usermod -aG docker $USER
fi
if [ -d "$HOMEDIR/.docker" ]; then
	sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
	sudo chmod g+rwx "$HOME/.docker" -R
fi

echo "Add GPG Keys"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "add package repositories"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "update package sources"
sudo apt-get update

echo 'Creating symlink for config file';
ln -f zshrc ~/.zshrc;

echo "https://github.com/denilsonsa/prettyping"
curl -O https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
chmod +x prettyping
sudo mv prettyping /usr/local/bin/

echo 'Install oh-my-zsh'
if [ -d "$HOMEDIR/.oh-my-zsh" ];
then
        echo 'Zsh installed'
else
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	mv $HOMEDIR/.zshrc $HOMEDIR/.zshrc.default
	mv $HOMEDIR/.zshrc.pre-oh-my-zsh $HOMEDIR/.zshrc
fi

echo "Done. Don't forget to change terminal font to Sauce Code Pro Regular. Happy bashing!"
