#!/usr/bin/env bash
# Update Script for zsh config

echo 'Updating symlink for config file';

ln -f zshrc ~/.zshrc;
source $ZSH/oh-my-zsh.sh

echo "Done."