#!/bin/bash

for i in exim-external exim-int-mailout exim-ext-mailout ; do docker compose exec $i /usr/exim/bin/exim -C /etc/exim/config.d/exim.conf -bp ; done
