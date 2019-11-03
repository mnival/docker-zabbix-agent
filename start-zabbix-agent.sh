#!/bin/bash

if [ ! -d /var/run/zabbix ]
then
	mkdir /var/run/zabbix
	chown zabbix: /var/run/zabbix
fi

su - zabbix -s "/bin/bash" -c "/usr/sbin/zabbix_agentd -f -c /etc/zabbix/zabbix_agentd.conf"
