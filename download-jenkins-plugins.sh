#! /bin/bash

# This script downloads Jenkins plugins (hpi files) from the specified website 
# (https://updates.jenkins-ci.org/download/plugins by default) due to the plugin list generated 
# with list-jenkins-plugins.sh script (https://github.com/Yannek-JS/list-jenkins-plugins).

# wget is required

START_TIME=$(date +%F__%T | sed 's/:/-/g')
DOWNLOAD_URL='https://updates.jenkins-ci.org/download/plugins'  # do not end it with slash
DESTINATION_DIR="plugins_${START_TIME}"                         # do not end it with slash
PLUGIN_LIST='jenkins-plugin-list_2023-01-02__11-18-13.csv'
LOG_FILE="jenkins_plugin_list_${START_TIME}.log"

if ! [ -f "${PLUGIN_LIST}" ]
then
    echo "The plugin list file ${PLUGIN_LIST} does not exitst. Quitting the script."
    exit
fi

if ! [ -d "${DESTINATION_DIR}" ]
then
    mkdir --parent "${DESTINATION_DIR}"
    if [ $? -ne 0 ]
    then
        echo "Destination directory ${DESTINATION_DIR} cannot be created. Quitting the script."
        exit
    fi
fi

cat "${PLUGIN_LIST}" | while read plugin
do
    pluginName=$(echo $plugin | gawk --field-separator ',' '{print $1}')
    pluginVer=$(echo $plugin | gawk --field-separator ',' '{print $2}')
    echo '------------------------------------------------------------' >> "${LOG_FILE}" 
    echo -e -n "  Downloading $pluginName $pluginVer ...... " | tee --append "${LOG_FILE}" 
    echo -e '\n------------------------------------------------------------' >> "${LOG_FILE}" 
    wget --no-verbose "${DOWNLOAD_URL}/${pluginName}/${pluginVer}/${pluginName}.hpi" \
        --output-document "${DESTINATION_DIR}/${pluginName}.hpi" --append-output="${LOG_FILE}"
    if [ $? -ne 0 ]; then echo 'Error ! See the log file.'; else echo 'OK'; fi
    echo | tee --append "${LOG_FILE}" 
done
