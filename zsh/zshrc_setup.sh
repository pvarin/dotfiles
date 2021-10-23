#!/bin/zsh
if [ ! -d $ZSH ]
then
    echo "Installing OhMyZsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    source ~/.zshrc
fi

echo "Insalling Powerlevel10k"
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
sed -i '' 's/ZSH_THEME.*/ZSH_THEME=\"powerline10k\/powerlevel10k\"/' ~/.zshrc


echo "See this post for more suggestions on customizing iTerm2: https://gist.github.com/kevin-smets/8568070"
