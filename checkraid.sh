#!/bin/bash
ARG="$1"
if [ "$ARG" = "-e" ]; then
	EMAILOK=true
else
	EMAILOK=false
fi

MDADM=$(sudo mdadm --detail /dev/md127)
#echo "$MDADM"
FAILED=$(echo "$MDADM" | grep -oE  'Failed Devices : ([0-9]*)')
if [ "$FAILED" = "Failed Devices : 0" ]; then
	echo "No failed devices."
	
	if [ "$EMAILOK" = true ]; then
		echo "Sending email."
		MESSAGE="To: switlikm@gmail.com\n"
		MESSAGE+="From: switlikm@comcast.net\n"
		MESSAGE+="Subject: [SERVER_OK] SWiT-FS\n"
		MESSAGE+="\n"
		MESSAGE+="SWIT-FS: RAID6 Array is fine.\n"
		MESSAGE+="\n"
		MESSAGE+="$MDADM\n"
		#echo -e "$MESSAGE"
		echo -e "$MESSAGE" | /usr/sbin/ssmtp switlikm@gmail.com
	fi
else
	echo "FAILED DEVICES!!!"
	
	echo "Sending email."
	MESSAGE="To: switlikm@gmail.com\n"
	MESSAGE+="From: switlikm@comcast.net\n"
	MESSAGE+="Subject: [SERVER_ERROR] SWiT-FS\n"
	MESSAGE+="\n"
	MESSAGE+="SWIT-FS: RAID6 Array has failed drive(s).\n"
	MESSAGE+="\n"
	MESSAGE+="$MDADM\n"
	#echo -e "$MESSAGE"
	echo -e "$MESSAGE" | /usr/sbin/ssmtp switlikm@gmail.com
fi
