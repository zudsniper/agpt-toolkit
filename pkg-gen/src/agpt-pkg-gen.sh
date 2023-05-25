#!/bin/bash
# 
# agpt-pkg-gen.sh < AutoGPT-Package < AutoGPT + Kurtosis < OpenAI GPT Models + lots more....
# builder for `AutoGPT-Package`, a packaged deployment tool for AutoGPT.
#
# ⚠ WARNING ⚠ -- ONLY `.json` CONFIG FILES ARE FUNCTIONAL AT THE MOMENT. 
# 4/29/2023
# 
# SOURCES
# AutoGPT-Package: https://github.com/kurtosis-tech/autogpt-package
# AutoGPT        : https://github.com/Significant-Gravitas/Auto-GPT
# OpenAI         : you know
#
# RESOURCES
# AutoGPT ENV    : https://raw.githubusercontent.com/Significant-Gravitas/Auto-GPT/master/.env.template
#
# LEGACY VERSION  
# agpt-pkg-gen2  : https://gist.github.com/zudsniper/9af4c7c3f0de9f162a6b6316cb86ba7d   
# 
# --------------
# by @zudsniper & ChatGPT
# --------------

## $$$$ SOURCE INITIALIZATION SCRIPT $$$$ ##  
source "$(dirname "${BASH_SOURCE[0]}")/init.sh"

# ----------------------------- #

# CLI INTRODUCTION 

echo -ne "*------------------------------------------------------------------------------------*\n"
echo -e " _______  ______  _____  _______      _____  _     _  ______      ______ _______ __   _"
echo -e " |_____| |  ____ |_____]    |    ___ |_____] |____/  |  ____ ___ |  ____ |______ | \  |"
echo -e " |     | |_____| |          |        |       |    \_ |_____|     |_____| |______ |  \_|"
echo -ne "*------------------------------------------------------------------------------------*\n"

echo -ne "${A_PURPLE}${A_BOLD}agpt-pkg-gen.sh${A_RESET} ${A_INVERSE}v${VERSION}${A_RESET}\n\n"
echo -ne "${A_LIGHTGREY}${A_ITALIC}configuration input generator (and runner) for AutoGPT-Plugin (check file header for sources)${A_RESET}\n"
echo -ne "${A_ITALIC}By @zudsniper${reset}\n"
echo -ne "*------------------------------------------------------------------------------------*\n"

## HANDLE PACKAGES WHICH ARE REQUIRED. THIS MAY PROBABLY WILL EXPAND  

# Define an array of package names
packages=( "jq" "yq" "pandoc" )

# Define an array of snarky messages in random colors
snarky_messages=(
    "What? You didn't have $package installed already? How primitive."
    "I'm installing $package for you. You're welcome."
    "Looks like someone forgot to install $package..."
    "Oh, you wanted to convert a file? Why didn't you say so? Here, let me install $package for you."
    "It's dangerous to go alone! Take $package with you."
    "This script requires $package. But don't worry, I'm installing it for you."
)

# Loop over the required packages and check if they're installed
for package in "${packages[@]}"; do
    if ! command -v "$package" >/dev/null 2>&1; then
        # Pick a random snarky message from the array and print it in a random color
        snarky_message_index=$(($RANDOM % ${#snarky_messages[@]}))
        snarky_message="${snarky_messages[$snarky_message_index]}"
        color_code=$((31 + $snarky_message_index % 7))
        echo -e "${yellow}$snarky_message${reset}"
        #spinner "pid" "$yellow"
        if sudo apt-get install -y "$package" >/dev/null 2>&1; then
            echo -e "${green}$package installed successfully!${reset}"
        elif sudo snap install "$package" >/dev/null 2>&1; then
            echo -e "${green}$package installed successfully!${reset}"
        else
            echo -e "${red}Failed to install $package. Trying Snap..."
            if sudo snap install "$package" >/dev/null 2>&1; then
                echo -e "${green}$package installed successfully!${reset}"
            else
                echo -e "${red}Failed to install $package. Please install it manually.${reset}"
                exit 1
            fi
        fi
    else
        echo -e "${green}$package is already installed.${reset}"
    fi
done

echo -ne "*------------------------------------------------------------------------------------*\n"

## USAGE / HELP MESSAGE 

# Define usage and help message
function usage {
    echo "USAGE: $0 [OPTIONS] FILE"
    echo -ne "USAGE:${A_BLUE} $0 -t yml ${A_BOLD}INIT${A_RESET}\n";
    echo ""
    echo "OPTIONS:"
    echo "  -o, --output-file <FILE>  Write the escaped JSON to FILE"
    echo "  -t, --file-type <TYPE>    Output file type, one of: .yaml, .yml, .json, .xml"
    echo "  -n, --no-run              Only print the necessary command to build the container, instead of running it"
    echo "  -h, --help                Show this help message and exit" 
    echo "  -d, --debug               Enable debug mode (lots of spam)"
    echo "  -f, --force               Forcefully overwrite when resolving conflicts."
    echo ""
    echo "FILE: The path to the file to convert. Supported formats are .yaml, .yml, .json, and .xml."
    exit
}

## SUBCOMMAND IMPLEMENTATIONS 

# Subcommand functions
subcommand_init() {
  cat > sample-config.json <<EOL
{
  "OPENAI_API_KEY": "",
  "ALLOWED_PLUGINLIST": []
}
EOL
  info "Generated sample-config.json"
}

subcommand_configure() {
    if [ $# -eq 3 ]; then
      configure "$2" "$3"
    else
      error "Invalid number of arguments. Usage: agpt-pkg-gen.sh CONFIGURE <key> <value>"
      exit 1
    fi
    ;;
}

subcommand_make() {
    # Implement MAKE subcommand
    # ...
}

subcommand_list() {
    # Implement LIST subcommand
    # ...
}

subcommand_exec() {
    # Implement EXEC subcommand
    # ...
}

subcommand_plugin() {
    # Implement PLUGIN subcommand
    # ...
}

subcommand_break() {
    # Implement BREAK subcommand
    # ...
}

subcommand_sftp() {
    # Implement SFTP subcommand
    # ...
}

subcommand_fuck() {
    # Implement FUCK/FRICK/OHNO subcommand
    # ...
}

## ARGUMENT PARSING (MAIN LOOP)

# Parse command-line arguments and call appropriate subcommand functions
SUBCOMMAND="$1"
shift

case "$SUBCOMMAND" in
    INIT)
        init "$@"
        ;;
    CONFIGURE | CONFIG | CONF)
        subcommand_configure "$@"
        ;;
    MAKE | BUILD)
        subcommand_make "$@"
        ;;
    LIST | LS)
        subcommand_list "$@"
        ;;
    EXEC | RUN)
        subcommand_exec "$@"
        ;;
    PLUGIN | PLUGINS | )
        subcommand_plugin "$@"
        ;;
    BREAK)
        subcommand_break "$@"
        ;;
    SFTP | FILES)
        subcommand_sftp "$@"
        ;;
    FUCK | FRICK | OHNO)
        subcommand_fuck "$@"
        ;;
    *)
        error "Invalid subcommand!"
        ;;
esac
