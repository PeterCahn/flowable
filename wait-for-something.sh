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
mv conf-provided/server.xml conf/server.xml
mv conf-provided/tomcat-users.xml conf/tomcat-users.xml

exec $cmd
