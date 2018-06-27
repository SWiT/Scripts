#!/bin/bash
mdadm --detail /dev/md127 | grep "Failed Devices"
