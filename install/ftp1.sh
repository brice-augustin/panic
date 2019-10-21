#!/bin/bash

apt-get remove --purge -y vsftpd

apt-get install -y vsftpd

systemctl start vsftpd

# Pourquoi ?!
arp -d $FTP1_IP &>> $LOGFILE
