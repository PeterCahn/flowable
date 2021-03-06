# Flowable Docker image
This repository contains the Dockerfile and the related files to run an instance of [Flowable](https://www.flowable.org/) on Docker.

It takes inspiration from the Flowable offical repository on [GitHub](https://github.com/flowable/flowable-engine) and in particular from the Flowable [all-in-one](https://github.com/flowable/flowable-engine/tree/master/docker/all-in-one) image from which it takes its structure.

## Architecture
The image is based on the official Tomcat image (see [GitHub](https://github.com/docker-library/tomcat) and [Docker Cloud](https://hub.docker.com/_/tomcat)) which comes with Java.

It contains all Flowable components (*all-in-one*: Flowable IDM, Modeler, Task, Admin, REST).

The image uses PostgreSQL as Flowable storage instead of the standard H2 database. 
* Tomcat: *8.5.37*
* Flowable: *6.4.1*
* PostgreSQL: *9.6* (JDBC PostgreSQL Connector: *9.4.1212*)

## Build
If you want to build a different version of Flowable (check [here](https://github.com/flowable/flowable-engine/releases)), run the following commands:
*   ```bash
    git clone https://github.com/PeterCahn/flowable.git
    ```
*   ```bash
    docker build --build-arg FLOWABLE_VERSION=<version> -t flowable:<version> .
    ```
    where *version* is the new version you want to build and then run.

You can also change the PostgreSQL JDBC Connector version by adding to ```docker build``` an other *build-arg* as the following:

``` Dockerfile
--build-arg POSTGRESQL_DRIVER_VERSION=<postgresql-jdbc-connector-version>
```
The adoption of a different PostgreSQL version will be added in the next releases.

## Execution

### Volumes

Before running the image you may need to add volumes to Flowable for persistence. 

* ```/var/lib/postgresql/data```
    This is the volume required by the [official PostgreSQL Docker](https://hub.docker.com/_/postgres/) image for persistence. The volume is suggested as it stores data and metadata generated by Flowable, included its process definitions which will remain after restarting or deleting the container.
* ```/usr/local/tomcat/conf-provided```
    In this volumes you can store different Tomcat configuration files. The actual supported files are:
    * *server.xml*
    To specify information about connectors (e.g enable SSL communication over HTTPS)
    * *tomcat-users.xml*
    To add users and roles to Tomcat (e.g. ad-hoc user with the caability to reach the *manager* page)
        * *manager.xml*
        To specify detail about manager webapp (i.e. which remote addresses are allowed)
    * *flowable.ts*
    This is the truststore which is added to the *cacerts* of the JVM. Import into this file the public certificates of nodes in the network that FLowable needs to reach.
* ```/etc/security/keytabs```
A volume to store keytabs for hosts authentication (if needed).

### Run

Use the `all-in-one-postgres.sh` script to `start`, `stop` or print `info` to the standard output of both PostgreSQL and Flowable:

 	./all-in-one-postgres.sh start
 	./all-in-one-postgres.sh stop
 	./all-in-one-postgres.sh info

P.S. If you have built the image, please change the image name into `docker-compose.yml` to the one that you have created (e.g. ```image: flowable:<version> ```).
