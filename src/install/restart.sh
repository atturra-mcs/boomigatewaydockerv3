#!/bin/sh

# ENV variables
# LOCALHOST_ID - set if script is invoked by a cluster node.

restart_log="restart${LOCALHOST_ID}.log"

date >> "${restart_log}" 2>&1
echo "Using systemd in docker container for restart. Check journalctl in container for logs." >> "${restart_log}" 2>&1
sudo systemctl restart atom

