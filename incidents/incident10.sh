#!/bin/bash

apt-get remove --purge -y openssh-server
apt autoremove -y
