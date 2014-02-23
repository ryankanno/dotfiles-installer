#!/usr/bin/env bash

# CHANGEME - If you want to install your dotfiles-installer elsewhere
INSTALLER_HOME="${HOME}/.dotfiles-installer"

##############################################################################
#
# HERE BE DRAGONS! (Where the magic happens)
#
##############################################################################

# Define these in .${APP}install file
GIT_REPO=""
GIT_EXEC="/opt/local/bin/git"

LOCAL_REPO_HOME_DIR="${INSTALLER_HOME}/repo/"
LOCAL_CONF_DIR="${INSTALLER_HOME}/conf"

APP=$1
APP_INSTALL_CONFIG=".${APP}install"

# echo -> https://unix.stackexchange.com/questions/65803/why-is-printf-better-than-echo

function get_local_repo_dir() {
    local LOCAL_REPO_DIR_NAME=`echo $GIT_REPO | sed 's%^.*/\([^/]*\)\.git$%\1%g'`
    echo "${LOCAL_REPO_HOME_DIR}${LOCAL_REPO_DIR_NAME}"
}

function echo() {
  if [ "$#" -gt 0 ]; then
     printf %s "$1"
     shift
  fi
  if [ "$#" -gt 0 ]; then
     printf ' %s' "$@"
  fi
  printf '\n'
}

# does a function exist?
function fn_exists() {
    type $1 2>/dev/null | grep -q 'is a function'
}

# does a command exist?
function command_exists() {
    command -v $1 >/dev/null 2>&1
}

# If .$APPinstall exists, use those variables instead
function load_install_config() {
    if [ -e "${HOME}/${APP_INSTALL_CONFIG}" ]; then
        source "${HOME}/${APP_INSTALL_CONFIG}"
    elif [ -e "${LOCAL_CONF_DIR}/${APP_INSTALL_CONFIG}" ]; then
        source "${LOCAL_CONF_DIR}/${APP_INSTALL_CONFIG}"
    else
        echo "Could not find ${APP_INSTALL_CONFIG}. Please try again."
        echo ""
        exit 1
    fi
}

# Create directory if it doesn't exist
function ensure_directory_exists() {
    DIRECTORY=$1
    if [ ! -d "${DIRECTORY}" ]; then
        echo "Creating directory: ${DIRECTORY}"
        mkdir -p "${DIRECTORY}"
    fi

    echo "Directory found: ${DIRECTORY}"
}

# Update directory from git
function update_from_git() {
    DIRECTORY=$1/${REPO_DIRECTORY_NAME}
    if [ `ls $DIRECTORY | wc -l` -eq 0 ]; then
        $GIT_EXEC clone $GIT_REPO $DIRECTORY
        pushd . > /dev/null
        cd "$DIRECTORY"
        $GIT_EXEC submodule init
        $GIT_EXEC submodule update
        popd > /dev/null
    else
        pushd . > /dev/null
        cd "$DIRECTORY"
        $GIT_EXEC pull origin master
        $GIT_EXEC submodule init
        $GIT_EXEC submodule update
        popd > /dev/null
    fi
}

# Update symlinks (and save previous)
# TODO: Should take src, target
function update_symlink() {
    local LOCAL_REPO_DIR=$(get_local_repo_dir)

    SYMLINK=$1

    if [ -L "${HOME}/${SYMLINK}" ]; then
        if [ -d "${HOME}/${SYMLINK}" ]; then
            rm "${HOME}/${SYMLINK}"
            echo "Found existing ${SYMLINK} directory symlink and removed it."
        else
            EPOCH=`(date +"%s")`
            BACKUP_SYMLINK="${HOME}/${SYMLINK}_$EPOCH"
            cat "${HOME}/${SYMLINK}" >> $BACKUP_SYMLINK
            rm -rf "${HOME}/${SYMLINK}"
            echo "Found existing ${SYMLINK} file symlink, copied contents to ${BACKUP_SYMLINK}, removing original."
        fi
    elif [ -f "${HOME}/${SYMLINK}" ]; then
        EPOCH=`(date +"%s")`
        BACKUP_FILE="${HOME}/${SYMLINK}_$EPOCH"
        mv "${HOME}/${SYMLINK}" $BACKUP_FILE
        echo "Found existing file ${SYMLINK}, renaming to $BACKUP_FILE."
    fi

    ln -s "${LOCAL_REPO_DIR}/${SYMLINK}" "${HOME}/${SYMLINK}"

    echo "Created symlink from ${LOCAL_REPO_DIR}/${SYMLINK} to ${HOME}/${SYMLINK}"
}

# usage
function usage() {
    echo "Usage: `basename $0` app"
}

##############################################################################
#
# Begin
#
##############################################################################

if [[ -z "$1" ]]; then
    echo "`basename $0` requires an app to install."
    echo
    usage
    exit 1
fi

load_install_config

command_exists ${GIT_EXEC}
if [ $? -ne 0 ]; then
    echo "git does not exist here: ${GIT_EXEC}. Fix GIT_EXEC path in your ${APP_INSTALL_CONFIG}. "
    echo
    exit 1
fi

ensure_directory_exists "${INSTALLER_HOME}"
ensure_directory_exists "${LOCAL_REPO_HOME_DIR}"

update_from_git $(get_local_repo_dir)

fn_exists pre_install
if [ $? -eq 0 ]; then
    pre_install
fi

fn_exists install
if [ $? -eq 0 ]; then
    install
fi

fn_exists post_install
if [ $? -eq 0 ]; then
    post_install
fi

echo "Done."
