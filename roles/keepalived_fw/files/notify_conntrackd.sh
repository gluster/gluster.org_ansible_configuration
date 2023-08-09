#!/bin/bash
STATUS=$1
echo "Keepalived status: $STATUS" > /etc/motd.d/status
# keepalived use master/backup, conntrackd use primary/backup, hence conversion needed
if [[ $STATUS -eq "master" ]]; then STATUS=primary; fi;
bash /usr/share/doc/conntrack-tools/doc/sync/primary-backup.sh $STATUS
