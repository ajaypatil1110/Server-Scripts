#!/bin/bash

#-----------------------------------------------------------------------
#
#  F L U S H _ C A C H E _ M E M O R Y  . S H
#
#  Flush cached memory
#
#-----------------------------------------------------------------------

sync; echo 3 > /proc/sys/vm/drop_caches 2>&1
exit 0
