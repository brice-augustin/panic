#!/bin/bash

sleep 5

netif=$(ip route | grep default | awk '{print $5}')

ip a flush dev $netif
