# Synology-Backup-LLD-Monitor
## Monitoring will be done in 2 steps
### Create and setup Syslog server
### Setup backup monitoring

1. Create syslogserver

` In my case I used the zabbix server as syslogserver when host is connected directly to the zabbix server LAN and the zabbix proxy  as syslog server when host is under a proxy'
Zabbix server - CentOS 8
On Zabbix server
 - Verify syslog server and install/configure
1. yum  install rsyslog
2. systemctl enable –now rsyslog.service
 
 - Configure syslog server to listen TCP/UDP 
 1. vi /etc/rsyslog.conf
 
 `Find the lines and set ass follow:`
 
\# Provides UDP syslog reception

\# for parameters see http://www.rsyslog.com/doc/imudp.html

module(load="imudp") # needs to be done just once

input(type="imudp" port="514")


\# Provides TCP syslog reception

\# for parameters see http://www.rsyslog.com/doc/imtcp.html

module(load="imtcp") # needs to be done just once

input(type="imtcp" port="514")

` After directive GLOBAL DIRECTIVES add'

\# Template to receive logs\
$template tplremote,"%timegenerated% %HOSTNAME% %fromhost-ip% %syslogtag%%msg:::drop-last-lf%\n"
$template RemoteLogs,"/var/log/remotelog/%fromhost-ip%.log"
*.* ?RemoteLogs;tplremote

` Some explain: `
`the $template tplremote .. will format the log as:`

`Jun 26 16:35:15 APP_NAS 172.16.5.3 Backup SYSTEM:#011[Local][backup] Backup task started.`

2. Create folder for logs
mkdir –p /var/log/remotelog

3. Configure SELinux
 - semanage port -a -t syslogd_port_t -p udp 514
 - semanage port -a -t syslogd_port_t -p tcp 514
 
4. Firewall
 - firewall-cmd --permanent --add-port=514/tcp
 - firewall-cmd --permanent --add-port=514/udp
 - firewall-cmd –reload

5. Configure NAS
 - Log on web interface
 - Go to Log Center -> Log Sending, check Send logs to a syslog server
 - Enter the IP of the Syslog server
 - Under Tab Log Filters select Backup and Network Backup, click Apply
 - To test - click Send test log. You must have the log under /var/log/remotelog

# Second step - Zabbix (as syslog server)
 - Add on the syslog server, in zabbix agent conf 2 keys:
1. UserParameter=backup[*],/etc/zabbix/scripts/synobackup.sh "$1" "$2"
2. UserParameter=backupt[*],/etc/zabbix/scripts/bptask.sh "$1" "$2"

 - On syslog server place under /etc/zabbix/scripts the scripts synobackup.sh and bptask.sh and give them execute permissions: chmod +x synobackup.sh and chmod +x bptask.sh
```
If this folder doesn't exists, do:
mkdir /etc/zabbix/scripts
chown root:zabbix -R /etc/zabbix/scripts/
chmod 750 /etc/zabbix/scripts/ 
``` 
 - Because the script use sed, you must allow zabbix to run under root
 - Restart agent 

3. Add template under Zabbix server
4. Create Macros for monitoring period, NAS IP and community name (in template they are created, you must only modify them)
5. Important: You must set NAS IP as Syslog server IP (or where are the logs), because Zabbix will look on the host for logs, not on the NAS
6. Don't name your backup tasks using ", ' or any Zabbix restricted parameter for the item keys
7. Trigger will be activated when in log zabbix will find `Failed to run backup task` or `Backup task was cancelled`






