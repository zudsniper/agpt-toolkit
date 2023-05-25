#!/bin/bash
# subcommands/configuration.sh
# ----------------------------

# TODO: hopefully spinner is defined elsewhere to a decent degree...  

source "$(dirname "${BASH_SOURCE[0]}")/../init.sh"

download_env_template() {
  local env_template_url="${AUTOGPT_ENV_TEMPLATE_RAW_URL}"
  info "Downloading latest env.template..."
  env_template_content=$(curl -s "$env_template_url")
  spinner & # Start spinner animation
  wait $! # Wait for the spinner to finish
  info "Downloaded latest env.template"
}

configure() {
  local config_key="$1"
  local config_value="$2"

  # Check if the config_key exists in the env.template content
  if grep -q "^#*\s*$config_key=" <<<"$env_template_content"; then
    # If the key exists, update its value in the actual .env file
    if grep -q "^#*\s*$config_key=" .env; then
      sed -i "s/^#*\s*\($config_key=\).*$/\1$config_value/" .env
    else
      echo "$config_key=$config_value" >> .env
    fi
    info "Updated $config_key to $config_value"
  else
    error "Invalid configuration key: $config_key"
  fi
}

download_env_template

case "$1" in
  "CONFIGURE"|"CONFIG"|"CONF")
    if [ $# -eq 3 ]; then
      configure "$2" "$3"
    else
      error "Invalid number of arguments. Usage: agpt-pkg-gen.sh CONFIGURE <key> <value>"
      exit 1
    fi
    ;;
  *)
    error "Invalid subcommand"
    exit 1
    ;;
esac
