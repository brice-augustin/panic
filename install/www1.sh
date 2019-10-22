#!/bin/bash

sleep 5

###
# Reset
###

rm READY

real_netif='eth0'
if_list='eth0 eth1 eth2'

netif=$(ip route | grep default | awk '{print $5}')

fakeif_list=$(sed -E "s/$netif\s?//" <<< $if_list)
fake_netif1=$(cut -d ' ' -f1 <<< $fakeif_list)
fake_netif2=$(cut -d ' ' -f2 <<< $fakeif_list)

# Disable interface
for iface in $netif
do
  ifdown $iface
done

ip link set $fake_netif1 down
ip link set $fake_netif2 down

brctl delbr $fake_netif1
brctl delbr $fake_netif2

if [ $netif != $real_netif ]
then
  ip link set $netif name $real_netif
  netif=$real_netif
fi

apt-get remove --purge -y apache2

killall bzip2
killall stress

tc qdisc del dev $netif root

###
# Config
###
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces

#ethif=$(ip -o l show | awk -F': ' '{print $2}' | grep -E "^(eth|en)")

# /sys/class/net/eth0/operstate (up ou down)
for iface in $netif
do
  echo "auto $iface" >> /etc/network/interfaces
  echo "iface $iface inet dhcp" >> /etc/network/interfaces
done

# Enable interface
for iface in $netif
do
  ifup $iface
done

apt-get update
apt-get install -y apache2
apt-get install -y openssh-server

# cp stress grosvirus et attentiondanger (deux noms différents) ?
apt-get install -y stress
apt-get install -y beep
apt-get install -y ethtool
apt-get install -y whois

apt-get install -y bridge-utils

systemctl start apache2

echo "<h1>Bienvenue sur le site Web de l'Entreprise !</h1>" > /var/www/html/index.html

dd if=/dev/zero of=/var/www/html/gros bs=1k seek=1M count=1

systemctl start ssh
systemctl start vsftpd

useradd -p $(mkpasswd fortytwo42) -m -s /bin/bash henri
useradd -p $(mkpasswd vitrygtr) -m -s /bin/bash sysadmin1

brctl addbr $fake_netif1
brctl addbr $fake_netif2

touch READY

#DISPLAY=":0" xset dpms force off
