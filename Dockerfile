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
#RUN pip install tox==1.6.1
RUN yum install python-pbr git python-devel python-setuptools python-pip gcc gcc-devel libxml2-python libxslt-python python-lxml sqlite python-repoze-lru openssl -y

WORKDIR /opt
#Clone Ceilometer
RUN git clone http://github.com/openstack/ceilometer.git

#Ceilometer Collector Configuration
WORKDIR /opt/stack
RUN python setup.py install
RUN mkdir -p /etc/ceilometer
#RUN tox -egenconfig
RUN cp /opt/stack/etc/ceilometer/*.json /etc/ceilometer
RUN cp /opt/stack/etc/ceilometer/*.yaml /etc/ceilometer
RUN cp /opt/stack/etc/ceilometer/ceilometer.conf.sample /etc/ceilometer/ceilometer.conf

#Ceilometer Collector Configuration changes
RUN sed -ri 's/#metering_secret=change this or be hacked/metering_secret=redhat/' /etc/ceilometer/ceilometer.conf
RUN sed -ri 's/#connection=<None>/connection = mongodb:\/\/admin:insecure@localhost:27017\/ceilometer/' /etc/ceilometer/ceilometer.conf

#Ceilometer API Configuration changes
RUN cp etc/ceilometer/api_paste.ini /etc/ceilometer/api_paste.ini

##Ceilometer Post Launch Configuration
RUN echo "#!/bin/bash" > /root/postlaunch.sh

#Add starting services to the postlaunch script
#RUN echo "/bin/mongod --dbpath /data/db --fork --logpath /root/mongo.log --noprealloc --smallfiles" >> /root/postlaunch.sh
#RUN echo "/bin/mongo mydb /root/mongosetup.js" >> /root/postlaunch.sh
RUN echo "/usr/bin/ceilometer-collector" >> /root/postlaunch.sh
RUN echo "/usr/bin/ceilometer-api" >> /root/postlaunch.sh
RUN chmod 755 /root/postlaunch.sh
