sed -i "s/CONN_DB_TYPE/$CONN_DB_TYPE/g" /etc/ceilometer/ceilometer.conf	
sed -i "s/CONN_DB_USER/$CONN_DB_USER/g" /etc/ceilometer/ceilometer.conf
sed -i "s/CONN_DB_PASSWORD/$CONN_DB_PASSWORD/g" /etc/ceilometer/ceilometer.conf	
sed -i "s/CONN_DB_NAME/$CONN_DB_NAME/g" /etc/ceilometer/ceilometer.conf
sed -i "s/CONN_DB_HOST/$CONN_DB_HOST/g" /etc/ceilometer/ceilometer.conf
sed -i "s/KEYSTONE_HOST/$KEYSTONE_HOST/g" /etc/ceilometer/ceilometer.conf
sed -i "s/PROJECT_DOMAIN_NAME/$PROJECT_DOMAIN_NAME/g" /etc/ceilometer/ceilometer.conf
sed -i "s/USER_DOMAIN_NAME/$USER_DOMAIN_NAME/g" /etc/ceilometer/ceilometer.conf
sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" /etc/ceilometer/ceilometer.conf
sed -i "s/KEYSTONE_USER/$KEYSTONE_USER/g" /etc/ceilometer/ceilometer.conf
sed -i "s/KEYSTONE_PASSWORD/$KEYSTONE_PASSWORD/g" /etc/ceilometer/ceilometer.conf
sed -i "s/AUTH_TYPE/$AUTH_TYPE/g" /etc/ceilometer/ceilometer.conf
sed -i "s/RABBIT_USERID/$RABBIT_USERID/g" /etc/ceilometer/ceilometer.conf
sed -i "s/RABBIT_PASSWORD/$RABBIT_PASSWORD/g" /etc/ceilometer/ceilometer.conf
sed -i "s/RABBIT_HOST/$RABBIT_HOST/g" /etc/ceilometer/ceilometer.conf
sed -i "s/REGION_NAME/$REGION_NAME/g" /etc/ceilometer/ceilometer.conf
sed -i "s/INTERFACE/$INTERFACE/g" /etc/ceilometer/ceilometer.conf

/usr/local/bin/ceilometer-collector > collector.log 2>&1 &
/usr/local/bin/ceilometer-api > api.log
