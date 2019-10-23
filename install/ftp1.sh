#!/bin/bash

apt-get remove --purge -y vsftpd

apt-get install -y vsftpd

apt-get install -y whois

systemctl start vsftpd

useradd -p $(mkpasswd fortytwo42) -m -s /bin/bash henri

# Pourquoi ?!
arp -d $FTP1_IP

hostnamectl set-hostname ftp1
sed -i "s/^127.0.1.1\s.*/127.0.1.1 ftp1/" /etc/hosts

# dernière commande, ça ferme la session
skill -KILL -u etudiant
