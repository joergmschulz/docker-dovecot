#!/bin/bash

for i in exim-external exim-int-mailout exim-ext-mailout ; do echo $i && docker compose exec $i /usr/exim/bin/exim -C /etc/exim/config.d/exim.conf -q -v ; done