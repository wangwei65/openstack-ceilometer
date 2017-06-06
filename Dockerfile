FROM fedora
MAINTAINER jlabocki@redhat.com

# This Dockerfile installs the following components of Ceilometer in a Docker Image
# 
# 
# 

#Timestamps are always useful
RUN date > /root/date

#RUN pip install tox
#Can't run the line above because https://bugs.launchpad.net/openstack-ci/+bug/1274135, need to specify version 1.6.1

RUN yum install mysql-devel openssl-devel wget unzip git redhat-rpm-config mongodb mongodb-server python-devel mysql-server libffi-devel libxml2-devel libxslt-devel python-setuptools python-pip libffi libffi-devel gcc  python-pip python-pbr mongodb python-pymongo rabbitmq-server -y

RUN pip install tox

WORKDIR /opt
#Clone Ceilometer
RUN git clone -b 6.0.0 http://github.com/openstack/ceilometer.git  /opt/stack/

#Ceilometer Collector Configuration
WORKDIR /opt/stack
RUN python setup.py install
RUN mkdir -p /etc/ceilometer
RUN tox -egenconfig
RUN cp /opt/stack/etc/ceilometer/*.json /etc/ceilometer
RUN cp /opt/stack/etc/ceilometer/*.yaml /etc/ceilometer
RUN cp /opt/stack/etc/ceilometer/ceilometer.conf.sample /etc/ceilometer/ceilometer.conf

#Ceilometer Collector Configuration changes
#RUN sed -ri 's/#metering_secret=change this or be hacked/metering_secret=redhat/' /etc/ceilometer/ceilometer.conf
#RUN sed -ri 's/#connection=<None>/connection = mongodb:\/\/admin:insecure@localhost:27017\/ceilometer/' /etc/ceilometer/ceilometer.conf
#RUN echo "   " > /etc/ceilometer/ceilometer.conf

RUN echo "[DEFAULT]" > /etc/ceilometer/ceilometer.conf
RUN echo "rpc_backend = rabbit" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_strategy = keystone" >> /etc/ceilometer/ceilometer.conf

RUN echo "[database]" >> /etc/ceilometer/ceilometer.conf
RUN echo "connection=mysql://ceilometer:HuaWei_123@10.21.147.126:3309/ceilometer" >> /etc/ceilometer/ceilometer.conf

RUN echo "[dispatcher_gnocchi]" >> /etc/ceilometer/ceilometer.conf
RUN echo "filter_service_activity = False" >> /etc/ceilometer/ceilometer.conf
RUN echo "archive_policy = low" >> /etc/ceilometer/ceilometer.conf

RUN echo "[keystone_authtoken]" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_uri = http://10.21.147.126:5001" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_url = http://10.21.147.126:35358" >> /etc/ceilometer/ceilometer.conf
RUN echo "project_domain_name = default" >> /etc/ceilometer/ceilometer.conf
RUN echo "user_domain_name = default" >> /etc/ceilometer/ceilometer.conf
RUN echo "project_name = service" >> /etc/ceilometer/ceilometer.conf
RUN echo "username = ceilometer" >> /etc/ceilometer/ceilometer.conf
RUN echo "password = huawei123" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_host = 10.21.147.126" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_type = password" >> /etc/ceilometer/ceilometer.conf

RUN echo "[oslo_messaging_rabbit]" >> /etc/ceilometer/ceilometer.conf
RUN echo "rabbit_host = 10.21.147.126" >> /etc/ceilometer/ceilometer.conf
RUN echo "rabbit_userid = openstack" >> /etc/ceilometer/ceilometer.conf
RUN echo "rabbit_password = huawei123" >> /etc/ceilometer/ceilometer.conf

RUN echo "[service_credentials]" >> /etc/ceilometer/ceilometer.conf
RUN echo "region_name = RegionOne" >> /etc/ceilometer/ceilometer.conf
RUN echo "interface = internalURL" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_type = password" >> /etc/ceilometer/ceilometer.conf
RUN echo "auth_url = http://10.21.147.126:5001/v3" >> /etc/ceilometer/ceilometer.conf
RUN echo "project_name = service" >> /etc/ceilometer/ceilometer.conf
RUN echo "project_domain_name = default" >> /etc/ceilometer/ceilometer.conf
RUN echo "user_domain_name = default" >> /etc/ceilometer/ceilometer.conf
RUN echo "username = ceilometer" >> /etc/ceilometer/ceilometer.conf
RUN echo "password = huawei123" >> /etc/ceilometer/ceilometer.conf


#Ceilometer API Configuration changes
RUN cp /opt/stack/etc/ceilometer/api_paste.ini /etc/ceilometer/api_paste.ini

##Ceilometer Post Launch Configuration
RUN echo "#!/bin/bash" > /root/postlaunch.sh

#Add starting services to the postlaunch script
#RUN echo "/bin/mongod --dbpath /data/db --fork --logpath /root/mongo.log --noprealloc --smallfiles" >> /root/postlaunch.sh
#RUN echo "/bin/mongo mydb /root/mongosetup.js" >> /root/postlaunch.sh
RUN echo "/usr/bin/ceilometer-collector > collector.log 2>&1 &" >> /root/postlaunch.sh
RUN echo "/usr/bin/ceilometer-api" >> /root/postlaunch.sh
RUN chmod 755 /root/postlaunch.sh

CMD ["/root/postlaunch.sh"]
