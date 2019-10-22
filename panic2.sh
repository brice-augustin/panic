#!/bin/bash

if [ $EUID -ne 0 ]
then
  echo "Doit être exécuté en tant que root"
  exit
fi

trap ctrl_c INT

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\e[1m'
NC='\033[0m'

export WWW1_IP=""
export FTP1_IP=""
export DC1_IP=""
export DNS_IP=""

LOGFILE=".panic2.log"

PANIC_GLOBAL='$WWW1_IP:$FTP1_IP:$DC1_IP:$DNS_IP'

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
contexte[1]="Horace (Comptable)|Le serveur Web est en panne.|1|www1|ssh|l"
contexte[2]="Baptiste (Admin système)|T'arrives à faire un SSH sur WWW1 toi ?|2|www1|ssh|l"
# GW
contexte[3]="June (Ingé réseaux)|Je dois mettre à jour le serveur mais apt-get update m'affiche une erreur !|3|www1|pingdns|l"
contexte[4]="Baptiste (Admin système)|Impossible de mettre à jour le serveur SSH, apt-get update marche pas|4|www1|pingdns|l"
# DNS
contexte[5]="June (Ingé réseaux)|Désolée, je voulais consulter \"Stack Overflow\" depuis le serveur, mais impossible. Ce site est bloqué ?|5|www1|resolv|l"
contexte[6]="Camilo (DSI)|QUI A TOUCHE AU SERVEUR DERNIEREMENT ? IL EST TOUT CASSE, Y A PU INTERNET DESSUS !!!|6|www1|resolv|l"
# Apache
contexte[7]="June (Ingé réseaux)|Il y a un gros bug ! Les client se plaignent, ils ne peuvent plus accéder au site Web.|7|www1|wwwup|r"
contexte[8]="Marion (Département Finance)|Je voulais déclarer un jour de congé sur le site Web mais impossible.|8|www1|wwwup|r"
# SSH
contexte[9]="Camilo (DSI)|Oulah, je voulais me connecter au serveur mais on dirait qu'il est dans les choux. Tu t'en occupes ?|9|www1|sshup|l"
contexte[10]="M. Z (Le boss)|Je suis en déplacement au Panama pour affaires et je n'arrive pas à accéder au serveur.|10|www1|sshup|l"
# RAM/CPU
contexte[11]="Candice (Designer)|C'est hyper lent !|11|www1|mem|r"
contexte[12]="Joachim (Accueil)|A mon avis on est en train de se faire DDoSser, le serveur rame énormément.|12|www1|cpu|r"
# dummy
contexte[13]="M. Z (Le boss)|Votre collègue de bureau s'est endormi, réveillez-le.|13|www1||r"
# erreur de syntaxe
contexte[14]="Camilo (DSI)|J'ai touché à la configuration du serveur FTP et j'ai tout cassé :-( Help !|14|ftp1|ftpup|r"
# reset de mot de passe
contexte[15]="Henri (Responsable du Bonheur)|Bonjour, J'ai oublié mon mot de passe, vous pouvez me le changer svp ? Mon login sur le serveur est 'henri'. Merci !|15|www1|chgpass|r"
# carte
contexte[16]="June (Ingé réseaux)|J'ai changé une carte réseau sur le serveur (elle était défectueuse), mais maintenant même les pings ne passent plus !|16|www1|pingdns|l"
# carte
contexte[17]="June (Ingé réseaux)|On a perdu l'accès réseau sur le serveur, ethtool indique Link down !!!|16|www1|pingdns|l"
# droits
contexte[18]="Baptiste (Admin système)|J'ai pas les droits pour lire /var/log/auth.log, tu peux changer ça stp ? Mon login est 'sysadmin1'|18|www1|addgrp|r"
# conflit
contexte[19]="Louis (Manageur du management)|Il marche quand il veut, votre nouveau serveur. C'était mieux avant !|19XX|XXX|dupipXXX|l"
# firewall Windows
contexte[20]="June (Ingé réseaux)|Le serveur DC-1 ne répond même plus aux pings. A mon avis il est mort, il faut le remplacer !|20|dc1|ssh|r"
# DNS windows
contexte[21]="Baptiste (Admin système)|T'as bloqué internet sur DC-1 ou quoi ?|21|dc1|resolv|r"
# capa réseau windows
contexte[22]="Camilo (DSI)|Le serveur DC-1 génère beaucoup de trafic réseau, il doit être infecté par un virus.|22|dc1|winprocess|r"
# erreur de syntaxe interfaces
contexte[23]="Baptiste (Admin système)|J'ai voulu mettre FTP1 en adressage statique et j'ai tout cassé ! Même ifdown m'affiche une erreur :-(|23|ftp1|pingdns|l"
# disable interface
contexte[24]="Camilo (DSI)|Je suivais un tuto pour renouveler le bail DHCP sur DC-1 et tout d'un coup j'ai perdu la main. Pourtant j'ai tout bien fait  ... il est nul cet OS !!|24|dc1|ssh|l"

SCORE_DEBUT=1000
SCORE_SUCCES=500
SCORE_PROMOTION=5
SCORE_PLAINTE=-100
SCORE_ERREUR=-200
SCORE_ESCALADE=-500
SCORE_DEPLACEMENT=-200

ATTENTE_MAX=50
ATTENTE_MAX=1

DUREE_PAUSE=5
NOMBRE_PAUSE=2

DEPLACEMENT_INUTILE=1

TEMPS_RAPPORT=120

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

# ssh_exec user@srv cmd
function ssh_exec {
  srv=$(cut -d '@' -f 2 <<< $1)

  if ! ping -c 1 -w 2 $srv &>> $LOGFILE
  then
    return 1
  fi

  # | Out-Null pour rendre la commande muette ?
  # Tout simplement rediriger la sortie de SSH
  sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
                              -o UserKnownHostsFile=/dev/null "$1" "$2" &>> $LOGFILE
}

# ssh_send file user@srv
function ssh_send {
  srv=$(cut -d '@' -f 2 <<< $2)

  if ! ping -c 1 -w 2 $srv &>> $LOGFILE
  then
    return 1
  fi

  sshpass -p vitrygtr scp -q -o StrictHostKeyChecking=no \
                              -o UserKnownHostsFile=/dev/null "$1" "$2": &>> $LOGFILE
}

function reset_conf {
  rm $LOGFILE &> /dev/null

  # Installer gxmessage sur le PC d'administration
  apt update -y &> /dev/null
  apt install -y gxmessage &> /dev/null
  apt install -y cowsay &> /dev/null
  apt install -y sshpass &> /dev/null

  echo -n -e "Entrez l'adresse IP de ${GREEN}WWW1${NC} : "

  read WWW1_IP

  # Vérifier que WWW1 est accessible
  ssh_exec etudiant@$WWW1_IP "echo OK"

  if [ $? -ne 0 ]
  then
    echo "Impossible de se connecter à WWW1. Fin."
    exit
  fi

  ssh_send validation/monitor.sh etudiant@$WWW1_IP
  ssh_send install/www1.sh etudiant@$WWW1_IP
  ssh_exec etudiant@$WWW1_IP "nohup sudo ./www1.sh &> /dev/null &"

  echo -n -e "Entrez l'adresse IP de ${GREEN}FTP1${NC} : "

  read FTP1_IP

  # Vérifier que FTP1 est accessible
  ssh_exec etudiant@$FTP1_IP "echo OK"

  if [ $? -ne 0 ]
  then
    echo "Impossible de se connecter à la FTP1. Fin."
    exit
  fi

  ssh_send install/ftp1.sh etudiant@$FTP1_IP
  ssh_exec etudiant@$FTP1_IP "nohup sudo ./ftp1.sh &> /dev/null &"

  echo -n -e "Entrez l'adresse IP de ${GREEN}DC-1${NC} : "

  read DC1_IP

  # Vérifier que DC1 est accessible
  ssh_exec administrateur@$DC1_IP "Write-Host OK"

  if [ $? -ne 0 ]
  then
    echo "Impossible de se connecter à DC-1. Fin."
    exit
  fi

  echo -n "Initialisation ."

  # Comment détacher complètement un processus fils d'une session sous Windows ?
  # (équivalent de nohup)
  ssh_send install/nohup.ps1 administrateur@$DC1_IP

  ssh_send install/dc1.ps1 administrateur@$DC1_IP
  # Attention DC-1 redémarre à la fin du script
  ssh_exec administrateur@$DC1_IP "./nohup.ps1 ./dc1.ps1"

  DNS_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')

  echo "www1 $WWW1_IP ftp1 $FTP1_IP dc1 $DC1_IP dns $DNS_IP" &>> $LOGFILE

  while ! ssh_exec etudiant@$WWW1_IP "ls READY"
  do
    echo -n '.'
    sleep 2
  done

  echo ""
}

function check_intervention {
  ssh_exec etudiant@$WWW1_IP './monitor.sh'

  # Moniteur allumé
  if [ $? -ne 0 ]
  then
    if [ $DEPLACEMENT_INUTILE -gt 0 ]
    then
      ./msg/furax.sh
    else
      ./msg/retrait.sh
      update_score $SCORE_DEPLACEMENT
    fi
    DEPLACEMENT_INUTILE=$(($DEPLACEMENT_INUTILE - 1))
  fi
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

facile=$(echo 2 3 5 8 9 12 21 24 | tr ' ' '\n' | shuf)
moyen=$(echo 4 6 7 10 11 15 16 20 22 | tr ' ' '\n' | shuf)
# 19
difficile=$(echo 13 14 17 18 23 | tr ' ' '\n' | shuf)

for defi in $(echo "1 next $facile next $moyen next $difficile")
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

    sleep 15

    continue
  fi

  ssh_exec etudiant@$WWW1_IP 'DISPLAY=":0" xset dpms force off'

  echo "Attente du prochain incident ..."
  if [ $incident_count -ne 0 ]
  then
    # Temps d'attente aléatoire entre chaque incident
    sleep $((10 + $RANDOM % $ATTENTE_MAX))
  fi

  if [[ ! ${contexte[$defi]} ]]
  then
    echo "Pas de contexte pour le defi $defi. Fin."
    exit
  fi

  incident_id=$(cut -d '|' -f 3 <<< ${contexte[$defi]})
  target=$(cut -d '|' -f 4 <<< ${contexte[$defi]})
  validation=$(cut -d '|' -f 5 <<< ${contexte[$defi]})
  intervention=$(cut -d '|' -f 6 <<< ${contexte[$defi]})

  case $target in
    www1)
      ext='sh'
      user='etudiant'
      ip=$WWW1_IP
      nohup='nohup'
      sudo_cmd='sudo '
      suffix=' &> /dev/null &'
      ;;
    ftp1)
      ext='sh'
      user='etudiant'
      ip=$FTP1_IP
      nohup='nohup'
      sudo_cmd='sudo '
      suffix=' &> /dev/null &'
      ;;
    dc1)
      ext='ps1'
      user='administrateur'
      ip=$DC1_IP
      nohup='./nohup.ps1'
      sudo_cmd=''
      suffix=''
      ;;
    *)
      echo "Serveur cible inconnu. Fin."
      exit
      ;;
  esac

  if [ ! -f incidents/incident$incident_id.* ]
  then
    echo "L'incident $incident_id n'est pas défini. Fin."
  fi

  envsubst "$PANIC_GLOBAL" < incidents/incident$incident_id.* > incident.$ext
  chmod +x incident.$ext

  ssh_send incident.$ext $user@$ip

  # Ajouter " &> /dev/null &" sous Linux ?!
  ssh_exec $user@$ip "$sudo_cmd$nohup ./incident.$ext$suffix"

  rm incident.$ext
  # TODO : supprimer le script sur l'ordinateur distant ?
  # Non car il est peut être encore en train de s'exécuter !

  sleep 5

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
  echo -e "Message : ${BLUE}${BOLD}$msg${NC}"
  echo "-----------"
  echo ""

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

      # Lancer le "coup de pression" sur le PC d'admin car
      # c'est ce PC que le joueur sera en train d'utiliser !
      #gxmessage -center -geometry 800x400 -name "$titre" -ontop \
      #    -bg "#bcacab" -fg "#ba2421" -fn "serif italic 20" -wrap -display ":0" \
      #    "A $d, vous recevez la visite de $from : \n\n\"$msg\"" &>> $LOGFILE &
      gxmsg='gxmessage -center -geometry 800x400 -name "'$titre'" -ontop \
          -bg "#bcacab" -fg "#ba2421" -fn "serif italic 20" -wrap -display ":0" \
          "A '$d', vous recevez la visite de '$from' : '$'\n\n''\"'$msg'\""'

      bash -c "$gxmsg &>> $LOGFILE &"

      update_score $SCORE_PLAINTE

      # Heure du prochain coup de pression
      prochain_cp=$(($(date +%s) + 180))

      continue
    fi

    case "$cmd" in
      pause)
        if [ $NOMBRE_PAUSE -gt 0 ]
        then
          echo ""
          echo -e -n "Vous pouvez prendre une pause de ${GREEN}$DUREE_PAUSE${NC} minutes ..."

          sleep $(($DUREE_PAUSE * 60))

          beep -f 500; beep -f 500; beep -f 500
          NOMBRE_PAUSE=$(($NOMBRE_PAUSE - 1))

          echo ""
          echo "Pause terminée ! Il vous en reste $NOMBRE_PAUSE."

          # Recalculer l'heure du prochain coup de pression.
          # Sinon le joueur reçoit systématiquement un CP en revenant de sa pause.
          prochain_cp=$(($(date +%s) + 180))
        else
          echo -e "Vous avez déjà pris assez de pauses ! ${RED}Au boulot !${NC}"
        fi
        ;;
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

        for t in $validation
        do
          if [ ! -f validation/$t.$ext ]
          then
            echo "La validation $t n'existe pas. Fin."
            exit
          fi

          envsubst "$PANIC_GLOBAL" < validation/$t.$ext > validation.$ext
          chmod +x validation.$ext

          ssh_send validation.$ext $user@$ip

          ssh_exec $user@$ip "$sudo_cmd./validation.$ext"

          if [ $? -ne 0 ]
          then
            solved=0
          fi

          rm validation.$ext
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

            if [ "$intervention" == "r" ]
            then
              check_intervention
            fi
          else
            echo "Votre N+1 a règlé le problème."
            update_score $SCORE_ESCALADE
          fi

          echo -n "Rédigez le rapport d'incident puis appuyez sur Entrée pour continuer ..."

          read -t $TEMPS_RAPPORT x

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
