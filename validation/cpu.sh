#!/bin/bash

VIRUS='grosvirus'

! ps aux | grep $VIRUS | grep -v grep
