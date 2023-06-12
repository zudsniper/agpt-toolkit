#!/bin/bash
# agpt_update_vars.sh
# -------------------
# 
# 🟡 UNFINISHED 🟡
# check the current master branch latest template .env against your environment variables and prompt you if you are missing values. 
# 
# @zudsniper

VERSION="2.0.1"

# Check if ANSI color schema is installed and install if necessary
ansi_colors_file="$HOME/.ansi_colors.sh"
ansi_colors_url="https://raw.githubusercontent.com/zudsniper/bashbits/master/.ansi_colors.sh"

if [[ ! -f "$ansi_colors_file" ]]; then
    echo -e "\e[1;33mANSI color schema not found. Installing...\e[0m"
    curl -s "$ansi_colors_url" -o "$ansi_colors_file"
    echo -e "\e[1;32mANSI color schema installed successfully.\e[0m"
fi

# Source ANSI color schema
source "$ansi_colors_file"

# Log levels
declare -A log_levels=(
    ["silly"]=7
    ["verbose"]=6
    ["debug"]=5
    ["http"]=4
    ["info"]=3
    ["warn"]=2
    ["error"]=1
    ["critical"]=0
)

# Default log level
log_level=${log_levels["info"]}

# Log function
log() {
    local level=$1
    shift
    local message=$@
    local log_level_value=${log_levels[$level]}

    if [[ $log_level_value -ge $log_level ]]; then
        local color=""
        case $level in
            "silly") color=$AnsiColorBlue;;
            "verbose") color=$AnsiColorCyan;;
            "debug") color=$AnsiColorMagenta;;
            "http") color=$AnsiColorGreen;;
            "info") color=$AnsiColorDefault;;
            "warn") color=$AnsiColorYellow;;
            "error") color=$AnsiColorRed;;
            "critical") color=$AnsiColorBold$AnsiColorRed;;
        esac

        echo -e "${color}[${level^^}] ${message}${AnsiColorReset}"
    fi
}

# Print usage message
print_usage() {
    echo -e "${AnsiColorCyan}Usage: $0 [OPTIONS]"
    echo -e "Options:"
    echo -e "  --help, -h\t\tShow usage message"
    echo -e "  --version, -V\t\tDisplay version"
    echo -e "  --verbose, -v\t\tSet logging to verbose"
    echo -e "  --log_level, -l [level]\tSet log level (values: silly, verbose, debug, http, info, warn, error, critical)"
    echo -e "  --setup, -s\t\tInteractive setup"
    echo -e "  --force, -f\t\tAutomatically set default values for all${AnsiColorReset}"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --help|-h)
            print_usage
            exit 0
            ;;
        --version|-V)
            version=${VERSION:-"None"}
            log "info" "Version: ${version}"
            exit 0
            ;;
        --verbose|-v)
            log_level=${log_levels["verbose"]}
            ;;
        --log_level|-l)
            log_level_arg="$2"
            if [[ -n "${log_levels[$log_level_arg]}" ]]; then
                log_level=${log_levels[$log_level_arg]}
            elif [[ "$log_level_arg" =~ ^[0-9]+$ ]]; then
                log_level=$log_level_arg
            else
                log "error" "Invalid log level: ${log_level_arg}"
                print_usage
                exit 1
            fi
            shift
            ;;
        --setup|-s)
            interactive_setup=true
            ;;
        --force|-f)
            force_setup=true
            ;;
        *)
            log "error" "Unknown option: $key"
            print_usage
            exit 1
            ;;
    esac
    shift
done

# Print author's GitHub handle
log "info" "${AnsiColorBold}@zudsniper${AnsiColorReset}"

# Check for the ANSI color schema file
if [[ ! -f "$ansi_colors_file" ]]; then
    log "error" "ANSI color schema file not found."
    exit 1
fi

# Your script logic goes here...

# Example: Backup the old .env file
input_file="path/to/.env"

# Backup the old .env file
parent_dir="$(dirname "$(pwd)")"
backup_dir="${parent_dir}/$(date +'%Y_%m_%d')-.env.bak"
counter=1
while [[ -f "$backup_dir" ]]; do
    backup_dir="${parent_dir}/$(date +'%Y_%m_%d')-${counter}.env.bak"
    counter=$((counter + 1))
done
cp "$input_file" "$backup_dir"
log "info" "Backup created: $backup_dir"

# Example: Iterate the old .env file and add new variables from the template
template_file="https://raw.githubusercontent.com/Significant-Gravitas/Auto-GPT/master/.env.template"

# Download the template file
template=$(mktemp)
if ! curl -sSf "$template_file" -o "$template"; then
    log "error" "Failed to download the template file."
    exit 1
fi

# Read the template file and extract new variables
new_vars=()
while IFS= read -r line; do
    if [[ ! "$line" =~ ^[[:space:]]*# && ! "$line" =~ ^[[:space:]]*$ ]]; then
        key=$(echo "$line" | awk -F= '{print $1}')
        if ! grep -q -E "^[[:space:]]*$key=" "$input_file"; then
            new_vars+=("$line")
        fi
    fi
done < "$template"

if [[ ${#new_vars[@]} -eq 0 ]]; then
    log "info" "No new variables found."
    exit 0
fi

# Interactive setup or force setup
if [[ "$interactive_setup" = true ]]; then
    # Interactive setup
    log "info" "Interactive setup:"
    for var in "${new_vars[@]}"; do
        key=$(echo "$var" | awk -F= '{print $1}')
        default_value=$(echo "$var" | awk -F= '{print $2}')
        read -p "${AnsiColorYellow}Set value for $key [$default_value]: ${AnsiColorReset}" new_value
        if [[ -z "$new_value" ]]; then
            new_value=$default_value
        fi
        log "info" "Setting $key=$new_value"
        echo "$key=$new_value" >> "$input_file"
    done
elif [[ "$force_setup" = true ]]; then
    # Force setup
    log "info" "Force setup:"
    for var in "${new_vars[@]}"; do
        key=$(echo "$var" | awk -F= '{print $1}')
        default_value=$(echo "$var" | awk -F= '{print $2}')
        log "info" "Setting $key=$default_value"
        echo "$key=$default_value" >> "$input_file"
    done
else
    # Default behavior
    log "info" "New variables found. Please run the script with --setup or --force to configure them."
fi

# Rest of your script logic...