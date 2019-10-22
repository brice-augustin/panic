#!/bin/bash

titre='Retrait sur salaire'
msg1="Je vous avais prévenu. Vous avez droit à un retrait sur salaire."

gxmsg='gxmessage -center -geometry 900x200 -name "'$titre'" -ontop \
          -bg "#bcacab" -fg "#ba2421" -fn "serif italic 30" -wrap -display ":0" \
          "'$msg1'"'

bash -c "$gxmsg &"

beep -f 200 -l 500; beep -f 150 -l 500; beep -f 100 -l 1000
