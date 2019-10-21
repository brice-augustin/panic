#!/bin/bash

# indique parfois "inactive" alors que le serveur est bien actif ...
#systemctl is-active vsftpd

if ! systemctl status vsftpd | grep " active"
then
  exit 1
fi

exit 0
