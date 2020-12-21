#!/bin/bash
export LC_ALL=""
export LANG="en_US.UTF-8"
### VARIABLES ###
BPATH="/var/log/remotelog"
IP="$1"
### Discover backup task and return in JSON format ###
if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  ##### DISCOVERY #####
  BACKUPS=$(cat "$BPATH"/"$IP".log | grep "Backup task started" | cut -d '[' -f 3 | cut -d ']' -f1 | sort -u)
  if [[ -n ${BACKUPS} ]]; then
    JSON="{ \"data\":["
    SEP=""
    IFS=$'\n'
    for BP in ${BACKUPS}; do
      JSON=${JSON}"$SEP{\"{#BPNAME}\":\"${BP}\"}"
      SEP=", "
    done
    JSON=${JSON}"]}"
    echo ${JSON}
  fi
  exit 0
fi





