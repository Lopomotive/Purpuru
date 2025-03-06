#Dependency installer

#!/bin/bash

MASTER_DIR="../"
INSTALLATION_FILE="install.sh"

source "${MASTER_DIR}/${INSTALLATION_FILE}"

#----------------------
# DOXYGEN
# ---------------------

DOXYGEN_GIT="https://github.com/doxygen/doxygen"
echo "Installing doxygen..."
#See if package manager or git
if [-z ${PACKAGE_MANAGER}]; then
  echo "Installing through packagemanager"
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

