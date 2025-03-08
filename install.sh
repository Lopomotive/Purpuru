#!/bin/bash

WITH_SUDO="sudo"
#Force sudo use, implement later

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

# Loop through the list of package managers to find the one in use
for entry in $PACKAGE_MANAGER; do
  if command -v "$entry" >/dev/null 2>&1; then
    USED_PACKAGE_MANAGER=("$entry")
    break
  fi
done
echo "Detected package manager: ${USED_PACKAGE_MANAGER}"

#Package list currently empty
export PACKAGE_LIST=" \
  Example
"
#Git translation of package manager
declare -A GIT_TRANSLATION
export GIT_TRANSLATION
GIT_TRANSLATION["Example"]="Example.git"

#Check if package is in package list
package_is_valid(){
  local PKG="$1"
  for package_entry in "${PKG}"; do
    if [ "${PKG}" == "${package_entry}"]; then
      continue
    else
      echo "Invalid package found"
      break
    fi
  done
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
npm \
"

#Install package through package manager
install_package_pm(){
  PKG_ERROR=$("echo Package not found $@ with package manager $^" && return 1)
  local PKG="$1"
  package_is_valid() "${PKG}"
  PACKAGE_IS_INSTALLED=$(echo "Package: ${PKG} is already installed \
   by ${USED_PACKAGE_MANAGER}")
   
  #Default way to check if package is installed
  if [command -v "${PKG}" &>/dev/null];then
    "${PACKAGE_IS_INSTALLED}"
  else
    break
  fi
  
  #Check if installation cases need to be fixed or changed
  #DRY implementation needs to happen, not full DRY
  #Also needs testing
  case "${USED_PACKAGE_MANAGER}" in
    apt)
      if [ "$(dpkg -l | awk -v pkg="${PKG}" '$2 == pkg {print}' | wc -l)" -ge 1]; then
        apt install -y "${PKG}"
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;
    dnf | yum)
      if [ "$(dnf -list installed | awk -v pkg="${PKG}"
         '$2 == pkg {print}')" -ge 1]; then
        "${USED_PACKAGE_MANAGER}" install -y "${PKG}"
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;
    pacman)
      if [ "$(pacman -Q | awk -v pkg="${PKG}"
       '$2 == pkg {print}')" -ge 1 ]; then
        pacman -S --noconfirm "${PACKAGE}" 
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;
    zypper)
      if [ "$(zypper search -i -r ${PKG} | awk -v pkg="${PKG}"
        '$2 == pkg {print}')" -ge 1]; then
        zypper install -y "${PACKAGE}"
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;
    apk)
      if [ "$(apk list -I | awk -v pkg={PKG}
        '$2 == pkg {print}')" -ge 1]; then
        apk add "${PACKAGE}" 
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;
    emerge)
      emerge "${PACKAGE}"
      if [ $? -eq 1]; then
        echo "Gentoo package manager does not seem to work, not suprised \n"
        echo "Install: ${PACKAGE} yourself"
        exit 1 
      fi ;;
    xbps)
      if [ "$(xbps-query -m | awk -v pkg={PKG}
      '$2 == pkg {print}')" -ge 1]; then
        xbps-install -y "${PACKAGE}" 
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;

    #Im confused if this is a valid package manager or not
    pkg)
      pkg install -y "${PACKAGE}" ;;

    brew)
      if [ "$(brew list | awk -v pkg={PKG}
       '$2 == pkg {print}')" -ge 1];
        brew install  "${PACKAGE}"
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi ;;
    npm)
      if [ "$(npm list | awk -v pkg={PKG}
        '$2 == pkg {print}')" -ge 1];
      else
        "${PACKAGE_IS_INSTALLED}"
        break
      fi
    ;;
  esac
  exit_code=$?

  if [ $exit_code -eq 0]; then
    "Package: ${PKG} installed sucessfully"
  else
    PKG_ERROR "${PKG}"
  fi
}

#Check if package has a valid entry for git translation
for package_entry in "${GIT_TRANSLATION}"; do
  #Logic here
done

#Git translation currently empty
install_package_git(){
  local PKG="$1"
  package_is_valid() "${PKG}" 

  #For loop might be implemented instead of case
  case "${GIT_TRANSLATION}" in
    
  esac
}

#----------------------
# LIB
# ---------------------

#Project dependent libaries

#----------------------
# TEMPLATE
# ---------------------


#----------------------
# TEMPLATE
# ---------------------


#----------------------
# TEMPLATE
# ---------------------

