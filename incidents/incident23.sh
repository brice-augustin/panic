#!/bin/bash

sleep 5

netif=$(ip route | grep default | awk '{print $5}')
ip=$(ip -o -4 a list $netif | awk '{print $4}' | cut -d '/' -f1)
gw=$(ip route | grep default | awk '{print $3}')
netmask="24"

killall dhclient
# Comme ça ifdown ne libère pas le bail DHCP
ip a flush dev $netif

ifdown $netif
sed -i "/$netif/d" /etc/network/interfaces

echo iface $netif inet static >> /etc/network/interfaces
echo "  address $ip/$netmask" >> /etc/network/interfaces
echo "  gateway $gw/$netmask" >> /etc/network/interfaces

# Brrr ... welcome to inconsistent land!
ifup eth0
