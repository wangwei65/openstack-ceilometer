FROM python:2.7.12
MAINTAINER wangwei

# This Dockerfile installs the following components of Ceilometer in a Docker Image
 
ENV CEILOMETER_VERSION 6.0.0

#Timestamps are always useful
RUN date > /root/date

LABEL version="$CEILOMETER_VERSION"

#RUN pip install tox
RUN apt-get -y update && apt-get install -y  python-pip python-dev libmysqlclient-dev python-setuptools git gcc && apt-get -y clean
#RUN pip install tox

WORKDIR /opt
#Clone Ceilometer
RUN git clone -b ${CEILOMETER_VERSION} http://github.com/openstack/ceilometer.git  /opt/stack/

RUN pip install mysql-python

#Ceilometer Collector Configuration
WORKDIR /opt/stack
RUN pip install -r requirements.txt && PBR_VERSION=${CEILOMETER_VERSION} python setup.py install
#RUN python setup.py install

RUN mkdir -p /etc/ceilometer

#RUN tox -egenconfig
RUN cp /opt/stack/etc/ceilometer/*.json /etc/ceilometer
RUN cp /opt/stack/etc/ceilometer/*.yaml /etc/ceilometer
#RUN cp /opt/stack/etc/ceilometer/ceilometer.conf.sample /etc/ceilometer/ceilometer.conf

#RUN pip install python-openstackclient

#Ceilometer Collector Configuration changes
#RUN sed -ri 's/#metering_secret=change this or be hacked/metering_secret=redhat/' /etc/ceilometer/ceilometer.conf
COPY /etc/meters.yaml /etc/ceilometer/meters.yaml
COPY /etc/ceilometer.conf /etc/ceilometer/ceilometer.conf


#Ceilometer API Configuration changes
RUN cp /opt/stack/etc/ceilometer/api_paste.ini /etc/ceilometer/api_paste.ini

##Ceilometer Post Launch Configuration
RUN echo "#!/bin/bash" > /root/postlaunch.sh

RUN echo "/usr/local/bin/ceilometer-collector > collector.log 2>&1 &" >> /root/postlaunch.sh
RUN echo "/usr/local/bin/ceilometer-api > api.log" >> /root/postlaunch.sh
RUN chmod 755 /root/postlaunch.sh

CMD ["/root/postlaunch.sh"]
