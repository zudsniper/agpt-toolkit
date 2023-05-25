#!/bin/bash
# utilities.sh 
# -------------
# 
# Full of miscellaneous unrelated functions 
# 
# --------------
# by @zudsniper & ChatGPT
# --------------

# Loading spinner
function spinner {
   local pid=$1
   local delay=0.1
   local spin_chars="⠇⠋⠙⠸⠴⠦⠇⠋⠙⠸⠴⠦"
   local spin_len=${#spin_chars}
   local idx=0
   echo -en "\e[?25l" # hide cursor
   while kill -0 $pid >/dev/null 2>&1; do
       local c="${spin_chars:$idx:1}"
       echo -en "$2$c$reset "
       idx=$(( (idx + 1) % spin_len ))
       sleep $delay
       echo -en "\b\b\b\b\b\b"
   done
   echo -en "\e[?25h" # show cursor
   wait $pid
   return $?
}

