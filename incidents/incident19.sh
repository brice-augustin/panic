#!/bin/bash

beep
beep
beep
beep
beep
beep

exit

# Conflit d'adresse IP

# SSH VM1 et lancer un script qui change l'adresse IP
# 5 secondes plus tard (éviter blocage SSH)
sshpass -p vitrygtr ssh -q -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null etudiant@$IPVM1 \
          "nohup bash -c \"sleep 5; echo vitrygtr | sudo -S ip a flush dev eth0; echo vitrygtr | sudo -S ip a add $NETIP/$NETMASK dev $NETIF\" > /dev/null 2>&1 /dev/null &"

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
