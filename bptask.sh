#!/bin/bash
# va extrage 1000 de randuri dupa cuvantul verificaT si le va analiza dupa cuvintele Failed to run backup task sau Backup task was cancelled
# va verifica daca exista cuvantul verificaT: daca da - verifica dupa el, daca nu, verifica intreg fisier
# apoi va sterge toate cuvintele verificaT si va adauga cuv. verificaT la urma. Astfel scriptul
# mereu va intoarce doar valorile noi
export LC_ALL=""
export LANG="en_US.UTF-8"
### VARIABLES ###
BPATH="/var/log/remotelog"
IP="$1"
BPNAME="$2"
BPTASK=$(cat "$BPATH"/"$IP".log | grep -A 1000 'verificaT' | grep -e "Failed to run backup task"  -e "Backup task was cancelled" | grep "\[$BPNAME\]" | tail -n 1)
BPTASK2=$(cat "$BPATH"/"$IP".log | grep -e "Failed to run backup task"  -e "Backup task was cancelled" | grep "\[$BPNAME\]" | tail -n 1)
CONDITION=$(cat "$BPATH"/"$IP".log | grep 'verificaT')
IFS=$'\n'
### Return backup task status ###
if [[ "$1" &&  "$2" ]]; then
        if [[ "$CONDITION"  ]]; then
                if [[ "$BPTASK" ]]; then
                        echo "$BPTASK"
                else
                        echo "Success. Backup is done"
                fi

        else

                if [[ "$BPTASK2" ]]; then
                        echo "$BPTASK2"
                else
                        echo "Success. Backup is done"
                fi
        fi
else
        echo "Error. Parameters are provided wrong. Yo must introduce IP (x.x.x.x) and backup name in brackets "". Check script /etc/zabbix/scripts/bptask.sh"
fi

sudo sed -i 's/verificaT//g' "$BPATH"/"$IP".log 2> /dev/null

#if [[ "$CONDITION"  ]]; then
#       exit 0
#else
#       echo 'verificaT' >> "$BPATH"/"$IP".log 2> /dev/null
#fi

echo 'verificaT' >> "$BPATH"/"$IP".log 2> /dev/null