#!/bin/bash
#Install file will be continued when rest of the project is more complete
WITH_SUDO="sudo"

#Force sudo use
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Please use 'sudo' to execute it."
  exit 1
fi

echo "Running installation"

MASTER_DIR=$(realpath "../Purpuru")

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
# VARS
# ---------------------
#General variables
declare -A COLORS
COLORS["RED"]="\033[0;31m"
COLORS["GREEN"]="\033[0;32m"
COLORS["YELLOW"]="\033[0;33m"
COLORS["BLUE"]="\033[0;34m"

USR_DIR=$(nodir "/usr")
MOUNT_DIR=$(nodir "/")

SYSTEM_REPOS="${USR_DIR} ${MOUNT_DIR}"

#If true allows suggestions if command missspelled, may not be needed
export ALLOW_VERBOSE_TYPING="true"

#----------------------
# COMMANDS/FLAGS
# ---------------------

#Help command print
print_help(){
  echo "Usage: $0 [OPTIONS] \n"
  echo "Options:"
  echo "  -p, --package PKG1 PKG2 ...PKGN  Specify packages to install
    (arguments after -p are treated as packages)"
  echo "  -m, --pm, --package-manager PKGM  Specify the preffered package manager \
    to install packages from"
  echo "  -l, --lib LIB1 LIB2 ...LIBN  Specify the libaries to install \
    (arguments after -l are treated as libaries)"
  echo "  -v, --verbose  Enable verbose output"
  echo "  -h, --help  Shows current help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    #Specify what packages should only be installed
    #Ignores all other packages
    -p | --package)
      shift
      while [[ $# -gt 0 && ! "$1" == -* ]]; do
        PACKAGES="$1"
        shift
      done
      echo "Only installing ${PACKAGES}"
    ;;
    #Specify package manager to be used
    -m | --pm | --package-manager)
      if [[ "$1" == -* ]]; then
        PREFFERED_PACKAGE_MANAGER="$1"
        shift
        shift
      fi
      echo "Using preffered package manager \
        ${PREFFERED_PACKAGED_MANAGER}"
    ;;
    #Specify what libaries should only be installed
    #Ignores all other libaries
    -l | --lib)
      shift
      while [[ $# -gt 0 && ! "$1" == -* ]]; do
        LIBS="$1"
        shift
      done
    echo "Only installing ${LIBS}"
    ;;

    -v | --verbose)
      VERBOSE=true
      shift
    ;;
    -h | --help)
      print_help
    shift
    ;;

    *)
      echo "Uknown option: $1"
      exit 1
    ;;
  esac
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    break
  else
    echo "Error parsing value: $@"
  fi
done


#----------------------
# TIME
# ---------------------
#Time specific section

format_time() {
  local time_seconds=$1
  local hours minutes seconds

  hours=$(echo "$time_seconds / 3600" | bc)
  time_seconds=$(echo "$time_seconds % 3600" | bc)
  minutes=$(echo "$time_seconds / 60" | bc)
  seconds=$(echo "$time_seconds % 60" | bc)

  printf "Time taken: %02d:%02d:%06.3f\n" "$hours" "$minutes" "$seconds"
}

#Usage
#echo "Running Task 1..."
#TASK1_START_TIME=$(date +%s.%N)

#PROCESS

#TASK1_END_TIME=$(date +%s.%N)
#TASK1_TIME_TAKEN=$(echo "$TASK1_END_TIME - $TASK1_START_TIME" | bc)
#echo "Task 1 completed in: $(format_time "$TASK1_TIME_TAKEN")"

#----------------------
# PACKAGES
# ---------------------
#NOTE:Packages sections will be re-newed and updated at a later state
# once all or most dependencies are known


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
    if [ "${PKG}" == "${package_entry}" ]; then
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
install_package_pm() {
  PKG_ERROR=$("echo Package not found $@ with package manager $^" && return 1)
  local PKG="$1"
  package_is_valid "${PKG}"
  PACKAGE_IS_INSTALLED=$(echo "Package: ${PKG} is already installed \
   by ${USED_PACKAGE_MANAGER}")
   
  #Default way to check if package is installed
  if [command -v "${PKG}" &>/dev/null ]; then
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

#Git translation currently empty
install_package_git(){
  local PKG="$1"
  package_is_valid() "${PKG}" 

  #For loop might be implemented instead of case
  case "${GIT_TRANSLATION}" in
    Example)
      
    ;;
  esac
}

#----------------------
# LIB
# ---------------------
#Project dependent libaries
LIB_DIR="${MASTER_DIR}/lib"
echo "${LIB_DIR}"

#Implementation to check if libary is not in system or user lib directory
# like lib64, lib32 etc
export VALID_LIB_DIR
for LIB_ENTRY in "${SYSTEM_REPOS[@]}"; do
  if [ -d "${LIB_ENTRY}"];then
    for SUBDIR in "${DIR}/*";do
      if [[ "${SUBDIR}" == *lib*]]; then
          VALID_LIB_DIR="${SUBDIR}"
      fi
    done
  fi
done
echo "${VALID_LIB_DIR}"

TRY_TO_INSTALL_THROUGH_PACKAGE="true"

#DPP
if [ "${TRY_TO_INSTALL_THROUGH_PACKAGE}" -eq "true"]; then
  case ${USED_PACKAGE_MANAGER} in
    yay)
      yay -Sy dpp
    
  esac
  if [$? -eq 1]; then
    echo ""
  fi
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

