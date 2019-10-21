#!/bin/bash

sed -E -i 's/^[# ]?write_enable=.*$/write_enable=NON/' /etc/vsftpd.conf
systemctl restart vsftpd
