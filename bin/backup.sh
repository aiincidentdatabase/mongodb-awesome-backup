#!/bin/bash -e

echo "Starting backup.sh script execution..."

# settings
IS_PUBLIC_BACKUP=${IS_PUBLIC_BACKUP:-false}
BACKUPFILE_PREFIX=${BACKUPFILE_PREFIX:-backup}
MONGODB_HOST=${MONGODB_HOST:-mongo}
CRONMODE=${CRONMODE:-false}
CLOUDFLARE_ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID}
if [ "${IS_PUBLIC_BACKUP}" == "true" ]; then
  TARGET_BUCKET_URL=${TARGET_PUBLIC_BUCKET_URL}
else
  TARGET_BUCKET_URL=${TARGET_PRIVATE_BUCKET_URL}
fi

# start script
CWD=`/usr/bin/dirname $0`
cd $CWD

. ./functions.sh
NOW=`create_current_yyyymmddhhmmss`

echo "=== $0 started at `/bin/date "+%Y/%m/%d %H:%M:%S"` ==="

TMPDIR="/tmp"
TARGET_DIRNAME="mongodump_full_snapshot"
TARGET="${TMPDIR}/${TARGET_DIRNAME}"
TAR_CMD="/bin/tar"
TAR_OPTS="jcvf"

DIRNAME=`/usr/bin/dirname ${TARGET}`
BASENAME=`/usr/bin/basename ${TARGET}`
TARBALL="${BACKUPFILE_PREFIX}-${NOW}.tar.bz2"
TARBALL_FULLPATH="${TMPDIR}/${TARBALL}"

# check parameters
# deprecate the old option
if [ "x${TARGET_BUCKET_URL}${CLOUDFLARE_ACCOUNT_ID}" == "x" ]; then
  echo "ERROR: At least one of the environment variables TARGET_BUCKET_URL or CLOUDFLARE_ACCOUNT_ID must be specified." 1>&2
  exit 1
fi
if [ "x${CLOUDFLARE_ACCOUNT_ID}" != "x" ]; then
  if [ -z "${CLOUDFLARE_R2_ACCESS_KEY}" ]; then
    echo "ERROR: If CLOUDFLARE_ACCOUNT_ID environment variable is defined, you have to define the CLOUDFLARE_R2_ACCESS_KEY as well" 1>&2
    exit 1
  fi
  if [ -z "${CLOUDFLARE_R2_SECRET_KEY}" ]; then
    echo "ERROR: If CLOUDFLARE_ACCOUNT_ID environment variable is defined, you have to define the CLOUDFLARE_R2_SECRET_KEY as well" 1>&2
    exit 1
  fi
  if [ "${IS_PUBLIC_BACKUP}" == "true" ] && [ -z "${CLOUDFLARE_R2_BUCKET}" ]; then
    echo "ERROR: If CLOUDFLARE_ACCOUNT_ID environment variable is defined, you have to define the CLOUDFLARE_R2_PUBLIC_BUCKET as well" 1>&2
    exit 1
  fi
  if [ "${IS_PUBLIC_BACKUP}" == "false" ] && [ -z "${CLOUDFLARE_R2_BUCKET}" ]; then
    echo "ERROR: If CLOUDFLARE_ACCOUNT_ID environment variable is defined, you have to define the CLOUDFLARE_R2_PRIVATE_BUCKET as well" 1>&2
    exit 1
  fi
fi

# dump databases
MONGODUMP_OPTS="--uri=${MONGODB_URI} ${MONGODUMP_OPTS}"
echo "dump MongoDB aiidprod to the local filesystem..."
mongodump -o ${TARGET} ${MONGODUMP_OPTS}

# Dump Translations database
MONGODUMP_OPTS_TRANSLATIONS="--uri=${MONGODB_URI_TRANSLATIONS}"
echo "dump MongoDB translations to the local filesystem..."
mongodump -o ${TARGET} ${MONGODUMP_OPTS_TRANSLATIONS}

echo "Report contents are subject to their own intellectual property rights. Unless otherwise noted, the database is shared under (CC BY-SA 4.0). See: https://creativecommons.org/licenses/by-sa/4.0/" > ${TARGET}/license.txt

ls -lah
echo "---"
ls -lah ${TARGET}

# run tar command
echo "Start backup ${TARGET} into ${TARGET_BUCKET_URL} ..."
time ${TAR_CMD} ${TAR_OPTS} ${TARBALL_FULLPATH} -C ${DIRNAME} ${BASENAME}

if [ "x${CLOUDFLARE_ACCOUNT_ID}" != "x" ]; then
  # upload tarball to Cloudflare R2
  r2_copy_file ${CLOUDFLARE_ACCOUNT_ID} ${CLOUDFLARE_R2_ACCESS_KEY} ${CLOUDFLARE_R2_SECRET_KEY} ${CLOUDFLARE_R2_BUCKET} ${TARBALL_FULLPATH} ${TARBALL}
elif [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "s3" ]; then
  # transfer tarball to Amazon S3
  s3_copy_file ${TARBALL_FULLPATH} ${TARGET_BUCKET_URL}
fi

# call healthchecks url for successful backup
if [ "x${HEALTHCHECKS_URL}" != "x" ]; then
  curl -fsS --retry 3 ${HEALTHCHECKS_URL} > /dev/null
fi

# clean up working files if in cron mode
if ${CRONMODE} ; then
  rm -rf ${TARGET}
  rm -f ${TARBALL_FULLPATH}
fi
