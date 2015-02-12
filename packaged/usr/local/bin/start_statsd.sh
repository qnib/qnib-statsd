#!/bin/bash
if [ "X${CARBON_IP}" != "X" ];then
    cat /etc/statsd/config.js.example |sed -e "s/, graphiteHost: .*/, graphiteHost: '${CARBON_IP}'/" > /etc/statsd/config.js
fi

# start statsd
/bin/node /usr/lib/statsd/stats.js /etc/statsd/config.js
