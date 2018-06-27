#!/bin/bash
FAILEDDEVICES=$(sudo mdadm --detail /dev/md127 | grep -oE  'Failed Devices : ([0-9]*)')
#echo "'$FAILEDDEVICES'"
if [ "$FAILEDDEVICES" = "Failed Devices : 0" ]; then
	echo "No failed devices."
else
	echo "FAILED DEVICES!!!"
fi

