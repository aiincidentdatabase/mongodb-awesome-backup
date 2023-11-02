#!/bin/bash -e

echo "Starting prune.sh execution..."

# settings
BACKUPFILE_PREFIX=${BACKUPFILE_PREFIX:-backup}

DELETE_DEVIDE=${DELETE_DEVIDE:-3}
DELETE_TARGET_DAYS_LEFT=${DELETE_TARGET_DAYS_LEFT:-4}

# start script
CWD=`/usr/bin/dirname $0`
cd $CWD

. ./functions.sh
PAST=`create_past_yyyymmdd ${DELETE_TARGET_DAYS_LEFT}`

# check the existence of past file
# if it exists, delete it
TARBALL_PAST="${BACKUPFILE_PREFIX}-${PAST}.tar.bz2"

if [ "x${CLOUDFLARE_ACCOUNT_ID}" != "x" ]; then
  echo "pruning Cloudflare R2 account bucket ${CLOUDFLARE_R2_PUBLIC_BUCKET}"
  r2_delete_file_if_delete_backup_day ${CLOUDFLARE_ACCOUNT_ID} ${CLOUDFLARE_R2_ACCESS_KEY} ${CLOUDFLARE_R2_SECRET_KEY} ${CLOUDFLARE_R2_PUBLIC_BUCKET} ${TARBALL_PAST} ${DELETE_TARGET_DAYS_LEFT} ${DELETE_DEVIDE}

  echo "pruning Cloudflare R2 account bucket ${CLOUDFLARE_R2_PRIVATE_BUCKET}"
  r2_delete_file_if_delete_backup_day ${CLOUDFLARE_ACCOUNT_ID} ${CLOUDFLARE_R2_ACCESS_KEY} ${CLOUDFLARE_R2_SECRET_KEY} ${CLOUDFLARE_R2_PRIVATE_BUCKET} ${TARBALL_PAST} ${DELETE_TARGET_DAYS_LEFT} ${DELETE_DEVIDE}
fi

for TARGET_BUCKET_URL in ${TARGET_PRIVATE_BUCKET_URL} ${TARGET_PUBLIC_BUCKET_URL}
do
  echo "pruning ${TARGET_BUCKET_URL}"
  if [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "s3" ]; then
    s3_delete_file_if_delete_backup_day ${TARGET_BUCKET_URL}${TARBALL_PAST} ${DELETE_TARGET_DAYS_LEFT} ${DELETE_DEVIDE}
  fi
done