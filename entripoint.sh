#!/bin/bash

if [ -n "${CRON_TIME}" ]; then
    echo "${CRON_TIME} /scripts/dumper.sh backup > /proc/1/fd/1 2>&1" > /crontab.conf
    crontab  /crontab.conf
fi

if [ "$#" -eq "0" ]; then
    /usr/sbin/crond -f -l 8
else
    /scripts/dumper.sh "$@"
fi
