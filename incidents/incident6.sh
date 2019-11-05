#!/bin/bash

# Sur le réseau Adista 8.8.8.8 est dorénavant accessible !
sed -i 's/nameserver .*/nameserver 172.16.30.42/' /etc/resolv.conf
