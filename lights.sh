#!/bin/sh
# Script used to start a lua script via systemd
cd /home/root/Mercury2014-edison/
luajit led_control.lua
