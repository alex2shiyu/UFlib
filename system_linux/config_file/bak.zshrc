# Path to your oh-my-zsh installation.
export ZSH=/home/cchen/.oh-my-zsh
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
#ZSH_THEME="agnoster"
ZSH_THEME="pygmalion"
#ZSH_THEME="muse"
DEFAULT_USER="alexchen"
plugins=(git)
source $ZSH/oh-my-zsh.sh
if [[ -r ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh ]]; then
    source ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
fi
#unsetopt share_history
setopt share_history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# edit line in vim with esc
export VISUAL=vim
export EDITOR=vim
autoload edit-command-line; zle -N edit-command-line
bindkey '\033' edit-command-line

# Aliases
alias ssh='TERM=xterm-256color ssh -X '
alias scpr="rsync -P --rsh=ssh -h -r"
# Enable autocomplete in gnuplot
alias gnuplot="rlwrap -a -c -b\"\\\"\\\"\\\'\\\'\" gnuplot"
alias mocp='mocp -T moca_theme'
alias pestat='pestat -n'
alias scp='scp -r'

### Environment Variables
#PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/bin/ctags-install/bin:$PATH
export PATH=$HOME/intel/bin:$PATH
export PATH=$HOME/mpich-install/bin:$PATH
export PATH=/usr/local/cuda-9.0/bin:$PATH
export PATH=$HOME/pgi-compiler/linux86-64/2019/bin:$PATH
export PATH=$HOME/Downloads/cmake-3.17.0-rc3/bin:$PATH
export PATH=$HOME/pgi-openmpi-cuda-install/bin:$PATH
#export PATH=$HOME/pgi-compiler/linux86-64-nollvm/2019/bin:$PATH

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/intel/lib/intel64:$HOME/intel/mkl/lib/intel64:$HOME/mpich-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/mpich-install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/magma-install/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=$HOME/pgi-compiler/linux86-64/2019/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=$HOME/pgi-compiler/linux86-64-llvm/2019/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/pgi-openmpi-cuda-install/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/intel/composer_xe_2013.3.163/compiler/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64:$LD_LIBRARY_PATH

# INCLUDE
#export CPLUS_INCLUDE_PATH=/home/cchen/pgi-compiler/linux86-64-llvm/19.10/include:$CPLUS_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu/c++/5:$CPLUS_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/home/cchen/anaconda3/include:$CPLUS_INCLUDE_PATH
export C_INCLUDE_PATH=/home/cchen/anaconda3/include:$C_INCLUDE_PATH

# here for scifor should be  MKLROOT=$HOME/intel/mkl/intel64
# but for gutzwiller  should be MKLROOT=$HOME/intel/mkl
export MKLROOT=$HOME/intel/mkl/lib/intel64
export MAGMALIB=$HOME/magma-install/lib
export MAGMAINC=$HOME/magma-install/include
export OPENBLASLIB=$HOME/openblas-install/lib

#CUDA
export CUDADIR=/usr/local/cuda-9.0
export CUDALIB=/usr/local/cuda-9.0/lib64
export INCLUDE=$CUDADIR/include:$INCLUDE

# <<< sypeng >>>
alias rm="bash /home/cchen/sypeng/UFlib/system_linux/func_myself/xxyrm.sh"
alias sline="bash /home/cchen/sypeng/UFlib/system_linux/func_myself/showline.sh"
export PYTHONPATH=/home/cchen/sypeng/UFlib:$PYTHONPATH

#hdf5
export LD_LIBRARY_PATH=/home/cchen/sypeng/soft/hdf5/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/home/cchen/sypeng/soft/hdf5/lib:$LIBRARY_PATH

#source $HOME/intel/composer_xe_2013.3.163/bin/compilervars.sh intel64
#source $HOME/intel/composer_xe_2013.3.163/bin/iccvars.sh intel64
#source $HOME/intel/composer_xe_2013.3.163/bin/ifortvars.sh intel64

# <<< sypeng >>>

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/cchen/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/cchen/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/cchen/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/cchen/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# cd to directory in clipboard
function cwd {
    cd $(xclip -o)
}

# load antigen, zsh plugins manager
source $HOME/.antigen/antigen.zsh
# load antigen configurations
antigen init $HOME/.antigenrc

# man highlight
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

alias nvprof="/home/cchen/pgi-compiler/linux86-64-llvm/2019/cuda/10.0/bin/nvprof"
alias git-describe-branches='for line in $(git branch); do
description=$(git config branch.$line.description)
if [ -n "$description" ]; then
    echo "$line     $description"
fi
done'
