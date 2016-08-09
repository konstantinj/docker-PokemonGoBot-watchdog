#!/bin/bash

names=$(echo $BOT_CONTAINER_NAMES | tr ";" "\n")
num=${NUMBER_ERRORS:-5}
seconds=${ERRORS_IN_SECONDS:-60}
error_statement="Error running loop"

while true; do
    for name in $names; do
        echo -n "checking $name: "
        logs=$(docker logs $name 2>&1 1>/dev/null)
        if [ -n "$logs" ]; then
            echo "no such container"
            continue
        fi
        time_error=$(docker logs $name | grep "$error_statement" | tail -n $num | grep -Eo "[0-9]{2}:[0-9]{2}:[0-9]{2}" | head -n 1)
        if [ -z "$time_error" ]; then
            echo "ok"
            continue
        fi
        lines_error=$(docker logs $name | grep "$error_statement"| tail -n $num | wc -l)
        if [ "$lines_error" -lt "5" ]; then
            echo "ok"
            continue
        fi
        timestamp_error=$(date -d $time_error +%s)
        timestamp_compare=$(date -d "$seconds seconds ago" +"%s")
        if [[ $timestamp_error > $timestamp_compare ]]; then
            echo "$num errors in last $seconds seconds - restarting..."
            docker restart $name &>/dev/null
            echo "sleeping $seconds seconds"
            sleep $seconds
        else
            echo "ok"
        fi
    done
    sleep 10
done
