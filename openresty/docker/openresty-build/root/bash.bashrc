
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias ll='ls -alF'
alias nt='netstat -antp'
alias json='python -mjson.tool'
alias mget='wget --mirror -p --html-extension --convert-links'

function lj2c {
    lua -b $1 /tmp/luac.out
    /opt/lua/base/bin2c/bin2c /tmp/luac.out > /tmp/code.c
    gcc -I/opt/lua/openresty/luajit/include/luajit-2.1 -L/opt/lua/openresty/luajit/lib -o $2 /opt/lua/base/bin2c/main.c -lluajit-5.1
    echo "$2 compiled ok."
}

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

export LUA_INIT=@/opt/lua/base/init.lua
export PYTHONSTARTUP=/root/.pythonrc

