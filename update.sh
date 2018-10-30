#!/usr/bin/env /bin/zsh
# Update Script for zsh config

echo 'Updating symlink for config file';

ln -f zshrc ~/.zshrc;

echo 'Sourcing';
source $ZSH/oh-my-zsh.sh

echo "Done."