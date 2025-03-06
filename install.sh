#!/bin/bash
#Testing case to be removed
MASTER_DIR=$(realpath "../Purpuru")
SCRIPT_FOLDER="${MASTER_DIR}/scripts"
source "${SCRIPT_FOLDER}/time.sh" #Time
source "${SCRIPT_FOLDER}/err.sh" #Error and exception handling
source "${SCRIPT_FOLDER}/os.h"

INSTALL_SOURCE_FILE="${BASH_SOURCE[0]}"
echo "Running process ID: ${BASHPID}"
echo "Running installation"

#Not currently in use
read_file() {
  local found=0
  while IFS= read -r line; do
      [[ "$line" =~ ^--.*--$ ]] && continue
      if [[ "$line" == "$2" ]]; then
        found=1
        echo "$2"
        break
      fi
  done < "$1"
  if [[ "$found" -eq 0 ]]; then
    echo "Error: Value not found $2"
  fi
}
PACKAGE_MANAGER=" \
apt \
yay \
pacman \
dnf \
zypper \
emerge \
apk \
slackpkg \
nix \
xbps \
swupd \
eopkg \
yum \
tdnf \
"

for entry in $PACKAGE_MANAGER; do
  if command -v "$entry" >/dev/null 2>&1; then
    USED_PACKAGE_MANAGER=("$entry")
    break 
  fi
done
echo "${USED_PACKAGE_MANAGER}"


#----------------------
# COMMAND
# ---------------------

COMMAND_VARS=

#----------------------
# TIME
# ---------------------

#----------------------
# PROCESS
# ---------------------

#----------------------
# PACKAGES
# ---------------------

#Get prefix, might develop further
GIT="git clone"

#DPP
DPP_GIT=""

#DOXYGEN
DOXYGEN_GIT="https://github.com/doxygen/doxygen"
echo "Installing doxygen..."
#See if package manager or git
if [-z "${USED_PACKAGE_MANAGER}"]; then
  echo "Installing with "
  "${PACKAGE_MANAGER} ${DISTRO_INSTALL_EXTRA} doxygen"
elif [-z ${GIT} | $? -ne 0]; then
  "${GIT_PREFIX} ${DOXYGEN_GIT}"  
else
  
fi



#----------------------
# TEMPLATE
# ---------------------


#----------------------
# TEMPLATE
# ---------------------


#----------------------
# TEMPLATE
# ---------------------


#----------------------
# TEMPLATE
# ---------------------

