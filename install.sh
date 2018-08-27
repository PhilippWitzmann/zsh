#!/usr/bin/env bash
# Installation Script for zsh config

echo 'Installing zsh';
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo 'Installing fonts'
cp SourceCodePro+Powerline+Awesome+Regular.ttf /Library/Fonts/

echo 'Creating symlink for config file';

ln zshrc ~/.zshrc;

echo "Adding CLI-Tools"

echo "https://github.com/sharkdp/bat"
brew install bat

echo "https://github.com/denilsonsa/prettyping"
curl -O https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
chmod +x prettyping
mv prettyping /usr/local/bin/

echo "https://github.com/junegunn/fzf"
brew install fzf

echo "https://github.com/so-fancy/diff-so-fancy"
brew install diff-so-fancy

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

echo "https://dev.yorhel.nl/ncdu"
brew install ncdu

echo "https://github.com/nicolargo/glances"
brew install glances


echo "Done. Don't forget to change terminal font to SourceCodePro+Powerline+Awesome+Regular. Happy bashing!"

echo "Change Terminal Font on Mac: http://osxdaily.com/2011/09/02/use-any-font-in-the-mac-os-x-lion-terminal"
