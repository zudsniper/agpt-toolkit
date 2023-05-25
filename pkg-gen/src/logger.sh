#!/bin/bash
# logger.sh 
# ----------
# 
# This is my scuffed logger!!! nice 
# TODO 
#     Replace with modern .ansi_colors.sh function calls. 


# ======================== # 
#     LOGGER FUNCTIONS

function info() {
  echo -e "${bgWhite}${bold}[INFO] ${reset}$1"
}

function debug() {
  echo -e "${bgPurple}${bold}[DEBUG] ${reset}$1"
}

function http() {
  echo -e "${bgBlue}${bold}[HTTP] ${reset}$1"
}

function warn() {
  echo -e "${bgYellow}${bold}[WARN] ${reset}$1"
}

function error() {
  echo -e "${bgRed}${bold}[ERROR] ${reset}$1"
}

function critical() {
  echo -e "${bgPinkRed}${bold}[CRITICAL] ${reset}$1"
}
