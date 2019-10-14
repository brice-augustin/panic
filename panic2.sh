#!/bin/bash

if [ $EUID -ne 0 ]
then
  echo "Doit être exécuté en tant que root"
  exit
fi

trap ctrl_c INT

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

NETIP=""
GATEWAY=""
NETIF="eth0"
NETMASK="24"
DNS=""
IPVM1=""
FAKE_NETIF="eth1"
FAKE_NETIF2="eth2"
LOGFILE=".panic2.log"

cp[0]="votre boss|C'est une honte, faites preuve d'un peu de professionnalisme."
cp[1]="Manu (un collègue qui aimerait bien vous faire virer)|Je n'ai jamais vu un tel manque de compétence."
cp[2]="votre boss (enervé)|Je ne vous paie pas pour vous tourner les pouces. Vous faites quoi toute la journée, des sudoku ?"
cp[3]="Samantha|On va faire du karting avec les collègues ce soir, tu viens ? Ah non t'es occupé, dommaaaage."
cp[4]="JC (meilleur vendeur depuis 10 ans)|J'ai besoin d'accéder au serveur tout de suite sinon je perds un contrat de 300 000 euros !"
cp[5]="Phil (un collègue)|T'as fait quelle école d'ingé ? Que j'y mette surtout pas mes gosses."
cp[6]="Manu (qui sait tout sur tout)|De toute façon je l'avais bien dit, on ne m'écoute jamais."
cp[7]="Manu (qui sait toujours tout)|A mon avis c'est un problème de DHCP, t'as checké les logs ?"
cp[8]="votre boss (qui a lu Les Réseaux pour les Nuls)|C'est un problème avec notre FAI, c'est évident."
cp[9]="Manu (qui connait tout mieux que tout le monde)|Pourtant les réseaux c'est facile, moi j'aurais réglé ça en 5 minutes."
cp[10]="Franky (un collègue)|Ah la la, j'aimerais pas être à ta place..."
cp[11]="votre boss|Vous devez absolument respecter les SLA ! Chaque heure perdue, c'est 300 kiloeuros d'indémnités qu'on doit aux clients !"
cp[12]="votre boss|Vous n'allez pas passer la journée sur un simple incident ! Pensez à escalader."
cp[13]="Gaston (un collègue)|Il faudrait peut être escalader là, tu perds trop de temps."
cp[14]="Manu (un collègue)|J'ai battu mon record de résolution d'incidents ce matin ! Et toi, t'en es où ?"
cp[15]="votre boss|N'oubliez pas le team meeting dans 5 minutes. J'espère que vous aurez résolu le problème d'ici là !"
cp[16]="Manu (un collègue qui aimerait bien vous faire virer)|Allez laisse tomber, escalade."
cp[17]="Franky (un collègue)|On n'a pas du tout respecté les SLA aujourd'hui, on perd un pognon de dingue. Le boss est furieux !"

# Différencier utilisateur et admin ?
# IP
contexte[1]="Horace (Comptable)|Le serveur Web est en panne."
contexte[2]="Baptiste (Admin système)|T'arrives à faire un SSH sur le serveur toi ?"
# GW
contexte[3]="June (Ingé réseaux)|Je dois mettre à jour le serveur mais apt-get update m'affiche une erreur !"
contexte[4]="Baptiste (Admin système)|Impossible de mettre à jour le serveur SSH, apt-get update marche pas"
# DNS
contexte[5]="June (Ingé réseaux)|Désolée, je voulais consulter \"Stack Overflow\" depuis le serveur, mais impossible. Ce site est bloqué ?"
contexte[6]="Camilo (DSI)|QUI A TOUCHE AU SERVEUR DERNIEREMENT ? IL EST TOUT CASSE, Y A PU INTERNET DESSUS !!! "
# Apache
contexte[7]="June (Ingé réseaux)|Il y a un gros bug ! Les client se plaignent, ils ne peuvent plus accéder au site Web."
contexte[8]="Marion (Département Finance)|Je voulais déclarer un jour de congé sur le site Web mais impossible."
# SSH
contexte[9]="Camilo (DSI)|Oulah, je voulais me connecter au serveur mais on dirait qu'il est dans les choux. Tu t'en occupes ?"
contexte[10]="M. Z (Le boss)|Je suis en déplacement au Panama pour affaires et je n'arrive pas à accéder au serveur."
# RAM/CPU
contexte[11]="Candice (Designer)|C'est hyper lent !"
contexte[12]="Joachim (Accueil)|A mon avis on est en train de se faire DDoSser, le serveur rame énormément."
# dummy
contexte[13]="M. Z (Le boss)|Votre collègue de bureau s'est endormi, réveillez-le."
# erreur de syntaxe
contexte[14]="Camilo (DSI)|J'ai touché à la configuration du serveur FTP et j'ai tout cassé :-( Help !"
# reset de mot de passe
contexte[15]="Henri (Responsable du Bonheur)|Bonjour, J'ai oublié mon mot de passe, vous pouvez me le changer svp ? Mon login sur le serveur est 'henri'. Merci !"
# carte
contexte[16]="June (Ingé réseaux)|J'ai changé une carte réseau sur le serveur (elle était défectueuse), mais maintenat même les pings ne passent plus !"
# carte
contexte[17]="June (Ingé réseaux)|On a perdu l'accès réseau sur le serveur, ethtool indique Link down !!!"
# droits
contexte[18]="Baptiste (Admin système)|J'ai pas les droits pour lire /var/log/auth.log, tu peux changer ça stp ? Mon login est 'sysadmin1'"
# conflit
contexte[19]="Louis (Manageur du management)|Il marche quand il veut, votre nouveau serveur. C'était mieux avant !"

SCORE_DEBUT=1000
SCORE_SUCCES=500
SCORE_PROMOTION=5
SCORE_PLAINTE=-100
SCORE_ERREUR=-200
SCORE_ESCALADE=-500

function ctrl_c() {
  echo ""
  echo -e "** Pour arrêter la partie, vous devez démissionner."
}

function update_score {
  score=$(($score + $1))

  if [ $score -le 0 ]
  then
    echo -e "${RED}Vous êtes muté à Pripiat !${NC}"
    mutation=1
    # Do not allow negative scores
    #score=0
  fi
}

function reset_conf {
  echo -n "Initialisation ."

  rm $LOGFILE &> /dev/null

  # Disable interface
  for iface in $NETIF
  do
    ifdown $iface &>> $LOGFILE
  done

  echo -n "."

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

  # Enable interface
  for iface in $NETIF
  do
    ifup $iface &>> $LOGFILE

    echo -n "."
  done

  apt-get remove --purge -y apache2 &>> $LOGFILE && echo -n "."
  apt-get remove --purge -y vsftpd &>> $LOGFILE && echo -n "."

  apt-get update &>> $LOGFILE
  apt-get install -y apache2 &>> $LOGFILE && echo -n "."
  apt-get install -y openssh-server &>> $LOGFILE && echo -n "."
  apt-get install -y vsftpd &>> $LOGFILE && echo -n "."

  # cp stress grosvirus et attentiondanger (deux noms différents) ?
  apt-get install -y stress &>> $LOGFILE
  apt-get install -y sshpass &>> $LOGFILE
  apt-get install -y beep &>> $LOGFILE
  apt-get install -y ethtool &>> $LOGFILE
  apt-get install -y whois &>> $LOGFILE && echo -n "."

  apt-get install -y gxmessage &>> $LOGFILE
  apt-get install -y bridge-utils &>> $LOGFILE
  apt-get install -y cowsay &>> $LOGFILE

  systemctl start apache2 &>> $LOGFILE && echo -n "."

  echo "<h1>Bienvenue sur le site Web de l'Entreprise !</h1>" > /var/www/html/index.html

  systemctl start ssh &>> $LOGFILE
  systemctl start vsftpd &>> $LOGFILE && echo -n "."

  killall bzip2 &>> $LOGFILE
  killall stress &>> $LOGFILE && echo -n "."

  useradd -p $(mkpasswd fortytwo42) -m -s /bin/bash henri &>> $LOGFILE
  useradd -p $(mkpasswd vitrygtr) -m -s /bin/bash sysadmin1 &>> $LOGFILE

  tc qdisc del dev $NETIF root &>> $LOGFILE && echo -n "."

  brctl addbr $FAKE_NETIF &>> $LOGFILE
  brctl addbr $FAKE_NETIF2 &>> $LOGFILE

  NETIF=$(ip route | grep default | awk '{print $5}')
  NETIP=$(ip -o -4 a list $NETIF | awk '{print $4}' | cut -d '/' -f1)
  GATEWAY=$(ip route | grep default | awk '{print $3}')
  DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')

  echo ""

  echo -n -e "Entrez l'adresse IP de ${GREEN}PC1${NC} : "

  read IPPC1

  # Vérifier que PC1 est accessible
  sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
              -o UserKnownHostsFile=/dev/null etudiant@$IPPC1 \
              "echo vitrygtr | sudo -S echo OK 2> /dev/null"

  if [ $? -ne 0 ]
  then
    echo "Impossible de se connecter à PC1. Fin."
    exit
  fi

  echo -n -e "Entrez l'adresse IP de ${GREEN}VM1${NC} : "

  read IPVM1

  # Vérifier que la VM1 est accessible
  sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
              -o UserKnownHostsFile=/dev/null etudiant@$IPVM1 \
              "echo vitrygtr | sudo -S echo OK 2> /dev/null"

  if [ $? -ne 0 ]
  then
    echo "Impossible de se connecter à la VM1. Fin."
    exit
  fi

  echo -n -e "Entrez l'adresse IP de ${GREEN}DC-1${NC} : "

  read IPWIN1

  # Vérifier que PC1 est accessible
  sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
              -o UserKnownHostsFile=/dev/null administrateur@$IPWIN1 \
              "Write-Host OK"

  if [ $? -ne 0 ]
  then
    echo "Impossible de se connecter à DC-1. Fin."
    exit
  fi

  arp -d $IPVM1 &>> $LOGFILE

  echo $NETIF $NETIP gw $GATEWAY dns $DNS pc1 $IPPC1 vm1 $IPVM1 &>> $LOGFILE
}

function ssh_exec {
  # | Out-Null pour rendre la commande muette ?
  # Tout simplement rediriger la sortie de SSH
  sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
                              -o UserKnownHostsFile=/dev/null "$1" "$2" &> /dev/null
}

reset_conf

echo -n -e "${GREEN}Prêt !${NC} "

n="non"
while [ "$n" != "oui" ]
do
  echo -n "Avant de démarrer la partie, prenez votre temps pour découvrir "
  echo "votre environnement de travail et vous assurer que tout fonctionne bien."

  echo -n "Les tests demandés ont-ils tous réussi ? (oui/non) "

  read n
done

incident_count=0
debut_jeu=$(date +%s)
score=$SCORE_DEBUT
level=0

#facile=$(echo 2 3 5 8 9 12 | tr ' ' '\n' | shuf)
facile=$(echo 13 20 | tr ' ' '\n' | shuf)
moyen=$(echo 4 6 7 10 11 15 16 | tr ' ' '\n' | shuf)
difficile=$(echo 13 14 17 18 19 | tr ' ' '\n' | shuf)

#for defi in $(echo "1 next $facile next $moyen next $difficile")
for defi in $(echo "next $facile next")
do
  solved=0

  if [ "$defi" == "next" ]
  then
    beep -f 400; beep -f 600; beep -f 800;

    level=$(($level + 1))
    echo ""
    # /usr/games pas dans le PATH de root
    /usr/games/cowsay "Vous êtes maintenant Technicien Support de niveau $level."
    echo ""
    echo -e -n "${GREEN}Félicitations !${NC} "
    echo -e -n "Vous obtenez une belle augmentation (${GREEN}+$SCORE_PROMOTION points${NC}) "
    echo "mais vous allez traiter des cas plus difficiles."

    update_score $SCORE_PROMOTION

    continue
  fi

  echo "Attente du prochain incident ..."
  if [ $incident_count -ne 0 ]
  then
    # Temps d'attente aléatoire entre chaque incident
    sleep $((10 + $RANDOM % 50))
  fi

  case $defi in
    1)
      # Pas d'adresse IP
      ip a flush dev $NETIF
      VALIDATION="pingneigh"
      ;;
    2)
      # Mauvaise adresse IP
      # Attention, suppose un /24
      b12=$(echo $NETIP | cut -d. -f1,2)
      b4=$(echo $NETIP | cut -d. -f4)
      newip=$b12.42.$b4

      ip a del $NETIP dev $NETIF &>> $LOGFILE
      ip a add $newip/$NETMASK dev $NETIF

      # Rajouter manuellement car ip a del vire aussi la gw
      # Feinte : indiquer que cette ip est en remise directe sur eth0
      # sinon ip route add foire (pas dans le réseau 42)
      ip route add $GATEWAY/32 dev $NETIF
      ip route add default via $GATEWAY

      # Autre solution, mettre une fausse gw cohérente avec la nouvelle ip
      # ip route add default via $b12.42.1
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
      sed -i 's/nameserver .*/nameserver 8.8.8.8/' /etc/resolv.conf
      VALIDATION="resolv"
      ;;
    7)
      # Apache stoppé
      systemctl stop apache2 &>> $LOGFILE
      VALIDATION="wwwup"
      ;;
    8)
      # Apache pas installé
      apt-get remove --purge -y apache2 &>> $LOGFILE
      apt autoremove -y &>> $LOGFILE
      VALIDATION="wwwup"
      ;;
    9)
      # SSH stoppé
      systemctl stop sshd &>> $LOGFILE
      VALIDATION="sshup"
      ;;
    10)
      # SSH pas installé
      apt-get remove --purge -y openssh-server &>> $LOGFILE
      apt autoremove -y &>> $LOGFILE
      VALIDATION="sshup"
      ;;
    11)
      # Plus de RAM
      # Lancer dans un subshell pour empecher bash d'afficher les notif [pid] et Complété
      # stress augmente l'utilisation CPU si la mémoire demandée excède de beaucoup celle disponible
      # Plus simple ? x=a; x=$x$x plusieurs fois
      (stress --vm-bytes $(($(grep MemFree /proc/meminfo | awk '{print $2}') * 11 / 10))k -m 3 --vm-keep &) &>> $LOGFILE
      VALIDATION="mem"
      ;;
    12)
      # CPU 100%
      #while true; do echo -n ""; done &
      #stress -c 10
      # Occuper tous les cpu
      for i in {1..9}
      do
        # Lancer dans un subshell pour empecher bash d'afficher les notif [pid] et Complété
        (nice -n -20 bzip2 -9 < /dev/urandom &) &>> $LOGFILE
      done
      VALIDATION="cpu"
      ;;
    13)
      # Resolution sans intervention
      VALIDATION=""
      ;;
    14)
      # Erreur de syntaxe
      sed -E -i 's/^[# ]?write_enable=.*$/write_enable=NON/' /etc/vsftpd.conf
      systemctl restart vsftpd &>> $LOGFILE

      VALIDATION="ftpup"
      ;;
    15)
      # Demande de reset de mot de passe
      henri_pass=$(grep "^henri:" /etc/shadow)
      VALIDATION="chgpass"
      ;;
    16|17)
      # Mauvaise carte réseau
      # Solution 1 : dummy, mais ethtool ne voit pas l'interface comme une carte Ethernet
      # Solution 3 : veth, mais ip a affiche veth1@veth2

      # Solution 2 : bridge
      #ip a flush dev $NETIF
      #ip a add $NETIP/$NETMASK dev $FAKE_NETIF
      # Refusé car $FAKE_NETIF est down
      #ip route add default via $GATEWAY dev $FAKE_NETIF

      # Solution 4 : bridge avec renommage des interfaces (inversion)
      CURR_NETIF=$NETIF
      if [ $(($RANDOM % 2)) -eq 0 ]
      then
        NEW_NETIF=$FAKE_NETIF
        FAKE_NETIF=$CURR_NETIF
      else
        NEW_NETIF=$FAKE_NETIF2
        FAKE_NETIF2=$CURR_NETIF
      fi
      # Pour les incidents suivants, la vraie
      # carte réseau se nomme maintenant eth1
      NETIF=$NEW_NETIF

      # eth0 -> ethtmp
      ifdown $CURR_NETIF &>> $LOGFILE
      ip link set $CURR_NETIF down
      ip link set $CURR_NETIF name ethtmp

      # eth1 -> eth0
      ip link set $NEW_NETIF down
      ip link set $NEW_NETIF name $CURR_NETIF

      # ethtmp -> eth1
      ip link set ethtmp name $NEW_NETIF
      ip link set $NEW_NETIF up

      ip a add $NETIP/$NETMASK dev $CURR_NETIF &>> $LOGFILE
      # Refusé car $NETIF est down
      #ip route add default via $GATEWAY dev $CURR_NETIF

      echo "Carte réseau réelle : $NETIF" &>> $LOGFILE
      echo "Cartes réseaux bidon : $FAKE_NETIF $FAKE_NETIF2" &>> $LOGFILE

      VALIDATION="pingneigh pingdns"
      ;;
    18)
      # Demande de droits supplémentaires
      VALIDATION="addgrp"
      ;;
    19)
      # Conflit d'adresse IP

      # SSH VM1 et lancer un script qui change l'adresse IP
      # 5 secondes plus tard (éviter blocage SSH)
      sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
                -o UserKnownHostsFile=/dev/null etudiant@$IPVM1 \
                "nohup bash -c \"sleep 5; echo vitrygtr | sudo -S ip a flush dev $NETIF; echo vitrygtr | sudo -S ip a add $NETIP/$NETMASK dev $NETIF\" > /dev/null 2>&1 /dev/null &"

      # L'entrée est forcément présente, on vient de faire un ssh
      vm1mac=$(arp -an $IPVM1 | cut -d ' ' -f 4)

      # Ajouter une entrée statique pour VM1
      # Problème que ça résout : une fois que VM1 a changé d'IP (pris celle du serveur),
      # serveur continue de vouloir dialoguer avec son ancienne IP (pour fermer connexions TCP ?).
      # Il envoie des requêtes ARP pour résoudre l'ancienne adresse de VM1 et du coup "pollue"
      # le cache du PC admin avec son adresse MAC (alors que ce qu'on veut, c'est que le cache du
      # PC admin contienne l'adresse MAC de VM1 pour que le conflit d'IP ait un effet visible.
      arp -s $IPVM1 $vm1mac &>> $LOGFILE

      # Ajouter un delai sur tous les paquets (un peu bourrin)
      # Le but est juste de retarder les réponses ARP pour que la VM1 réponde avant
      # Sous windows, la DERNIERE réponse est prise en compte.
      # Du coup scénario suivant sur PC admin :
      # Reponse ARP de VM1
      # TCP/IP sur PC admin commence à préparer SYN (connexion depuis navigateur Web)
      # Reponse ARP de serveur arrive et met à jour cache !!!
      # Trame contenant SYN part avec MAC de serveur (et pas VM1 comme on souhaite :-(
      # Solution : délai plus important (300 ms ?)
      tc qdisc add dev $NETIF root netem delay 100ms &>> $LOGFILE

      # Lancer un serveur Web fictif
      # Problème que ça résout : si PC admin sous Windows
      # (politique ARP = prise en compte de la dernière) ce dernier envoie SYN à VM1 qui répond
      # par RST plusieurs fois; pendant ce temps ARP reply du serveur arrive (retardée par tc)
      # et màj cache ARP; envoi SYN avec MAC de serveur qui répond :-(
      # TODO : le lancer slt si il n'existe pas déjà
      # Curieux : pas d'erreur de nc si apache déjà attaché au port 80 ! les proc se "partagent"
      # le port et répondent "chacun leur tour" aux requêtes
      sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
                  -o UserKnownHostsFile=/dev/null etudiant@$IPVM1 \
                  "echo vitrygtr | sudo -S nohup bash -c 'while true; do nc -l -p 80; sleep 1; done' &> /dev/null &"

      # SSH PC1 et effacer l'entrée ARP pour serveur 5 secondes plus tard
      # Sinon PC1 il ARP request regulièrement juste pour rafraichir
      # (utilise la MAC du serveur comme adresse de dst)
      # donc vm1 ne peut pas y repondre ...
      sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
                  -o UserKnownHostsFile=/dev/null etudiant@$IPPC1 \
                  "nohup bash -c \"sleep 5; echo vitrygtr | sudo -S arp -d $NETIP\" > /dev/null 2>&1 /dev/null &"

      VALIDATION="dupip"
      ;;
    20)
      ssh_exec administrateur@$IPWIN1 "Remove-NetFirewallRule -DisplayName 'Autoriser ICMPv4'"
      ssh_exec administrateur@$IPWIN1 "New-NetFirewallRule -DisplayName 'Autoriser ICMPv4' -Direction Inbound -Protocol ICMPv4 -Action Block"
      VALIDATION="pingwin"
      ;;
    *)
      echo Défi : "erreur"
      ;;
  esac

  incident_count=$(($incident_count + 1))

  d=$(date +%Hh%M)

  beep -f 600; beep -f 600; beep -f 600;

  num1=$(echo $(($RANDOM % 1000)))
  num2=$(awk 'BEGIN{printf "%c%c", '$((65 + $RANDOM % 10))','$((65 + $RANDOM % 10))'}')
  incident_num=$num1$num2$defi

  echo ""
  echo ""
  echo -e "Il est $d, ${RED}nouvel incident${NC} (Ticket #$incident_num) :"

  echo "Description :"
  echo "-----------"
  if [[ ${contexte[$defi]} ]]
  then
    from=$(echo ${contexte[$defi]} | cut -d '|' -f 1)
    msg=$(echo ${contexte[$defi]} | cut -d '|' -f 2)
  else
    from="Anonyme"
    msg="Ben ça marche plus."
  fi
  echo "De : $from"
  echo "Message : $msg"
  echo "-----------"

  echo "Dépêchez-vous de traiter cet incident avant qu'on ne vous tombe dessus !"
  echo "Quand le problème est reglé, tapez \"ok\" pour valider."

  debut_incident=$(date +%s)
  prochain_cp=$(($debut_incident + 180))

  while [ $solved -eq 0 ]
  do
    echo -n "[Niveau $level : $score points] "

    d=$(($prochain_cp - $(date +%s)))
    if [ $d -lt 0 ]
    then
      d=0
    fi
    read -t $d cmd

    read_result=$?

    # Pas d'input utilisteur
    if [ $read_result -ne 0 ]
    then
      beep -f 600; beep -f 600; beep -f 600
      titre="Toc toc toc quelqu'un vient vous voir pour se plaindre !"
      wall -n $titre

      pression=${cp[$(($RANDOM % ${#cp[@]}))]}
      from=$(echo $pression | cut -d'|' -f1)
      msg=$(echo $pression | cut -d'|' -f2)
      d=$(date +%Hh%M)
      echo ""
      echo "!---!---!---!---!---!"
      echo -e "A $d, vous recevez la visite de ${RED}$from${NC} :"
      echo -e "\"$msg\""
      echo "!---!---!---!---!---!"

      # A part 3 incidents (pas d'ip, conflit), le PC admin est
      # toujours accessible.
      # Si c'est le cas, lancer le "coup de pression" sur ce dernier car
      # c'est ce PC que le joueur sera en train d'utiliser !
      gxmsg='gxmessage -center -geometry 800x400 -name "'$titre'" -ontop \
          -bg "#bcacab" -fg "#ba2421" -fn "serif italic 20" -wrap -display ":0" \
          "A '$d', vous recevez la visite de '$from' : '$'\n\n''\"'$msg'\""'

      sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
                -o UserKnownHostsFile=/dev/null etudiant@$IPPC1 \
                "$gxmsg &> /dev/null &"

      # Si PC admin inaccessible, lancer sur le serveur
      if [ $? -ne 0 ]
      then
        bash -c "$gxmsg &>> $LOGFILE &"
      fi

      update_score $SCORE_PLAINTE

      # Heure du prochain coup de pression
      prochain_cp=$(($(date +%s) + 180))

      continue
    fi

    case "$cmd" in
      dem)
        echo "Démission acceptée."
        exit
        ;;
      ok|esc)
        solved=1

        if [ "$cmd" == ok ]
        then
          echo "Validation en cours ..."
        else
          echo "Escalade ..."
        fi

        for t in $VALIDATION
        do
          case "$t" in
            pinggw)
              echo ping gw
              ;;
            pingdns)
              ping -c 1 -w 2 $DNS &>> $LOGFILE

              if [ $? -ne 0 ]
              then
                solved=0
              fi
              ;;
            pingneigh)
              ping -c 1 -w 2 $IPVM1 &>> $LOGFILE

              if [ $? -ne 0 ]
              then
                solved=0
              fi
              ;;
            pingwin)
              ping -c 1 -w 2 $IPWIN1 &>> $LOGFILE

              if [ $? -ne 0 ]
              then
                solved=0
              fi
              ;;
            resolv)
              host www.google.com &>> $LOGFILE

              if [ $? -ne 0 ]
              then
                solved=0
              fi
              ;;
            wwwup)
              systemctl is-active apache2 &>> $LOGFILE

              if [ $? -ne 0 ]
              then
                solved=0
              fi
              ;;
            sshup)
              # indique parfois "inactive" alors que le serveur est bien actif ...
              #systemctl is-active sshd > /dev/null 2>&1

              if ! systemctl status sshd | grep " active" &>> $LOGFILE
              then
                solved=0
              fi
              ;;
            ftpup)
              if ! systemctl status vsftpd | grep " active" &>> $LOGFILE
              then
                solved=0
              fi
              ;;
            mem)
              ps aux | grep stress | grep -v grep &>> $LOGFILE

              if [ $? -eq 0 ]
              then
                solved=0
              fi
              ;;
            cpu)
              ps aux | grep bzip2 | grep -v grep &>> $LOGFILE

              if [ $? -eq 0 ]
              then
                solved=0
              fi
              ;;
            dupip)
              # Vérifier que la VM1 a récupéré son IP légitime
              # Bof bof comme test ... et si elle en obtient une autre entretemps ?
              ping -c 1 -w 2 $IPVM1 &>> $LOGFILE

              if [ $? -ne 0 ]
              then
                solved=0
              else
                # Annuler le retard de paquets
                tc qdisc del dev $NETIF root &>> $LOGFILE

                # Effacer l'entrée ARP statique
                arp -d $IPVM1 &>> $LOGFILE
              fi
              ;;
            chgpass)
              new_pass=$(grep "^henri:" /etc/shadow)

              if [ $henri_pass == $new_pass ]
              then
                solved=0
              fi
              ;;
            addgrp)
              if ! groups sysadmin1 | grep -E " adm( |$)"
              then
                solved=0
              fi
              ;;
            *)
              ;;
            esac # case validation
        done

        if [ $solved -eq 1 ]
        then
          # beep joyeux ?

          fin_incident=$(date +%s)
          ttr[$defi]=$((($fin_incident - $debut_incident) / 60))

          if [ "$cmd" == ok ]
          then
            echo -e "${GREEN}Bravo${NC} ! Il vous a fallu ${ttr[$defi]} minutes pour traiter cet incident."

            echo "Vous pouvez souffler un peu."

            update_score $SCORE_SUCCES
          else
            echo "Votre N+1 a règlé le problème."
            update_score $SCORE_ESCALADE
          fi

          echo -n "Rédigez le rapport d'incident puis appuyez sur Entrée pour continuer ..."

          read -t 120 x

          if [ $? -ne 0 ]
          then
            beep
            echo ""
            echo "Vous prenez trop de temps pour rédiger votre rapport !"
          fi
        else
          echo -e "${RED}Le problème persiste !${NC} Les utilisateurs s'impatientent ..."

          if [ "$cmd" == ok ]
          then
            update_score $SCORE_ERREUR
          fi
        fi
        ;;
    esac # case cmd
  done # while solved
done # for defi

fin_jeu=$(date +%s)
duree_jeu=$((($fin_jeu - $debut_jeu) / 60))
echo ""
echo ""
echo -e "${GREEN}Hourra${NC} ! Vous avez traité $incident_count incidents en moins de $duree_jeu minutes !"

avg_ttr=$(printf "%s\n" "${ttr[@]}" | awk '{ total += $1; count++ } END { print total/count }')
min_ttr=$(printf "%s\n" "${ttr[@]}" | awk 'min=="" || $1 < min {min=$1} END{print min}')
max_ttr=$(printf "%s\n" "${ttr[@]}" | awk 'max=="" || $1 > max {max=$1} END{print max}')

echo -e "min/moy/max = $min_ttr/$avg_ttr/$max_ttr minutes"

echo -e "Votre score est de ${GREEN}$score${NC} points."

if [ $mutation ]
then
  echo -e "Vous êtes tout de même ${RED}muté à Pripiat${NC}. Faites vos bagages demain !"
fi

for i in $(seq 1 ${#contexte[@]})
do
  echo "$i ${ttr[$i]}" &>> $LOGFILE
done
