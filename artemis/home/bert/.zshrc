# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

#alias
alias vim=nvim
alias rewire="vim ~/.i3/config"
alias livealpha="source ~/Work/envs/py313_env_alpha/bin/activate"
alias backup_configs="python ~/.config/scripts/backup_config_paths.py"

neofetch
source ~/.config/env_vars.sh
