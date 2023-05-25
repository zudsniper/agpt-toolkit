#!/bin/bash
# [GPT-3.5] OBVIOUSLY ITS BY THE ROBOT ITS ALL BY THE ROBOT   
# v4.6.0
# (this file).sh < AutoGPT-Package < AutoGPT + Kurtosis < OpenAI GPT Models + lots more....
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
# --------------
# by @zudsniper
# --------------

echo -ne "*------------------------------------------------------------------------------------*\n"
echo -e " _______  ______  _____  _______      _____  _     _  ______      ______ _______ __   _"
echo -e " |_____| |  ____ |_____]    |    ___ |_____] |____/  |  ____ ___ |  ____ |______ | \  |"
echo -e " |     | |_____| |          |        |       |    \_ |_____|     |_____| |______ |  \_|"
echo -ne "*------------------------------------------------------------------------------------*\n"

echo -ne "${A_PURPLE}${A_BOLD}agpt-pkg-gen.sh${A_RESET}\n\n"
echo -ne "${A_LIGHTGREY}${A_ITALIC}simple configuration input generator (and runner) for AutoGPT-Plugin (check file header for sources)${A_RESET}\n"
echo -ne "${A_ITALIC}By @zudsniper${reset}\n"
echo -ne "*------------------------------------------------------------------------------------*\n"

# Define ANSI color codes
red="\e[91m"
green="\e[92m"
yellow="\e[93m"
blue="\e[94m"
magenta="\e[95m"
cyan="\e[96m"
reset="\e[0m"

# ----------------------------- #
## ANSI COLOR ENVIRONMENT VARS

# [WARNING] this is very zod.tf specific
# Check if .ansi_colors.sh exists, and if not, download it from Github
if [ ! -f "$HOME/.ansi_colors.sh" ]; then
  echo "${A_LIGHTGREY}Downloading ${A_BOLD}.ansi_colors.sh${A_RESET}${A_LIGHTGRAY}...${A_RESET}"
  curl -sSf "https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh" > "$HOME/.ansi_colors.sh"
fi

# source the colors
. "$HOME/.ansi_colors.sh"
# ----------------------------- #

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

# Define a spinner
#function spinner {
#    local pid=$1
#    local delay=0.1
#    local spin_chars="⠇⠋⠙⠸⠴⠦⠇⠋⠙⠸⠴⠦"
#    local spin_len=${#spin_chars}
#    local idx=0
#    echo -en "\e[?25l" # hide cursor
#    while kill -0 $pid >/dev/null 2>&1; do
#        local c="${spin_chars:$idx:1}"
#        echo -en "$2$c$reset "
#        idx=$(( (idx + 1) % spin_len ))
#        sleep $delay
#        echo -en "\b\b\b\b\b\b"
#    done
#    echo -en "\e[?25h" # show cursor
#    wait $pid
#    return $?
#}

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

# Generate a sample configuration file and exit if the "init" subcommand is specified
if [[ "$1" == "init" ]]; then
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --file-type|-t)
                echo -e "${cyan}file-type flag is enabled.${reset}"
                output_file_type="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    # Generate the sample configuration file
    sample_config='{
        "OPENAI_API_KEY":"api-key-here-teehee",
        "EXECUTE_LOCAL_COMMANDS": true,
        "RESTRICT_TO_WORKSPACE": true,
        "SMART_LLM_MODEL":"gpt-4",
        "FAST_LLM_MODEL":"3.5-turbo",
        "FAST_TOKEN_LIMIT": 4000, 
        "SMART_TOKEN_LIMIT": 8000,
        "MEMORY_BACKEND": "redis",
        "MEMORY_INDEX": "auto-gpt",
        "PINECONE_API_KEY": "",
        "PINECONE_ENV": "",
        "REDIS_HOST": "localhost",
        "REDIS_PORT": 6379,
        "REDIS_PASSWORD": "",
        "WIPE_REDIS_ON_START": true,
        "IMAGE_PROVIDER": "dalle",
        "IMAGE_SIZE": 256,
        "HUGGINGFACE_IMAGE_MODEL": "CompVis/stable-diffusion-v1-4",
        "HUGGINGFACE_API_TOKEN": "my-huggingface-api-key",
        "SD_WEBUI_AUTH": "username:password",
        "SD_WEBUI_URL": "https://127.0.0.1:7860",
        "HUGGINGFACE_AUDIO_TO_TEXT_MODEL": "facebook/wav2vec2-base-960h", 
        "GITHUB_API_KEY": "GITHUB_PAT",
        "GITHUB_USERNAME": "username",
        "HEADLESS_BROWSER": true,
        "USE_WEB_BROWSER": "chrome",
        "BROWSE_CHUNK_MAX_LENGTH": 2750,
        "BROWSE_SPACY_LANGUAGE_MODEL": "en_core_web_sm",
        "GOOGLE_API_KEY": "",
        "CUSTOM_SEARCH_ENGINE_ID": "",
        "USE_MAC_OS_TTS": false,
        "USE_BRIAN_TTS": false,
        "ELEVENLABS_API_KEY": "elevenlabs-api-key",
        "ELEVENLABS_VOICE_1_ID": "",
        "ELEVENLABS_VOICE_2_ID": "",
        "ALLOWLISTING_PLUGINS": "email"
    }'

	
    # Get standard time for config write-out

    # Determine the output file type
    case "$output_file_type" in
        .yaml|.yml|.json|.xml)
            output_file="$PWD/sample-config$output_file_type"
            ;;
        *)
            output_file="$PWD/sample-config.json"
            ;;
    esac

    # Write the sample configuration file to the output
        echo -e "${cyan}Creating sample configuration file in ${output_file}...${reset}"
    echo "$sample_config" > "$output_file"
    echo -e "${green}Sample configuration file created successfully!${reset}"
    exit
fi

# Parse command line arguments
output_file=""
stamp_output=1
force=0
no_run=0
debug_mode=0
while [[ $# -gt 0 ]]; do
    case $1 in
        --file-type|-t)
            echo -e "${cyan}file-type flag is enabled.${reset}"
            output_file_type="$2"
            shift 2
            ;;
        --output-file|-o)
            echo -e "${cyan}output-file flag is enabled.${reset}"
	    stamp_output=0
            output_file="$2"
            shift 2
            ;;
        --no-run|-n)
            echo -e "${cyan}no-run flag is enabled.${reset}"
            no_run=1
            shift
            ;;
        --debug|-d)
            echo -e "${cyan}debug flag is enabled.${reset}"
            debug_mode=1
            shift
            ;;
    	--force|-f)
	    echo -e "${red}${A_UNDERLINE}FORCE MODE ENABLED.${reset}\n"
	    force=1
	    shift
	    ;;
    	-h|--help)
            usage
            ;;
        *)
            input_file="$1"
            shift
            ;;
    esac
done

# if stamp_output, get a standard timestamp
STAMP="_escaped"

# Check if input file is specified
if [[ -z "$input_file" ]]; then
    echo -e "${red}Error: Input file not specified.${reset}"
    usage
fi

# Check if input file exists
if [[ ! -f "$input_file" ]]; then
    echo -e "${red}Error: Input file '$input_file' not found.${reset}"
    exit 1
fi

# Determine the output file type
if [[ -z "$output_file_type" ]]; then
    output_file_type=".json"
fi

# TODO: Support other formats again!
# Check if input file contains valid JSON
if ! jq empty "$input_file" >/dev/null 2>&1; then
    echo -e "${red}Error: Input file '$input_file' contains invalid JSON.${reset}"
    exit 1
fi



# HANDLE WRITE PERMISSIONS 
check_permissions() {
    filepath=$1

    if [[ ! -w $filepath ]]; then
        echo -e "\033[0;31mFATAL ERROR could not change $filepath permissions!\033[0m" >&2
        exit 1
    fi

    chmod 755 "$filepath"
    chown "$USER:$USER" "$filepath" 
}

# FORCE OVERRIDE
if [[ $force -eq 0 ]]; then
	# Determine the output file path
	if [[ -z "$output_file" ]]; then
   	    output_file="$(basename "$input_file" | sed "s/\(.*\)\..*/\1/")${STAMP}${output_file_type}"
	fi
else 
    	echo -e "${A_YELLOW}WARNING${reset} ${red}${A_BOLD} force mode enabled.${reset}\n"
	output_file="$(basename "$input_file" | sed "s/\(.*\)\..*/\1/")${STAMP}${output_file_type}"
fi

# CHECK ACTUAL PERMISSIONS (call) 
check_permissions $output_file

# Convert input file to escaped JSON
echo -e "${cyan}Converting $input_file to escaped JSON and writing to $output_file...${reset}"
#function jq_internal() { 
#	escaped_json=$(jq 'with_entires(.value |= tojson )' "$1")  
#	if [[ $debug_mode -gt 0 ]]; then
#		echo -e "${ttttt}"
#	fi
#
#	return $ttttt 
#}
case "$input_file" in
    *.yaml|*.yml)
        yq -o=json '.' "$input_file" | jq -c '.' > "$output_file"
        ;;
    *.json)
	yq -P '.' "$input_file" -o=json | jq -c '.' > "$output_file"
        ;;
    *.xml)
        pandoc -f html -t json "$output_file"
        ;;
    *)
        echo -e "${red}Error: Unsupported file format. Supported formats are .yaml, .yml, .json, and .xml.${reset}"
        exit 1
        ;;
esac

if [[ $no_run -eq 1 ]]; then
    echo -ne "\n${A_BOLD}kurtosis run github.com/kurtosis-tech/autogpt-package --enclave autogpt '$(cat $output_file)'${A_RESET}"
else
    # Run the Kurtosis command
    kurtosis run github.com/kurtosis-tech/autogpt-package --enclave autogpt "$(cat "$output_file")"
fi
echo -e "${green}Conversion and Kurtosis command execution completed successfully!${reset}"

if [[ $debug_mode -eq 19323 ]]; then
    echo -e "${yellow}DEBUG MODE: Printing redacted JSON configuration${reset}"
    cat "$output_file" | jq 'map_values(
        if type == "string" and 
            (contains("API_KEY") or 
             contains("KEY") or 
             contains("PASSWORD"))
        then "${red}[REDACTED]${reset}"
        else . end)' | jq .
fi



