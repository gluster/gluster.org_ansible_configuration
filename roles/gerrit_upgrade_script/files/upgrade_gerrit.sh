#!/bin/bash

# https://github.com/gluster/infra-docs/blob/master/procedures/gerrit_upgrade.rst
function cleanup_upgrade() {
    [ -f /etc/httpd/conf.d/upgrade.conf ] && rm -f /etc/httpd/conf.d/upgrade.conf && service httpd reload

    systemctl start xinetd

    systemctl start gerrit 
}

function show_message() {
    echo ""
    echo "$1"
    echo "* Press enter to continue"
    read 
}

function check_url() {
    
    if ! curl -f -L -s -I $1 >/dev/null ; 
    then 
        echo "Version $VERSION do not exist upstream, exiting"
        exit
    fi
}

function check_screen() {
    if ! (echo $TERM | grep -P '^screen'); 
    then
        echo "Script requires to run in screen or tmux, exiting"
        exit
    fi
}

function check_version() {
    if ! (echo $1 | grep -P '^\d\.\d{1,2}.\d{1,2}$'); 
    then
        echo "Version $1 do not have the right format, exiting"
        exit
    fi
}

[ -z "$1" ] && echo "Need a version as first argument" && exit

VERSION="$1"
SHORT_VERSION="$(echo $VERSION | cut -d'.' -f1,2)"
URL="https://gerrit-releases.storage.googleapis.com/gerrit-${VERSION}.war"

# TODO handle stage
HOSTNAME="review.gluster.org"

check_version $VERSION
check_url $URL

check_screen

# TODO check that call
trap cleanup_upgrade SIGINT
# stop xinetd, so no more ssh push
systemctl stop xinetd
# add error message
echo "ErrorDocument 500 \"The gerrit server is being upgraded, please come back in 1 or 2h.\"" > /etc/httpd/conf.d/upgrade.conf 
systemctl reload httpd

systemctl stop gerrit

# stop gerrit also using the shell script, just in case (non systemd use)
# Back up Gerrit DB and files into ~/review inside the review user's home directory.
echo "Starting backups"
su - review -c 'cd review.gluster.org ;  bin/gerrit.sh stop ; export B=~review/backup_$(date +%Y-%m-%d-%H-%M)/ ; mkdir -p $B ; cp -r $( ls |grep -v cache |grep -v tmp|grep -v logs) $B'
echo "Backups finihed and placed in ~review"
echo ""

echo "Downloading version ${VERSION} of gerrit, moving old to /review/review.gluster.org/bin/gerrit.war.bak"
# Download the latest version of gerrit into /review/review.gluster.org
mv -f /review/review.gluster.org/bin/gerrit.war /review/review.gluster.org/bin/gerrit.war.bak
wget https://gerrit-releases.storage.googleapis.com/gerrit-${VERSION}.war -O /review/review.gluster.org/bin/gerrit.war
echo "Download finished"
echo ""

show_message "Check https://www.gerritcodereview.com/${SHORT_VERSION}.html for upgrade instructions"

show_message "Schema is about to be upgraded, it will take a while (5 to 10 minutes in total) and ask questions at the end."

#upgrade the schema
su - review -c 'java -jar /review/review.gluster.org/bin/gerrit.war init -d /review/review.gluster.org/'
# start gerrit

show_message "Upgrade is finished, please do any offline tasks now, then Gerrit is going to restart."

cleanup_upgrade

# do display Post Upgrade Testing

echo ""
echo "*******************************"
echo "Post upgrade verification steps"
echo "*******************************"

# TODO automate that verification
show_message "Check the UI, is https://$HOSTNAME/ working ?"

show_message "Check if the diff of a change display properly"
show_message "Check if you can login using Github"
show_message "Check if you can logout using Github "
show_message "Check if you can see username on a change, not just the account number"
# TODO automate too
show_message "Check if the git clone work, with git clone git://$HOSTNAME/glusterfs"
# TODO what about stage ?
show_message "Check if http://git.gluster.org/ work"

show_message "Push a test review and verify that the push goes through."
show_message "Verify that Jenkins voting work as expected for this change."


