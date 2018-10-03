#!/bin/bash
#set -x
set -e

DIRENV_DIR=$HOME/.config/direnv
DIRENV_RC=$DIRENV_DIR/direnvrc

mkdir -p $DIRENV_DIR
ln -sf $PWD/docker-env.sh $DIRENV_DIR/docker-env.sh
if ! grep 'docker-env.sh' $DIRENV_RC > /dev/null; then
    echo 'Adding docker-env.sh to $DIRENV_RC'
    cat >> $DIRENV_RC <<EOF

# Automatically added by docker-env
source $DIRENV_DIR/docker-env.sh
EOF

fi
echo "Installed. Don't forget to load direnv in your environment"
