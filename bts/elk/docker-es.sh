#!/bin/bash

set -e
#set -x


#sysctl -w vm.max_map_count=262144


docker run \
-it --rm \
--network=elastic \
--name elasticsearch \
-v/tmp/empty:/usr/share/elasticsearch/plugins \
docker.elastic.co/elasticsearch/elasticsearch:5.3.0  

