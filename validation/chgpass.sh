#!/bin/bash

new_pass=$(grep "^henri:" /etc/shadow)

henri_pass=$(cat /tmp/henri_pass)

test $henri_pass != $new_pass
