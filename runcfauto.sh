#!/bin/bash

step=5 #间隔的秒数，不能大于60

for (( i = 0; i < 60; i=(i+step) )); do
    /bin/bash /tmp/cfauto.sh >> /tmp/cfautolog.log 2>&1 &
    sleep $step
done

exit 0