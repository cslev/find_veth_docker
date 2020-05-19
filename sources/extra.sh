#!/bin/bash

#COLORIZING

#===================   COLORIZING  OUTPUT =================
declare -A colors
colors=(
  [None]='\033[0m'
  [Bold]='\033[01m'
  [Disable]='\033[02m'
  [Underline]='\033[04m'
  [Reverse]='\033[07m'
  [Strikethrough]='\033[09m'
  [Invisible]='\033[08m'
  [Black]='\033[0;30m'        # Black
  [Red]='\033[0;31m'          # Red
  [Green]='\033[0;32m'        # Green
  [Yellow]='\033[0;33m'       # Yellow
  [Blue]='\033[0;34m'         # Blue
  [Purple]='\033[0;35m'       # Purple
  [Cyan]='\033[0;36m'         # Cyan
  [White]='\033[0;37m'        # White
  # Bold
  [BBlack]='\033[1;30m'       # Black
  [BRed]='\033[1;31m'         # Red
  [BGreen]='\033[1;32m'       # Green
  [BYellow]='\033[1;33m'      # Yellow
  [BBlue]='\033[1;34m'        # Blue
  [BPurple]='\033[1;35m'      # Purple
  [BCyan]='\033[1;36m'        # Cyan
  [BWhite]='\033[1;37m'       # White
  # Underline
  [UBlack]='\033[4;30m'       # Black
  [URed]='\033[4;31m'         # Red
  [UGreen]='\033[4;32m'       # Green
  [UYellow]='\033[4;33m'      # Yellow
  [UBlue]='\033[4;34m'        # Blue
  [UPurple]='\033[4;35m'      # Purple
  [UCyan]='\033[4;36m'        # Cyan
  [UWhite]='\033[4;37m'       # White
)
num_colors=${#colors[@]}
# -----------------------------------------------------------


# ==================== USE THIS FUNCTION TO PRINT TO STDOUT =============
# $1: color  - if not exists, then normal output is used
# $2: text to print out
# $3: no_newline - if nothing is provided newline will be printed at the end
#                 - anything provided, NO newline is indicated
function c_print ()
{
  color=$1
  text=$2
  no_newline=$3

  #if color exists/defined in the array
  if [[ ${colors[$color]} ]]
  then
    text_to_print="${colors[$color]}${text}${colors[None]}" #colorized output
  else
    text_to_print="${text}" #normal output
  fi

  if [ -z "$no_newline" ]
  then
    echo -e $text_to_print # newline at the end
  else
    echo -en $text_to_print # NO newline at the end
	fi

}


function check_retval ()
{
  retval=$1
  if [ $retval -ne 0 ]
  then
    c_print "BRed" "[FAIL]"
    exit -1
  else
    c_print "BGreen" "[DONE]"
  fi
}
