#!/bin/bash

set -e
#set -x


docker run \
-it --rm \
-p127.0.0.1:5601:5601 \
--network=elastic \
--name kibana \
-v/tmp/empty:/usr/share/kibana/plugins \
docker.elastic.co/kibana/kibana:5.3.0
