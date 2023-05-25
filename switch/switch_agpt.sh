#!/bin/bash
# agpt_switch.sh
# --------------

# FUTURE PLANS
# 1. add prompt text
# 2. add help message
# 3. add better argparse

source ~./ansi_colors.sh

if [[ $# -eq 0 ]]; then 
	exit 1;
fi

# PARAMS
PREV_NAME=$1


# SHOULD BE PARAMS

#EXEC_HOME="${HOME}/autoAI"
EXEC_HOME=/home/zod/autoAI

AI_SETTINGS_SAVE_DIR="${EXEC_HOME}/workspaces"


if [[ -z ${AI_SETTINGS_SAVE_DIR} ]]; then
	mkdir -p "${AI_SETTINGS_SAVE_DIR}"
	sudo chmod -R 777 "${AI_SETTINGS_SAVE_DIR}"
	# this is crap
	mkdir -p "${EXEC_HOME}/Auto-GPT/ai_settings/"
	sudo chmod -R 777 "${EXEC_HOME}/Auto-GPT/ai_settings/"
fi

# first copy the workspace to a place it can be stored
rsync -av "${EXEC_HOME}/Auto-GPT/auto_gpt_workspace/" "${AI_SETTINGS_SAVE_DIR}/${PREV_NAME}"

# now copy the AI settings 
cp "${EXEC_HOME}/Auto-GPT/ai_settings/ai_settings.yaml" "${EXEC_HOME}/Auto-GPT/ai_settings/ai_settings.yaml.${PREV_NAME}"

# now we're clear to wipe 
sudo rm -rf "${EXEC_HOME}/Auto-GPT/auto_gpt_workspace/"
sudo rm -f "${EXEC_HOME}/Auto-GPT/ai_settings/ai_settings.yaml"

echo -e "${A_GREEN}Finished copying to backup & removing from working tree old data. Time to write new prompt!${A_RESET}"

mkdir -p "${EXEC_HOME}/Auto-GPT/auto_gpt_workspace/"
#chmod -R 777 "${EXEC_HOME}/Auto-GPT/auto_gpt_workspace/"

# write a new empty ai_settings.yaml to the appropriate place, then open vim 
AI_SETTINGS_CONTS=$(cat << EOF
ai_name: ExampleGPT
ai_role: An artificial intelligence focused on creating and maintaining wealth for its operator.
ai_goals: 
	- goal 1
	- goal 2

EOF
)

# write temp example file
echo "${AI_SETTINGS_CONTS}" > "${EXEC_HOME}/Auto-GPT/ai_settings/ai_settings.yaml"

echo -e "${A_YELLOW}COMMAND\n${A_RESET}${A_INVERSE}sudo vim ${EXEC_HOME}/Auto-GPT/ai_settings/ai_settings.yaml${A_RESET}"



exit 0

# !! in the future, save the redis instance !!