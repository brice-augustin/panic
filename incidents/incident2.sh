#!/bin/bash

sleep 5

netif=$(ip route | grep default | awk '{print $5}')
ip=$(ip -o -4 a list $netif | awk '{print $4}' | cut -d '/' -f1)
gw=$(ip route | grep default | awk '{print $3}')
# TODO : récupérer le masque depuis ip a
netmask=24

# Mauvaise adresse IP
# Attention, suppose un /24
b12=$(echo $ip | cut -d. -f1,2)
b4=$(echo $ip | cut -d. -f4)
newip=$b12.42.$b4

ip a del $ip dev $netif
ip a add $newip/$netmask dev $netif

# Rajouter manuellement car ip a del vire aussi la gw
# Feinte : indiquer que cette ip est en remise directe sur eth0
# sinon ip route add foire (pas dans le réseau 42)
ip route add $gw/32 dev $netif
ip route add default via $gw

# Autre solution, mettre une fausse gw cohérente avec la nouvelle ip
# ip route add default via $b12.42.1
