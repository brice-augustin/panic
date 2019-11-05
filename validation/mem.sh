#!/bin/bash

VIRUS='megavirus'

! ps aux | grep $VIRUS | grep -v grep
