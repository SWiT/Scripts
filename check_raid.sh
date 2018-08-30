#!/bin/bash
# run as root
# this script is for monitoring the RAID 6 array for failed disks and free space
# sudo apt-get install ssmtp
# sudo nano /etc/ssmtp/ssmtp.conf
#
# root=postmaster
# mailhub=smtp.comcast.net:587
# UseSTARTTLS=YES
# UseTLS=YES
# AuthUser=USER@comcast.net
# AuthPass=PASSWORD
# hostname=MYSERVER
# FromLineOverride=YES
# 
# OR sudo nano/etc/postfix/main.cf AND set SMPT=false
#
# CRON:
# m h  dom mon dow   command
# 0 */8 * * * /home/moodleadmin/moodlebackup_scripts/check_raid.sh > /home/moodleadmin/log/check_raid.log 2>&1
# 0 6 * * 0 /home/moodleadmin/moodlebackup_scripts/check_raid.sh -e > /home/moodleadmin/log/check_raid.log 2>&1
#

SMPT=true
RAIDDRIVE="/dev/md1"
TO="switlikm@gmail.com"
FROM="switlikm@comcast.net"
SPAREDRIVES=0
DRIVES=("/dev/md1" "/dev/sda1")
MINPERCENTFREE=5

ARG="$1"
if [ "$ARG" = "-e" ]; then
    EMAILOK=true
else
    EMAILOK=false
fi

MDADM=$(sudo mdadm --detail $RAIDDRIVE)
DF=$(df -h)
echo -e "$MDADM\n"
echo -e "$DF\n"


LINEFAILED=$(echo "$MDADM" | grep -oE  'Failed Devices : ([0-9]*)')
if [ "$LINEFAILED" = "Failed Devices : 0" ]; then
    FAILED=false
else
    FAILED=true
fi


LINESPARE=$(echo "$MDADM" | grep -oE 'Spare Devices : ([0-9]*)')
if [ "$LINESPARE" = "Spare Devices : $SPAREDRIVES" ]; then
    SPAREMISSING=false
else
    SPAREMISSING=true
fi


LOWMESSAGE=""
DISKLOW=false
for ix in ${!DRIVES[*]}
do
    PERCENTFREE=$((100-$(echo "$DF" | grep "${DRIVES[$ix]}" | awk '{print $5}' | cut -d'%' -f1 )))
    #printf " %s %s %s \n" "${DRIVES[$ix]}" "$PERCENTFREE" "$MINPERCENTFREE"
    if (( $PERCENTFREE < $MINPERCENTFREE )); then
        LOWMESSAGE+="${DRIVES[$ix]} has less than $MINPERCENTFREE% free\n"
        DISKLOW=true
    fi
done
echo -e "$LOWMESSAGE"

#echo "$FAILED $SPAREMISSING $DISKLOW"

if $FAILED || $SPAREMISSING || $DISKLOW; then
    echo "FULL, FAILED, OR MISSING DEVICES!!!"	
    echo "Sending email."
    SUBJECT="[SERVER_ERROR] $HOSTNAME"
    MESSAGE+="$HOSTNAME: RAID6 Array has full, failed, or missing drive(s).\n"
    MESSAGE+="\n"
    MESSAGE+="$MDADM\n"
    MESSAGE+="\n"
    MESSAGE+="$DF\n"
    MESSAGE+="\n"
    MESSAGE+="$LOWMESSAGE\n"
    if [ "$SMPT" = true ]; then
        HEADER="To: $TO\n"
        HEADER+="From: $FROM\n"
        HEADER+="Subject: $SUBJECT\n"
        HEADER+="\n"
        MESSAGE="$HEADER\n$MESSAGE"
        echo -e "$MESSAGE" | /usr/sbin/ssmtp $TO
    else
        echo -e "$MESSAGE" | mail -s "$SUBJECT" "$TO"
    fi	
else
    echo "No full, failed, or missing devices."
    if $EMAILOK; then
        echo "Sending email."
        SUBJECT="[SERVER_OK] $HOSTNAME"
        MESSAGE="$HOSTNAME: RAID6 Array is fine.\n"
        MESSAGE+="\n"
        MESSAGE+="$MDADM\n"
        MESSAGE+="\n"
        MESSAGE+="$DF\n"
        MESSAGE+="\n"
        MESSAGE+="$LOWMESSAGE\n"
        if [ "$SMPT" = true ]; then
            HEADER="To: $TO\n"
            HEADER+="From: $FROM\n"
            HEADER+="Subject: $SUBJECT\n"
            HEADER+="\n"
            MESSAGE="$HEADER\n$MESSAGE"
            echo -e "$MESSAGE" | /usr/sbin/ssmtp $TO
        else
            echo -e "$MESSAGE" | mail -s "$SUBJECT" "$TO"
        fi
    fi
fi

echo

