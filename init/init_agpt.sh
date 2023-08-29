#!/bin/bash
# init_agpt.sh v5.3.0
# ------------
#
# This script will initialize the redis server for AutoGPT
#      then start the AutoGPT instance of name $1
# ---------------------------------------------------------
# MAKE SURE YOU SET YOUR REDIS ENVIRONMENT VARIABLES WITHIN YOUR CONFIGURATION!
# it may be `config.json` or `.env`, or some other way.
#
# by @zudsniper
# Modified by ChatGPT


# last autogpt version with redis memory support
export AGPT_VERSION="0.3.1"

#############################################
#                CLI COLORS 
#############################################

# ANSI color codes
A_RED='\033[0;31m'
A_GREEN='\033[0;32m'
A_YELLOW='\033[0;33m'
A_BLUE='\033[0;34m'
A_LIGHTGRAY='\033[0;37m'
A_RESET='\033[0m'
A_BOLD='\033[1m'
A_UNDERLINE='\033[4m'
A_INVERSE='\033[7m'
A_ITALIC='\033[3m'


#############################################
#              ERROR HANDLING
#############################################
# Error handling
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
echo_error() {
    echo -e "${A_RED}Error: ${last_command} exited with status $?${A_RESET}" >&2
}
trap echo_error ERR


# SMALL LOGGER 
log() {
    echo -e "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "${LOG_FILE_PATH}"
}

#############################################
#            HELP / USAGE PRINT
#############################################
# Helper function for printing help message
print_help() {
  echo -e "${A_BOLD}${A_UNDERLINE}Usage:${A_RESET}"
  echo -e "  ${A_BOLD}./init_agpt.sh${A_RESET} [options]"
  #echo -e "  ${A_BOLD}./pause.sh${A_RESET} [options]\n"
  echo -e "${A_BOLD}${A_UNDERLINE}Options:${A_RESET}"
  echo -e "  -h, --help                          Display this help message"
  echo -e "  -b, --agpt-branch <branch_name>     Use the specified branch_name for the Auto-GPT repository"
  echo -e "  -pv, --py-virtualenv <env_path>     Use the specified Python virtual environment path"
  echo -e "  -d, --docker-compose-alias <alias>  Use the specified alias for docker-compose commands"
  echo -e "  -c, --commands <commands>           Append extra commands to the last docker.compose call"
  echo -e "  -v, --verbose                       Enable verbose output"
  echo -e "  -f, --force                         Force remove conflicting images without prompt"
  echo -e "  -y, --yes                           Agree to all prompts"
  echo -e "  -mv, --move-main <new_name>         Rename conflicting main image instead of deleting"
  echo -e "  -rc, --redis-clear                  Clear the Redis image on startup if set."
  echo -e "  -dd, --docker-install               Force the reinstallation of docker and docker compose."
  echo -e "\n${A_BOLD}${A_UNDERLINE}pause.sh Options:${A_RESET}"
  echo -e "  -h, --help          Display this help message"
  echo -e "  -l, --leave         Leave the interactive terminal instance after pausing"
  echo -e "  -h, --halt          Fully delete the docker image and stop the redis image"
}

# DEPENDENCIES 
APT_PACKAGES=() # this should be ignored b/c venv? idk
	# Yes, this should be ignored because of `venv`. In short, don't use this to install `python`, `python3`, or any `python3.x`.
	# Best bet is to use a virtualenv with python version 3.10.11
SNAP_PACKAGES=()
NPM_PACKAGES=()  # Replace with your npm package names
PIP_PACKAGES=()  # Replace with your pip package names

# DEFAULTS FOR VARS
AGPT_PATH="Auto-GPT"
DOCKER_COMPOSE_ALIAS="docker-compose"
AGPT_CONTAINER_NAME="auto-gpt"
REDIS_CONTAINER_NAME="redis"
REDIS_PORT=6379
REDIS_CLEAR=1
PYTHON_VENV="venv"
AGPT_BRANCH="master"
EXTRA_DOCKER_COMPOSE_COMMANDS=""
VERBOSE=0

# DERIVED  
MAIN_PATH="${PWD}/${AGPT_PATH}/"

# EPOCH 
TIMESTUMP=$(date +%s)

LOG_FILE_PATH="/${MAIN_PATH}/logs/${AGPT_CONTAINER_NAME}_${TIMESTUMP}.log"
AI_SETTINGS_DIR="/${MAIN_PATH}/ai_settings"
WORKSPACES_DIR="/${MAIN_PATH}/workspaces"

FORCE=0
YES=0
FORCE_DOCKER_INSTALL=0

#############################################
#                 ARGPARSE
#############################################
# Process command line options
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -d|--docker-compose-alias)
        DOCKER_COMPOSE_ALIAS="$2"
        shift # past argument
        shift # past value
        ;;
        -pv|--py-virtualenv)
        PYTHON_VENV="$2"
        shift # past argument
        shift # past value
        ;;
        -b|--agpt-branch)
        AGPT_BRANCH="$2"
        shift # past argument
        shift # past value
        ;;
        --log-file|-l) LOG_FILE_PATH="$2" 
        shift 2 ;;
        -c|--commands)
        EXTRA_DOCKER_COMPOSE_COMMANDS="$2"
        shift # past argument
        shift # past value
        ;;
        --log-file|-l) LOG_FILE_PATH="$2"; shift 2 ;;
        --move-main|-mv) 
        echo -e "${RED}SORRY!${A_RESET} this feature isn't done yet.\n"
        shift 1 
        ;;
      	--force|-f) 
        FORCE=1; 
        shift 1
      	;;
      	--yes|-y) 
        YES=1; 
        shift 1
      	;;
      	--docker-install|-dd) 
        FORCE_DOCKER_INSTALL=1 
        shift 1
      	;;
	--redis-clear|-rc)
	REDIS_CLEAR=0
	shift
	;;
        -v|--verbose)
        VERBOSE=1
        shift # past argument
        ;;
        -h|--help)
      	print_help
        exit 
        ;;
        *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done


#############################################
#        SPECIAL DOCKER INSTALLATION 
#############################################

function uninstall_dock() {

	# Uninstall docker the other ways you might have it....
	$(sudo snap remove docker --purge) || echo "didn't uninstall docker via snap!"  

	# Kill docker... 
	sudo apt-get purge -y docker-engine docker docker.io docker-ce  
	sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce  
	sudo umount /var/lib/docker/
	sudo rm -rf /var/lib/docker /etc/docker
	sudo rm -f /etc/apparmor.d/docker
	sudo groupdel docker
	sudo rm -rf /var/run/docker.sock
	sudo rm -rf /usr/bin/docker-compose
 
}

function install_dock() {

	###############################################################################
	# SOURCE -- thanks! 
	# https://gist.github.com/angristan/389ad925b61c663153e6f582f7ef370e
	###############################################################################
	sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common sudo
	sudo curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
	sudo apt-get update -y
	sudo apt-get install docker-ce -y
	COMPOSE_VERSION=$(sudo curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
	# Install docker-compose
	sudo sh -c "sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
	sudo chmod +x /usr/local/bin/docker-compose
	sudo sh -c "sudo curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

	# Output compose version
	docker-compose -v

	sudo curl -fsSL https://get.docker.com/ -o get-docker.sh
	sudo sh get-docker.sh

}

#############################################
#         FORCE_DOCKER_INSTALL (-dd)
#############################################

if [[ ${FORCE_DOCKER_INSTALL} -gt 0 ]]; then
    uninstall_dock
    install_dock
fi

#############################################
#             DRY-RUN HANDLERS
#############################################
# Define the necessary directories
REQUIRED_DIRS=(
  "${MAIN_PATH}/logs"
  "${AI_SETTINGS_DIR}"
  "${WORKSPACES_DIR}"
)

# Check and create directories
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
done

# Check if .env file exists
if [ ! -f "${MAIN_PATH}/.env" ]; then
  echo -e "${A_WHITE}${A_RED_BG}${A_BOLD}FATAL ERROR: .env file is missing!${A_RESET}"
  echo -e "${A_RED}${A_BOLD}Make sure you have a .env file in your project root directory.${A_RESET}"
  echo -e "${A_BLUE}For more information and assistance, please visit the Auto-GPT repository: https://github.com/your-repo/auto-gpt${A_RESET}"
  exit 1
fi

#############################################
#                ANIMATION 
#############################################
# Functions
spinner() {
  local -r FRAMES='/-\|'
  local -r NUMBER_OF_FRAMES=${#FRAMES}
  local -r INTERVAL=0.1

  while true; do
    for (( i=0; i<NUMBER_OF_FRAMES; i++ )); do
      echo -en "${FRAMES:i:1} " >&2
      echo -en "\b\b" >&2
      sleep "${INTERVAL}"
    done
  done
}


#############################################
#            ENTERING Auto-GPT               
#############################################

echo -ne "${A_YELLOW}${A_UNDERLINE}cd ${MAIN_PATH}...${A_RESET}\n"
cd "${MAIN_PATH}" || echo -e "${A_RED}couldn't cd into ${MAIN_PATH}!${A_RESET}\n"

#############################################
#        PACKAGE INSTALLATION FUNCS
#############################################

function install_packages() {
  local manager="$1"
  shift
  local packages=("$@")

  for package in "${packages[@]}"; do
    echo -ne "${A_LIGHTGRAY}${A_ITALIC}Checking and installing ${package} using ${manager}...${A_RESET} "
    spinner &
    local spinner_pid=$!

    if [ "${manager}" == "apt" ]; then
	    sudo apt-get install -y "${package}" > /dev/null 2>&1
    elif [ "${manager}" == "snap" ]; then 
	    sudo snap install "${package}" > /dev/null 2>&1
	    # echo -ne "${A_RED}${A_BOLD}sudo snap install disabled temporarily. ${A_RESET}\n";
    elif [ "${manager}" == "npm" ]; then
      # Check if there are packages to install
      if [ ${#NPM_PACKAGES[@]} -eq 0 ]; then
        echo -e "${A_YELLOW}No npm packages to install.${A_RESET}"
        return
      fi
      npm install -g "${package}" > /dev/null 2>&1 
    elif [ "${manager}" == "pip" ]; then
      # Check if there are packages to install
      if [ ${#PIP_PACKAGES[@]} -eq 0 ]; then
        echo -e "${A_YELLOW}No pip packages to install.${A_RESET}"
        return
      fi
      pip install "${package}" > /dev/null 2>&1
    fi

    kill "${spinner_pid}" >/dev/null 2>&1
    wait "${spinner_pid}" 2>/dev/null

    echo -ne "${A_GREEN}Done${A_RESET}\n"
  done
}

#############################################
#        DEP CHECKS & INSTALLATIONS
#############################################

# Add verbose_print function
verbose_print() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo -e "$1"
    fi
}


echo -ne "${A_BLUE}${A_INVERSE}${A_BOLD}CHECKING AND INSTALLING REQUIREMENTS...${A_RESET}\n"
sudo apt-get update -y && sudo apt-get upgrade -y

install_packages "apt" "${APT_PACKAGES[@]}"

install_packages "snap" "${SNAP_PACKAGES[@]}"

if command -v npm &> /dev/null; then
  install_packages "npm" "${NPM_PACKAGES[@]}"
fi

if command -v pip &> /dev/null; then
  install_packages "pip" "${PIP_PACKAGES[@]}"
fi

# Continue with the script
echo -ne "${A_GREEN}${A_INVERSE}${A_BOLD}STARTING${A_RESET}\n"
echo -e "&======================================&"
echo -e " _       _ _                        _   "
echo -e "(_)_ __ (_) |_     __ _  __ _ _ __ | |_ "
echo -e "| | '_ \\| | __|   / _\` |/ _\` | '_ \\| __|"
echo -e "| | | | | | |_   | (_| | (_| | |_) | |_ "
echo -e "|_|_| |_|_|\\__|___\\__,_|\\__, | .__/ \\__|"
echo -e "             |_____|    |___/|_|        "
echo -e "&======================================&"

echo -e "${A_RED}${A_UNDERLINE}make sure you are in the ROOT OF \"auto-gpt\" github repository directory!${A_RESET}"

# echo -ne "${A_BLUE}${A_INVERSE}${A_BOLD}CHECKING REDIS INSTANCE...${A_RESET}\n"
# Check if Redis port is active
if lsof -Pi :${REDIS_PORT} -sTCP:LISTEN -t >/dev/null; then
  # Prompt user whether to kill the active application or not
  if [[ "$USER_RESPONSE" == "yes" ]]; then
    read -p "Port ${REDIS_PORT} is already in use. Do you want to kill the active redis instance? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${A_RED}Killing...${A_RESET}"
      kill $(lsof -t -i:${REDIS_PORT})
    else
      echo "Exiting without killing."
      exit 1
    fi
  else
    echo -e "${A_RED}Skipping prompt and killing the active application...${A_RESET}"
    kill $(lsof -t -i:${REDIS_PORT})
  fi
fi

# Start Redis service with the specified container name
echo -ne "${A_YELLOW}${A_BOLD}Starting Redis service with the container name '${REDIS_CONTAINER_NAME}'...${A_RESET}\n"
docker run -d "${REDIS_CONTAINER_NAME}" -p ${REDIS_PORT}:6379 redis/redis-stack-server:latest
echo -ne "${A_GREEN}Done${A_RESET}\n"
echo -ne "###########################\n"

########################################################################### 

# Check if the Auto-GPT container is already running
AGPT_CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' $AGPT_CONTAINER_NAME 2>/dev/null || true)
if [ "$AGPT_CONTAINER_STATUS" == "running" ]; then
    echo -ne "${A_YELLOW}${A_BOLD}${AGPT_INSTANCE_NAME} Auto-GPT instance is already running.${A_RESET}\n"
    echo -ne "${A_YELLOW}${A_BOLD}Do you want to stop and remove it?${A_RESET} [y/N] "
    read -n 1 response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        echo -ne "${A_YELLOW}${A_BOLD}Stopping the Auto-GPT instance...${A_RESET}\n"
        docker stop $AGPT_CONTAINER_NAME
        echo -ne "${A_YELLOW}${A_BOLD}Removing the Auto-GPT instance...${A_RESET}\n"
        docker rm $AGPT_CONTAINER_NAME
    fi
elif [ "$AGPT_CONTAINER_STATUS" == "exited" ]; then
    echo -ne "${A_YELLOW}${A_INVERSE}${A_BOLD}${AGPT_INSTANCE_NAME} Auto-GPT instance is not running but still exists.${A_RESET}\n"
    echo -ne "${A_YELLOW}${A_BOLD}Do you want to remove it?${A_RESET} [y/N] "
    read -n 1 response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        echo -ne "${A_YELLOW}${A_BOLD}Removing the Auto-GPT instance...${A_RESET}\n"
        docker rm $AGPT_CONTAINER_NAME
    fi
fi

# 3. Check for the Python version after entering the venv
# echo -ne "${A_BLUE}${A_INVERSE}${A_BOLD}CHECKING PYTHON VERSION IN VENV...${A_RESET}\n"
# Insert your implementation here for checking the Python version after entering the venv

echo -ne "${A_YELLOW}${A_INVERSE}${A_BOLD}BUILDING AUTOGPT${A_RESET}...\n"

echo -ne "${A_LIGHTGRAY}${A_ITALIC}activating python virtualenv under \"${PYTHON_VENV}\"...${A_RESET}\n"
python -m venv "${PYTHON_VENV}"
source "${PYTHON_VENV}/bin/activate"

####################################################

# D O C K E R   G A N G 

####################################################

# Temporary Dockerfile for adding modifications
DOCKERFILE_CONTENT=$(cat <<'EOF'
# Base image
#FROM significantgravitas/auto-gpt:0.2.2

# Base image (last version with redis)
FROM significantgravitas/auto-gpt:0.3.1

# TODO: currently unsupported...
# Add pause.sh script
#COPY pause.sh /usr/local/bin/pause.sh
#RUN chmod +x /usr/local/bin/pause.sh
EOF
)

# Write temporary Dockerfile
echo "${DOCKERFILE_CONTENT}" > Dockerfile

# -------- DOCKER COMPOE -------- #

# check vars to set stateful variables
REDIS_WIPE="True"

if [ "${REDIS_CLEAR}" -gt 0]; then
	REDIS_WIPE="False"
fi

DOCKERCOMPOSEYML_CONTENT=$(cat << EOF
version: '3.9'
services:
  auto-gpt:
    build:
      context: .
      dockerfile: Dockerfile
    image: significantgravitas/auto-gpt:custom
    container_name: ${AGPT_CONTAINER_NAME}
    depends_on:
      - redis
    env_file:
      - .env
    environment:
      - LOG_FILE_PATH=${LOG_FILE_PATH}
      - MEMORY_BACKEND=${MEMORY_BACKEND:-redis}
      - REDIS_HOST=${REDIS_HOST:-redis}
      - WIPE_REDIS_ON_START=${REDIS_WIPE}
      - AI_SETTINGS_FILE=ai_settings/ai_settings.yaml
    volumes:
      - "./pause.sh:/usr/local/bin/pause.sh"
      - "./.env:/app/auto-gpt/.env"
      - "${AI_SETTINGS_DIR}:/app/ai_settings"
      - "${WORKSPACES_DIR}:/app/workspaces"
      - ./:/app
    profiles: ["exclude-from-up"]
  redis:
    image: "redis/redis-stack-server:latest"
EOF
)

echo "${DOCKERCOMPOSEYML_CONTENT}" > docker-compose.yml


##########################################################################################

echo -ne "${A_GREEN}Done${A_RESET}\n"
echo -ne "###########################\n"

echo -ne "${A_LIGHTGRAY}${A_ITALIC}using ${A_INVERSE}${DOCKER_COMPOSE_ALIAS}${A_RESET}${A_LIGHTGRAY}${A_ITALIC} to build ${AGPT_CONTAINER_NAME} with pause.sh${A_RESET}\n"
#"${DOCKER_COMPOSE_ALIAS}" build -f "${TMP_DOCKERFILE}" ${AGPT_CONTAINER_NAME}
${DOCKER_COMPOSE_ALIAS} build ${AGPT_CONTAINER_NAME}
echo -ne "${A_GREEN}Done${A_RESET}\n"
echo -ne "###########################\n"

echo -ne "\n\n${A_MAGENTA}${A_INVERSE}${A_BOLD}STARTING AUTOGPT!${A_RESET}\n"
${DOCKER_COMPOSE_ALIAS} run --rm ${AGPT_CONTAINER_NAME} ${EXTRA_DOCKER_COMPOSE_COMMANDS}
echo -ne "${A_GREEN}RUNNING!${A_RESET}\n"
echo -ne "###########################\n"

echo -ne "${A_UNDERLINE}${A_BOLD}${A_RED}${A_INVERSE}Closed. ${A_RESET}\n"


# Run the Auto-GPT instance with the specified options
# echo -ne "${A_YELLOW}${A_BOLD}Starting the Auto-GPT instance with the container name '${AGPT_CONTAINER_NAME}'...${A_RESET}\n"
# ${DOCKER_COMPOSE_ALIAS} up -d --remove-orphans --force-recreate --no-deps autogpt

# Follow the logs of the Auto-GPT instance
# echo -ne "${A_YELLOW}${A_BOLD}Following the logs of the Auto-GPT instance '${AGPT_CONTAINER_NAME}'...${A_RESET}\n"
# docker logs -f $AGPT_CONTAINER_NAME
