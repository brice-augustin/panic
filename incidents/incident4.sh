#!/bin/bash

gw=$(ip route | grep default | awk '{print $3}')

b123=$(echo $gw | cut -d. -f1-3)
ip route del default
ip route add default via $b123.42
