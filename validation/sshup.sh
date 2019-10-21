#!/bin/bash

# indique parfois "inactive" alors que le serveur est bien actif ...
#systemctl is-active sshd

if ! systemctl status sshd | grep " active"
then
  exit 1
fi

exit 0
