FROM tomcat:8.5.37

ENV FLOWABLE_VERSION=6.4.1

# Download Flowable release, extract and deploy wars to Tomcat
RUN wget https://github.com/flowable/flowable-engine/releases/download/flowable-${FLOWABLE_VERSION}/flowable-${FLOWABLE_VERSION}.zip -O /tmp/flowable-${FLOWABLE_VERSION}.zip && \
    cd /tmp && unzip -q flowable-${FLOWABLE_VERSION}.zip && cp -Rv /tmp/flowable-${FLOWABLE_VERSION}/wars/* ${CATALINA_HOME}/webapps && rm -Rf /tmp/flowable* && \
    apt-get update && apt-get install -y netcat vim && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add FreeIPA client (custom requirement)
RUN echo "deb http://httpredir.debian.org/debian/ sid main" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive; apt-get install --no-install-recommends -y freeipa-client openssh-client sshpass && \
    apt-get clean &&  rm -rf /var/lib/apt/lists/* /var/tmp && \
    sed -i '/deb http:\/\/httpredir.debian.org\/debian\/ sid main/d' /etc/apt/sources.list
	
WORKDIR ${CATALINA_HOME}

# Add PostgreSQL JDBC Driver to Tomcat
ENV POSTGRESQL_DRIVER_VERSION=9.4.1212 
RUN wget http://central.maven.org/maven2/org/postgresql/postgresql/${POSTGRESQL_DRIVER_VERSION}/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar -O lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar

ADD wait-for-something.sh .
RUN chmod +x ${CATALINA_HOME}/wait-for-something.sh

# Volume where to add personal information about Tomcat and trust stores
VOLUME ["${CATALINA_HOME}/conf-provided"]

ENV JAVA_OPTS="-Xms1024M -Xmx1024M -Djava.security.egd=file:/dev/./urandom -Duser.timezone=Europe/Rome"

EXPOSE 8080

CMD ["bin/catalina.sh", "run" ]
