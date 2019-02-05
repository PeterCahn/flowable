FROM tomcat:8.5.37

ENV FLOWABLE_VERSION=6.4.1

ADD wait-for-something.sh .

# Download Flowable release, extract and deploy wars to Tomcat
RUN wget https://github.com/flowable/flowable-engine/releases/download/flowable-${FLOWABLE_VERSION}/flowable-${FLOWABLE_VERSION}.zip -O /tmp/flowable-${FLOWABLE_VERSION}.zip && \
    cd /tmp && unzip -q flowable-${FLOWABLE_VERSION}.zip && cp -Rv /tmp/flowable-${FLOWABLE_VERSION}/wars/* ${CATALINA_HOME}/webapps && rm -Rf /tmp/flowable* && \
    chmod +x ${CATALINA_HOME}/wait-for-something.sh && \
    apt-get update && apt-get install -y netcat vim && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${CATALINA_HOME}

# Add PostgreSQL JDBC Driver to Tomcat
ENV POSTGRESQL_DRIVER_VERSION=9.4.1212 
RUN wget http://central.maven.org/maven2/org/postgresql/postgresql/${POSTGRESQL_DRIVER_VERSION}/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar -O ${CATALINA_HOME}/lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar

# Volume where to add personal information about Tomcat and trust stores
VOLUME ["${CATALINA_HOME}/conf-provided"]

#RUN mv conf-provided/server.xml conf/server.xml && \
#    mv conf-provided/tomcat-users.xml > conf/tomcat-users.xml

#ADD tomcat-conf/server.xml conf/server.xml
#ADD tomcat-conf/tomcat-users.xml conf/tomcat-users.xml

ENV JAVA_OPTS="-Xms1024M -Xmx1024M -Djava.security.egd=file:/dev/./urandom -Duser.timezone=Europe/Rome"

EXPOSE 8080

CMD ["bin/catalina.sh", "run""]