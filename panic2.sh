#!/bin/bash

if [ $EUID -ne 0 ]
then
  echo "Doit être exécuté en tant que root"
  exit
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

NETIP=""
GATEWAY=""
NETIF="enp0s3"
NETMASK="24"
DNS=""
IPVM1=""

cp[0]="votre boss|C'est une ${RED}honte${NC}."
cp[1]="Manu (un collègue qui aimerait bien vous faire virer)|Je n'ai jamais vu ça."
cp[2]="votre boss (enervé)|Je ne vous paie pas pour vous tourner les pouces. Vous faites quoi toute la journée, des sudoku ?"
cp[3]="Samantha|On va faire du karting avec les collègues, tu viens ? Ah non t'es occupé, dommaaaage."
cp[4]="JC (meilleur vendeur depuis 10 ans)|J'ai besoin d'accéder au serveur tout de suite sinon je perds un contrat de 300 000 euros !"
cp[5]="Phil (un collègue)|T'as fait quelle école d'ingé ? Que j'y mette surtout pas mes gosses."
cp[6]="Manu (qui sait tout sur tout)|De toute façon je l'avais bien dit, on ne m'écoute jamais."
cp[7]="Manu (qui sait toujours tout)|A mon avis c'est un problème de DHCP, t'as checké les logs ?"
cp[8]="votre boss (qui a lu Les Réseaux pour les Nuls)|C'est un problème avec notre FAI, c'est évident."
cp[9]="Manu (qui connait tout mieux que tout le monde)|Pourtant les réseaux c'est facile, moi j'aurais réglé ça en 5 minutes."

contexte[11]="C'est hyper lent !"
contexte[14]="Votre collègue de bureau s'est endormi, réveillez-le."

if false # DEBUG
then
# Disable interface
for iface in $NETIF
do
  ifdown $iface > /dev/null 2>&1
done

# Tout configurer correctement
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces

#ethif=$(ip -o l show | awk -F': ' '{print $2}' | grep -E "^(eth|en)")

# /sys/class/net/eth0/operstate (up ou down)
for iface in $NETIF
do
  echo "auto $iface" >> /etc/network/interfaces
  echo "iface $iface inet dhcp" >> /etc/network/interfaces
done

# pour dev du script, virer ensuite
echo "auto enp0s8" >> /etc/network/interfaces
echo "iface enp0s8 inet dhcp" >> /etc/network/interfaces

# Enable interface
for iface in $NETIF
do
  ifup $iface > /dev/null 2>&1
done
fi # DEBUG fin if false

NETIF=$(ip route | grep default | awk '{print $5}')
NETIP=$(ip -o -4 a list $NETIF | awk '{print $4}' | cut -d '/' -f1)
GATEWAY=$(ip route | grep default | awk '{print $3}')
DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
IPVM1="10.10.164.75"
echo -e "${RED}TODO : Demander l'adresse IP de VM1${NC}"

echo $NETIF $NETIP gw $GATEWAY dns $DNS

incident_count=0

#for defi in $(seq 1 10 | shuf)
for defi in $(echo 7 14)
do
  solved=0

  case $defi in
    1)
      # Pas d'adresse IP
      ip a flush dev $NETIF
      VALIDATION="pingneigh"
      ;;
    2)
      # Mauvaise adresse IP
      b12=$(echo $NETIP | cut -d. -f1,2)
      b4=$(echo $NETIP | cut -d. -f4)
      newip=$b12.42.$b4

      ip a del $NETIP dev $NETIF > /dev/null 2>&1
      ip a add $newip/$NETMASK dev $NETIF
      # Rajouter manuellement car ip a del vire aussi la gw
      ip route add default via $GATEWAY
      VALIDATION="pingneigh"
      ;;
    3)
      # Pas de passerelle
      ip route del default
      # resolv plutot que pingdns ?
      VALIDATION="pingdns"
      ;;
    4)
      # Mauvaise passerelle
      b123=$(echo $GATEWAY | cut -d. -f1-3)
      ip route del default
      ip route add default via $b123.42
      VALIDATION="pingdns"
      ;;
    5)
      # Pas de DNS
      sed -i '/nameserver/d' /etc/resolv.conf
      VALIDATION="resolv"
      ;;
    6)
      # Mauvais DNS
      # Autre erreur : nameserver dns.u-pec.fr
      sed 's/nameserver .*/nameserver 8.8.8.8/' /etc/resolv.conf
      VALIDATION="resolv"
      ;;
    7)
      # Apache stoppé
      systemctl stop apache2
      VALIDATION="wwwup"
      ;;
    8)
      # Apache pas installé
      apt-get remove --purge apache2
      apt autoremove
      VALIDATION="wwwup"
      ;;
    9)
      # SSH stoppé
      systemctl stop sshd
      VALIDATION="sshup"
      ;;
    10)
      # Apache pas installé
      apt-get remove --purge openssh-server
      apt autoremove
      VALIDATION="sshup"
      ;;
    11)
      # Plus de RAM
      # Lancer dans un subshell pour empecher bash d'afficher les notif [pid] et Complété
      (stress --vm-bytes $(($(grep MemFree /proc/meminfo | awk '{print $2}') * 2))k -m 1 --vm-keep &) &> /dev/null
      VALIDATION="mem"
      ;;
    12)
      # CPU 100%
      #while true; do echo -n ""; done &
      #stress -c 10
      (bzip2 -9 < /dev/urandom &) &> /dev/null
      VALIDATION="cpu"
      ;;
    13)
      # Conflit d'adresse IP
      # SSH VM1 et lancer un script qui change l'adresse IP
      # 5 secondes plus tard (éviter blocage SSH)
      echo "conflit IP"

      sshpass -p vitrygtr ssh -o StrictHostKeyChecking=no \
                              -o UserKnownHostsFile=/dev/null etudiant@$IPVM1 \
                              "nohup bash -c \"sleep 5; echo vitrygtr | sudo -S ip a flush dev $NETIF; echo vitrygtr | sudo -S ip a add $NETIP/$NETMASK dev $NETIF\" > /dev/null 2>&1 /dev/null &"
      VALIDATION="dupip"
      ;;
    14)
      # Resolution sans intervention
      echo "resoliton sans intefventon"
      VALIDATION=""
      ;;
    *)
      echo Défi : "erreur"
      ;;
  esac

  incident_count=$(($incident_count + 1))

  d=$(date +%Hh%M)

  beep -f 600; beep -f 600; beep -f 600;

  echo ""
  echo ""
  echo -e "Il est $d, ${RED}nouvel incident${NC} (Ticket #$incident_count) :"

  echo "Description :"
  echo "-----------"
  if [[ ${contexte[$defi]} ]]
  then
    echo ${contexte[$defi]}
  else
    echo "Ben ça marche plus."
  fi
  echo "-----------"

  echo -e "Dépêchez-vous de traiter cet incident avant qu'on ne vous tombe dessus !"
  echo ""

  debut_incident=$(date +%s)

  while [ $solved -eq 0 ]
  do
    echo "Appuyez sur Entrée pour tester"
    read -t 180 n

    read_result=$?

    # Pas d'input utilisteur
    if [ $read_result -ne 0 ]
    then
      beep -f 600; beep -f 600; beep -f 600
      wall -n "Toc toc toc quelqu'un vient vous voir pour se plaindre !"

      pression=${cp[$(($RANDOM % ${#cp[@]}))]}
      from=$(echo $pression | cut -d'|' -f1)
      msg=$(echo $pression | cut -d'|' -f2)
      d=$(date +%Hh%M)
      echo ""
      echo "!---!---!---!---!---!"
      echo -e "A $d, vous recevez la visite de ${RED}$from${NC} :"
      echo -e "\"$msg"\"
      echo "!---!---!---!---!---!"

      continue
    fi

    solved=1

    for t in $VALIDATION
    do
      case "$t" in
        pinggw)
          echo ping gw
          ;;
        pingdns)
          echo ping dns
          ip=$DNS
          # XXX DEBUG
          ip=8.8.8.8
          ping -c 1 -w 2 $ip > /dev/null 2>&1

          if [ $? -ne 0 ]
          then
            solved=0
          fi
          ;;
        pingneigh)
          echo ping neighbor
          ;;
        resolv)
          host www.google.com > /dev/null 2>&1

          if [ $? -ne 0 ]
          then
            solved=0
          fi
          ;;
        wwwup)
          systemctl is-active apache2 > /dev/null 2>&1

          if [ $? -ne 0 ]
          then
            solved=0
          fi
          ;;
        sshup)
          systemctl is-active sshd > /dev/null 2>&1

          if [ $? -ne 0 ]
          then
            solved=0
          fi
          ;;
        mem)
          ps aux | grep stress | grep -v grep > /dev/null 2>&1

          if [ $? -eq 0 ]
          then
            solved=0
          fi
          ;;
        cpu)
          ps aux | grep bzip2 | grep -v grep > /dev/null 2>&1

          if [ $? -eq 0 ]
          then
            solved=0
          fi
          ;;
        dupip)
          ping -c 1 -w 2 $IPVM1 > /dev/null 2>&1

          if [ $? -ne 0 ]
          then
            solved=0
          fi
          ;;
        *)
          ;;
        esac
    done

    if [ $solved -eq 1 ]
    then
      echo -e "${GREEN}Bravo${NC}"
      fin_incident=$(date +%s)
      ttr=$((($fin_incident - $debut_incident) / 60))
      echo "Il vous a fallu $ttr minutes pour traiter cet incident"

      echo "Vous pouvez souffler un peu ..."

      # beep joyeux ?
      sleep 10
    else
      echo -e "${RED}Essaie encore${NC}"
    fi
  done
done
