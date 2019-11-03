FROM debian:stable-slim

LABEL maintainer="Michael Nival <docker@mn-home.fr>" \
	name="debian-zabbix-agent" \
	description="Debian Stable with the package zabbix-agent" \
	docker.cmd="docker run -d -p 10050:10050 -v /etc/zabbix/zabbix_agentd.conf.d:/etc/zabbix/zabbix_agentd.conf.d --hostname zabbix-agent --name zabbix-agent mnival/debian-zabbix-agent"

RUN addgroup --system --quiet --gid 130 zabbix && \
	adduser --quiet --uid 130 --system --disabled-login --disabled-password --no-create-home --ingroup zabbix --home /var/lib/zabbix/ --uid 130 zabbix

RUN printf "deb http://ftp.debian.org/debian/ stable main\ndeb http://ftp.debian.org/debian/ stable-updates main\ndeb http://security.debian.org/ stable/updates main\n" >> /etc/apt/sources.list.d/stable.list && \
	cat /dev/null > /etc/apt/sources.list && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt update && \
	apt -y --no-install-recommends full-upgrade && \
	apt -y --no-install-recommends install gnupg1 && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 082AB56BA14FE591 && \
	printf "deb http://repo.zabbix.com/zabbix/4.4/debian buster main\n" > /etc/apt/sources.list.d/zabbix.list && \
	apt -y purge gnupg1 && \
	apt -y autoremove && \
	apt -y purge $(dpkg -l | egrep "^rc" | awk '{print $2}') && \
	apt -y --no-install-recommends install zabbix-agent ca-certificates publicsuffix libsasl2-modules tini && \
	echo "UTC" > /etc/timezone && \
	rm /etc/localtime && \
	dpkg-reconfigure tzdata && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/alternatives.log /var/log/dpkg.log /var/log/apt/ /var/cache/debconf/*-old

COPY start-zabbix-agent.sh /usr/local/bin/start-zabbix-agent.sh

RUN printf "LogType = console\n" > /etc/zabbix/zabbix_agentd.conf.d/override.conf && \
	chmod +x /usr/local/bin/start-zabbix-agent.sh

EXPOSE 10050/TCP

WORKDIR /var/lib/zabbix

VOLUME ["/etc/zabbix/zabbix_agentd.conf.d"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/start-zabbix-agent.sh"]
