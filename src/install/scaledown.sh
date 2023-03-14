#!/bin/bash
pid=`systemctl show --property MainPID --value atom`
runuser -l boomi -c 'mkdir -p $ATOM_HOME/nodes-deleted && touch $ATOM_HOME/nodes-deleted/${ATOM_LOCALHOSTID//-/_}.offboard'
tail --pid=$pid -f /dev/null
