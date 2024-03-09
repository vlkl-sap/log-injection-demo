#!/bin/bash

set -e
#set -x


docker run \
-u "$(id -u):$(id -g)" -it --rm \
--network=elastic \
--name logstash \
-e HOME=/workspace \
-v "$(pwd)":/workspace -w /workspace \
docker.elastic.co/logstash/logstash:5.0.0 logstash --path.data logstash.data -f logstash.conf
