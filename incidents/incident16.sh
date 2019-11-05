#!/bin/bash

sleep 5

# Mauvaise carte réseau
# Solution 1 : dummy, mais ethtool ne voit pas l'interface comme une carte Ethernet
# Solution 3 : veth, mais ip a affiche veth1@veth2

# Solution 2 : bridge
#ip a flush dev $NETIF
#ip a add $NETIP/$NETMASK dev $FAKE_NETIF
# Refusé car $FAKE_NETIF est down
#ip route add default via $GATEWAY dev $FAKE_NETIF

# Solution 4 : bridge avec renommage des interfaces (inversion)

if_list="eth0 eth1 eth2"

netif=$(ip route | grep default | awk '{print $5}')
ip=$(ip -o -4 a list $netif | awk '{print $4}' | cut -d '/' -f1)
netmask="24"

fakeif_list=$(sed -E "s/$netif\s?//" <<< $if_list)
fake_netif1=$(cut -d ' ' -f1 <<< $fakeif_list)
fake_netif2=$(cut -d ' ' -f2 <<< $fakeif_list)

curr_netif=$netif
if [ $(($RANDOM % 2)) -eq 0 ]
then
  new_netif=$fake_netif1
  fake_netif1=$curr_netif
else
  new_netif=$fake_netif2
  fake_netif2=$curr_netif
fi
# Pour les incidents suivants, la vraie
# carte réseau se nomme maintenant $new_netif
netif=$new_netif

# eth0 -> ethtmp
ifdown $curr_netif
ip link set $curr_netif down
ip link set $curr_netif name ethtmp

# eth1 -> eth0
ip link set $new_netif down
ip link set $new_netif name $curr_netif

# ethtmp -> eth1
ip link set ethtmp name $new_netif
ip link set $new_netif up

# Ne pas remettre l'IP sur la fausse carte (ils ne savent pas la retirer)
# TODO an prochain : si ip a flush dans mémo, OK
# ip a add $ip/$netmask dev $curr_netif
# Refusé car $curr_netif est down
#ip route add default via $gw dev $curr_netif

echo "Carte réseau réelle : $netif"
echo "Cartes réseaux bidon : $fake_netif1 $fake_netif2"
