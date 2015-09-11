
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias ll='ls -alF'
alias nt='netstat -antp'

function ng {
    $(nginx_cmd) -c "$(echo `pwd`)/$1"
}

function ngr {
    ngs; ng "$1" && ngt
}

function ngs {
    $(nginx_cmd) -s stop
}

function ngc {
    rm -rf $(nginx_logs)*
    mkdir -p $(nginx_logs)
}

function ngt {
    tail -f $(nginx_logs)/*.log
}

function nginx {
    $(nginx_cmd) "$@"
}

function nginx_cmd {
    echo "/opt/lua/openresty/nginx/sbin/nginx";
}

function nginx_logs {
    echo "/opt/lua/openresty/nginx/logs";
}

alias psg='ps -ef|grep nginx'

