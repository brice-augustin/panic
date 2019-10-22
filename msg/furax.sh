#!/bin/bash

titre='Le boss est furieux'
msg1="Quoi ? Vous avez eu besoin de vous déplacer pour résoudre cet incident ?!"
msg2="Mais attendez, vous croyez que je vais vous payer un billet d'avion toutes les semaines !?"
msg3="La prochaine fois, je retire le prix du billet sur votre salaire."

gxmsg='gxmessage -geometry 900x200+100+100 -name "'$titre'" -ontop \
          -bg "#bcacab" -fg "#ba2421" -fn "serif 20" -wrap -display ":0" \
          "'$msg1'"'

bash -c "$gxmsg &"

sleep 1

gxmsg='gxmessage -geometry 900x200+1000+350 -name "'$titre'" -ontop \
          -bg "#bcacab" -fg "#ba2421" -fn "serif 20" -wrap -display ":0" \
          "'$msg2'"'

bash -c "$gxmsg &"

sleep 1

gxmsg='gxmessage -geometry 900x200+600+600 -name "'$titre'" -ontop \
          -bg "#bcacab" -fg "#ba2421" -fn "serif italic 30" -wrap -display ":0" \
          "'$msg3'"'

bash -c "$gxmsg &"

beep -f 200 -l 500; beep -f 150 -l 500; beep -f 100 -l 500
