# Installation Script for zsh config

echo 'Installing zsh';
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo 'Installing fonts'
cp SourceCodePro+Powerline+Awesome+Regular.ttf /Library/Fonts/

echo 'Creating symlink for config file';
ln zshrc ~/.zshrc;

echo 'Installing thefuck'
brew install thefuck

echo 'Done. Don\'t forget to change terminal font to SourceCodePro+Powerline+Awesome+Regular. Happy bashing!'

echo 'Change Terminal Font on Mac: http://osxdaily.com/2011/09/02/use-any-font-in-the-mac-os-x-lion-terminal'
