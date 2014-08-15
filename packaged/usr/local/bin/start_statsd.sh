#!/bin/bash
CARBON_IP=${CARBON_PORT_2003_TCP_ADDR}
if [ "X${CARBON_IP}" == "X" ];then
   CARBON_IP=$(dig +short carbon)
   if [ "X${CARBON_IP}" == "X" ];then
       echo "ERROR: Carbon could not be resolved"
       exit 1
   fi
fi
cat /etc/statsd/config.js.example |sed -e "s/, graphiteHost: .*/, graphiteHost: '${CARBON_IP}'/" > /etc/statsd/config.js

# start statsd
/bin/node /usr/lib/statsd/stats.js /etc/statsd/config.js
