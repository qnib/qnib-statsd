#!/bin/bash
cfg_parser () {
    ini="$(<$1)"                # read the file
    ini="${ini//[/\[}"          # escape [
    ini="${ini//]/\]}"          # escape ]
    IFS=$'\n' && ini=( ${ini} ) # convert to line-array
    ini=( ${ini[*]//;*/} )      # remove comments with ;
    ini=( ${ini[*]/\    =/=} )  # remove tabs before =
    ini=( ${ini[*]/=\   /=} )   # remove tabs be =
    ini=( ${ini[*]/\ =\ /=} )   # remove anything with a space around =
    ini=( ${ini[*]/#\\[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%\\]/ \(} )    # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )    # convert item to array
    ini=( ${ini[*]/%/ \)} )     # close array parenthesis
    ini=( ${ini[*]/%\\ \)/ \\} ) # the multiline trick
    ini=( ${ini[*]/%\( \)/\(\) \{} ) # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} ) # remove extra parenthesis
    ini[0]="" # remove first element
    ini[${#ini[*]} + 1]='}'    # add the last brace
    eval "$(echo "${ini[*]}")" # eval the result
}

cfg_parser '/etc/qnib-setup.cfg'
cfg.section.local

if [ "X$carbon_plain" != "X" ];then
   # carbon is local
   CARBON_IP = '127.0.0.1'
else
   CARBON_IP=$(dig +short carbon.qnib)
   if [ "X${CARBON_IP}" == "X" ];then
       echo "ERROR: Carbon could not be resolved"
       exit 1
   fi
fi
cat /etc/statsd/config.js.example |sed -e "s/, graphiteHost: .*/, graphiteHost: '${CARBON_IP}'/" > /etc/statsd/config.js

# start statsd
/bin/node /usr/lib/statsd/stats.js /etc/statsd/config.js
