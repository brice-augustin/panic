#!/bin/bash

# Plus de RAM
# Lancer dans un subshell pour empecher bash d'afficher les notif [pid] et Complété
# stress augmente l'utilisation CPU si la mémoire demandée excède de beaucoup celle disponible
# Plus simple ? x=a; x=$x$x plusieurs fois
(stress --vm-bytes $(($(grep MemFree /proc/meminfo | awk '{print $2}') * 11 / 10))k -m 3 --vm-keep &)
