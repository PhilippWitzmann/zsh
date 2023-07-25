#!/usr/bin/env bash

MYDIR=$(pwd)
HOMEDIR="/home/$USER"
GIT_USERNAME="Philipp Witzmann"
GIT_EMAIL="philipp@philippwitzmann.de"

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

headline() {
  printf '%s\n' ----------------------------------------------------------------------
  echo -e "${GREEN}${1}${NOCOLOR}"
  printf '%s\n' ----------------------------------------------------------------------
}

subheadline() {
  echo -e " >> ${CYAN}${1}${NOCOLOR}"
}

apt_install() {
  local PACKAGE_NAME=$1

  headline "Install $PACKAGE_NAME"
  sudo apt install -y $PACKAGE_NAME
}

snap_install() {
  local PACKAGE_NAME=$1
  headline "Install $PACKAGE_NAME"
  if [[ $(snap list | cut -d " " -f 1 | grep $PACKAGE_NAME) == *"$PACKAGE_NAME"* ]]; then
    echo "$PACKAGE_NAME installed"
  else
    sudo snap install $PACKAGE_NAME --classic
  fi
}

pip3_install() {
  local PACKAGE_NAME=$1
  headline "Install $PACKAGE_NAME"
  if [[ $(pip3 list --format=columns | grep "$PACKAGE_NAME") == *"$PACKAGE_NAME"* ]]; then
    echo "$PACKAGE_NAME installed"
  else
    sudo pip3 install $PACKAGE_NAME
  fi
}

dpkg_install() {
  local PACKAGE_NAME=$1
  local DEB_PATH=$2
  headline "Install $PACKAGE_NAME"
  if [[ $(dpkg -l | cut -d " " -f 3 | grep "$PACKAGE_NAME") == *"$PACKAGE_NAME"* ]]; then
    echo "$PACKAGE_NAME is installed"
  else
    wget $DEB_PATH -O "/tmp/$PACKAGE_NAME.deb"
    sudo dpkg -i "/tmp/$PACKAGE_NAME.deb"
    rm "/tmp/$PACKAGE_NAME.deb"
  fi
}

gem_install() {
  local PACKAGE_NAME=$1
  headline "Install $PACKAGE_NAME"
  if [[ $(gem list -i "^$PACKAGE_NAME$") == "true" ]]; then
    echo "$PACKAGE_NAME installed"
  else
    sudo gem install $PACKAGE_NAME
  fi
}

apt_install "git"
apt_install "vim"
apt_install "curl"
apt_install "zsh"
apt_install "python3-dev"
apt_install "python3-pip"
apt_install "python3-setuptools"
apt_install "net-tools"
apt_install "fzf"
apt_install "ncdu"
apt_install "bat"

apt_install "apt-transport-https"
apt_install "ca-certificates"
apt_install "gnupg-agent"
apt_install "software-properties-common"
apt_install "ruby-dev"
apt_install "easy-rsa"
apt_install "autojump"

snap_install "spotify"
snap_install "kubectl"
snap_install "code"

headline "Install krew"
(
  set -x
  cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

)

KREW_TOOLS=(ctx ns resource-capacity)

for value in "${KREW_TOOLS[@]}"; do
  headline "Install ${value}"
  kubectl krew install ${value}
done

dpkg_install "google-chrome-stable" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

gem_install colorls
pip3_install thefuck

headline 'Set chrome as default browser'
if [[ $(ls -la /etc/alternatives/x-www-browser | cut -d " " -f 11) == *"google-chrome-stable"* ]]; then
  echo 'Google chrome as default browser set'
else
  sudo update-alternatives --config x-www-browser
fi

headline 'Install diff-so-fancy'
if [ -f "/usr/local/bin/diff-so-fancy" ]; then
  echo 'Diff-so-fancy installed'
else
  sudo wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -O /usr/local/bin/diff-so-fancy
  sudo chmod +x /usr/local/bin/diff-so-fancy
  sudo chown philipp:philipp /usr/local/bin/diff-so-fancy

  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  git config --global color.ui true
  git config --global color.diff-highlight.oldNormal "red bold"
  git config --global color.diff-highlight.oldHighlight "red bold 52"
  git config --global color.diff-highlight.newNormal "green bold"
  git config --global color.diff-highlight.newHighlight "green bold 22"
  git config --global color.diff.meta "yellow"
  git config --global color.diff.frag "magenta bold"
  git config --global color.diff.commit "yellow bold"
  git config --global color.diff.old "red bold"
  git config --global color.diff.new "green bold"
  git config --global color.diff.whitespace "red reverse"
fi

headline 'Set git config'
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"
git config --global push.default current
git config --global push.autoSetupRemote true

headline "Set globalignore file"
echo "" >~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

headline "Install Docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
rm ./get-docker.sh

# create docker group and assign user to group
subheadline "Create docker group and assign current user to it"
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

headline 'Creating symlink for config file'
ln -f zshrc ~/.zshrc

headline 'Install helm'
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

headline 'Install oh-my-zsh'
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

headline 'Install powerlevel10k theme'
if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
  echo "powerlevel10k already installed"
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

headline 'Creating symlink for config file'
ln -f zshrc ~/.zshrc

headline 'Install zsh autocompletion'
if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
  echo "autocompletion already installed"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

headline 'Install zsh syntax highlighting'
if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
  echo "zsh-syntax-highlighting already installed"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

headline 'Install zsh git open'
if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open ]; then
  echo "git open already installed"
else
  git clone https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open
fi

headline 'Install zsh fzf history search'
if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search ]; then
  echo "zsh-fzf-history-search already installed"
else
  git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search
fi

headline 'Install homebrew'
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

headline 'Install pre-commit'
brew install pre-commit


headline 'Cleanup'
sudo apt autoremove

headline "Done. Don't forget to change terminal font to MesloLGS. Happy bashing!"
