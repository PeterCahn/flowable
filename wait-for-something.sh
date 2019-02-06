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
	
# Adding provided truststore to JVM truststore
if [ -f $CATALINA_HOME/conf-provided/flowable.ts ] ; then
    echo "Adding provided truststore to JVM trustore..."
    keytool -noprompt -importkeystore -srckeystore $CATALINA_HOME/conf-provided/flowable.ts -destkeystore $JAVA_HOME/lib/security/cacerts -srcstorepass mypass -deststorepass changeit
fi

exec $cmd
