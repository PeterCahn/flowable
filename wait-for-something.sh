#!/bin/bash
set -e

host="$1"
port="$2"
description="$3"
shift 3
cmd="$@"

until nc -z "$host" "$port"; do
    echo "$description is unavailable - sleeping"
    sleep 1
done

>&2 echo "$description is up - executing command"

# Replacing Tomcat custom configuration from volume
if [ -f $CATALINA_HOME/conf-provided/server.xml ] ; then
	cp -f $CATALINA_HOME/conf-provided/server.xml $CATALINA_HOME/conf/server.xml
fi
if [ -f $CATALINA_HOME/conf-provided/tomcat-users.xml ] ; then
	cp -f $CATALINA_HOME/conf-provided/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml
fi

# Add manager.xml to enable access of Tomcat manager webapp 
if [ -f $CATALINA_HOME/conf-provided/manager.xml ] ; then
	mkdir -p $CATALINA_HOME/conf/Catalina/localhost
	cp -f $CATALINA_HOME/conf-provided/manager.xml $CATALINA_HOME/conf/Catalina/localhost
fi
	
# Add provided truststore to JVM truststore
if [ -f $CATALINA_HOME/conf-provided/flowable.ts ] ; then
    echo "Adding provided truststore to JVM trustore..."
    keytool -noprompt -importkeystore -srckeystore $CATALINA_HOME/conf-provided/flowable.ts -destkeystore $JAVA_HOME/lib/security/cacerts -srcstorepass mypass -deststorepass changeit
fi

# Add provided crt and conf for connecting to KDC
if [ -f $CATALINA_HOME/conf-provided/freeipa/ca.crt -a -f $CATALINA_HOME/conf-provided/freeipa/krb5.conf ] ; then
	cp $CATALINA_HOME/conf-provided/freeipa/ca.crt /etc/ipa
	cp $CATALINA_HOME/conf-provided/freeipa/krb5.conf /etc/
fi

# Replace flowable-idm url
if [ -n "$FLOWABLE_IDM_HOSTNAME" ] ; then
    if [ -z "$FLOWABLE_IDM_PORT" ] ; then
		FLOWABLE_IDM_PORT=8080
	fi
	sed -i 's/flowable.common.app.idm-url=.*/flowable.common.app.idm-url=http:\/\/'$FLOWABLE_IDM_HOSTNAME':'$FLOWABLE_IDM_PORT'\/flowable-idm/' $CATALINA_HOME/webapps/flowable-*/WEB-INF/classes/flowable-default.properties
fi

exec $cmd
