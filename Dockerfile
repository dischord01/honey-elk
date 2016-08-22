# rhel7_base image to get systemd to work w/ selinux
FROM rhel7_base 
MAINTAINER Brad Sollar bsollar@redhat.com


# Repos
ADD repo/elasticsearch.repo /etc/yum.repos.d/ 
ADD repo/logstash.repo /etc/yum.repos.d/ 
ADD repo/kibana.repo /etc/yum.repos.d/

# Conf
ADD conf/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml 
ADD conf/logstash.conf /etc/logstash/conf.d/logstash.conf
ADD conf/kibana.yml /opt/kibana/config/kibana.yml
ADD conf/elkbase.tgz /data/elkbase.tgz
ADD conf/persistence.off /data/persistence.off

# Pip
ADD https://bootstrap.pypa.io/get-pip.py /tmp/get-pip.py


# Install Packages
RUN python /tmp/get-pip.py; \
    pip install elasticsearch-curator; \
    rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch; \
    yum install -y elasticsearch kibana logstash logrotate wget java-1.8.0-openjdk hostname which; \
    yum clean all; \
    mkdir -p /data/ \
             /data/elk/ /data/elk/log/ /data/elk/data/ \
             /data/conpot/log/ \
             /data/cowrie/log/tty/ /data/cowrie/downloads/ /data/cowrie/keys/ /data/cowrie/misc/ \
             /data/dionaea/log/ /data/dionaea/bistreams/ /data/dionaea/binaries/ /data/dionaea/rtp/ /data/dionaea/wwwroot/ \
             /data/elasticpot/log/ \
             /data/glastopf/ \
             /data/honeytrap/log/ /data/honeytrap/attacks/ /data/honeytrap/downloads/ \
             /data/emobility/log/ \
             /data/ews/log/ /data/ews/conf/ /data/ews/dionaea/ /data/ews/emobility/ \
             /data/suricata/log/; \
    chown -R elasticsearch:elasticsearch /data; \
    systemctl enable elasticsearch.service; \
    systemctl enable logstash.service; \
    systemctl enable kibana.service; \
    /opt/kibana/bin/kibana plugin -i tagcloud -u https://github.com/stormpython/tagcloud/archive/master.zip; \
	/opt/kibana/bin/kibana plugin -i heatmap -u https://github.com/stormpython/heatmap/archive/master.zip


# Expose volumes
VOLUME ["/data"]

# Start ELK
EXPOSE 5601 9300 9200

# Use systemd to start all services
CMD ["/usr/sbin/init"]



# sudo docker built -t honey-elk .
# sudo docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 5601:5601 -p 9200:9200 -p 9300:9300 honey-elk



# # Let's create ews.ip before reboot and prevent race condition for first start
# myLOCALIP=$(hostname -I | awk '{ print $1 }')
# myEXTIP=$(curl myexternalip.com/raw)
# sed -i "s#IP:.*#IP: $myLOCALIP, $myEXTIP#" /etc/issue
# tee /data/ews/conf/ews.ip << EOF
# [MAIN]
# ip = $myEXTIP
# EOF
# chown $myuser:$myuser /data/ews/conf/ews.ip
