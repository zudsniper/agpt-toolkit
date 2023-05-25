#!/bin/bash
# setup.sh 
# ----------
# 
# This file handles downloading the arbitrary color files I use, as well as all bootstrapping silliness 
# to ensure stuff exists where it must and such
# It also holds constants

# VERSION
VERSION="0.1.6"

# URLS 
export AUTOGPT_ENV_TEMPLATE_RAW_URL="https://raw.githubusercontent.com/Significant-Gravitas/Auto-GPT/master/.env.template"
export ANSI_COLORS_FILEPATH="https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh"


# STATIC COLORS  
# TODO 
# These should be phased out completely but remain for compatability
red="\e[91m" 
green="\e[92m"
yellow="\e[93m"
blue="\e[94m"
magenta="\e[95m"
cyan="\e[96m"
bold="\033[1m"
bgWhite="\033[47m"
bgPurple="\033[45m"
bgBlue="\033[44m"
bgYellow="\033[43m"
bgRed="\033[41m"
bgPinkRed="\033[105m"
reset="\033[0m"

# ----------------------------- #
## ANSI COLOR ENVIRONMENT VARS

# [WARNING] this is very zod.tf specific
# Check if .ansi_colors.sh exists, and if not, download it from Github
if [ ! -f "$HOME/.ansi_colors.sh" ]; then
  echo "${green}Downloading ${bold}.ansi_colors.sh${reset}..."
  curl -sSf ${ANSI_COLORS_FILEPATH} > "$HOME/.ansi_colors.sh"
fi

# source the colors
. "$HOME/.ansi_colors.sh"
# ----------------------------- #
