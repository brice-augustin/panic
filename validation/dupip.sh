#!/bin/bash

beep
beep
beep
beep
beep
beep

exit

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
