#!/bin/sh

function check_glusterd_running()
{
# Explanation of why ps command is used this way:
# https://stackoverflow.com/questions/9117507/linux-unix-command-to-determine-if-process-is-running
        if ! ps cax | grep -w '[g]lusterd' > /dev/null 2>&1
        then
                echo "ERROR: Glusterd is not running"
                exit 1
        fi
}

while [[ !  -z  $(check_glusterd_running)  ]]; do
  sleep 1s;
done

echo "Glusterd is running"

# start volume mounts
mount -t glusterfs 192.168.1.100:/brick1 /mnt/general-volume