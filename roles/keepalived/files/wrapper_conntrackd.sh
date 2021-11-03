#!/bin/bash
echo "Keepalived status: $1" > /etc/motd.d/status

if [ -f /usr/share/doc/conntrack-tools/doc/sync/primary-backup.sh ] ; then
    bash /usr/share/doc/conntrack-tools/doc/sync/primary-backup.sh $*
fi
