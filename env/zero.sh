#!/bin/bash
echo "installing zerobrane..."
cd /opt/lua
git clone git@github.com:irr/ZeroBraneStudio.git
cd ZeroBraneStudio
git remote add upstream https://github.com/pkulchenko/ZeroBraneStudio.git
git fetch upstream && git merge upstream/master && git push
cd /usr/local/bin/
sudo ln -s /opt/lua/ZeroBraneStudio/zbstudio.sh
