#!/bin/bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

BACKUP_DIR="/backup/"

[[ ( -n "${MONGODB_HOST_FILE}" ) ]] && MONGODB_HOST=$(cat "${MONGODB_HOST_FILE}")
[[ ( -n "${MONGODB_PORT_FILE}" ) ]] && MONGODB_PORT=$(cat "${MONGODB_PORT_FILE}")
[[ ( -n "${MONGODB_USER_FILE}" ) ]] && MONGODB_USER=$(cat "${MONGODB_USER_FILE}")
[[ ( -n "${MONGODB_PASS_FILE}" ) ]] && MONGODB_PASS=$(cat "${MONGODB_PASS_FILE}")
[[ ( -n "${MONGODB_DB_FILE}" ) ]] && MONGODB_DB=$(cat "${MONGODB_DB_FILE}")

[[ ( -n "${MONGODB_USER}" ) ]] && USER_STR=" --username ${MONGODB_USER}" || MONGODB_USER=""
[[ ( -n "${MONGODB_PASS}" ) ]] && PASS_STR=" --password ${MONGODB_PASS}" || MONGODB_PASS=""
[[ ( -n "${MONGODB_DB}" ) ]] && DB_STR=" --db ${MONGODB_DB}" || DB_STR=""

if [ "$#" -eq "0" ]; then
    exit 1
fi

case "$1" in
    ###################################
    ## Create Backup
    ###################################
    "backup")

    BACKUP_NAME=$(date +\%Y.\%m.\%d.\%H\%M\%S)
    echo "[Backup database $BACKUP_NAME]"
    BACKUP_CMD="mongodump --out ${BACKUP_DIR}${BACKUP_NAME} --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR}${DB_STR} ${EXTRA_ARGUMENTS}"
    if ${BACKUP_CMD} ;then
        echo "   Backup succeeded"
    else
        echo "   Backup failed"
        rm -rf ${BACKUP_DIR}${BACKUP_NAME}
    fi
    if [ -n "${MAX_BACKUPS}" ]; then
        echo "   Deleting old backups"
        ls -t -d ${BACKUP_DIR}* | tail -n +$(($MAX_BACKUPS + 1)) | xargs rm -rf
    fi
    echo "=> Backup done"
    ;;

    ###################################
    ## Restore Backup
    ###################################
    "restore")
        shift
        echo "[Restore database from $1]"
        RESTORE_CMD="mongorestore --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR} ${EXTRA_OPTS_RESTORE} ${BACKUP_DIR}$1"
        if ${RESTORE_CMD}; then
            echo "   Restore succeeded"
        else
            echo "   Restore failed"
        fi
        echo "=> Done"
    ;;

    ###################################
    ## List Backup
    ###################################
    "list")
        echo "[Availible database backups]"
        ls -l  $BACKUP_DIR | awk '/^d/ {print $9}'
    ;;

esac
