#!/bin/bash -e

echo "Starting list.sh execution..."

# start script
CWD=`/usr/bin/dirname $0`
cd $CWD
. ./functions.sh

# check parameters
if [ "x${TARGET_PRIVATE_BUCKET_URL}" == "x" ]; then
  echo "ERROR: The environment variable TARGET_PRIVATE_BUCKET_URL must be specified." 1>&2
  exit 1
fi

TARGET_BUCKET_URL=${TARGET_PRIVATE_BUCKET_URL}

# output final file list
if [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "s3" ]; then
  echo "There are files below in '${TARGET_BUCKET_URL}' S3 bucket:"
  s3_list_files ${TARGET_BUCKET_URL}
elif [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "gs" ]; then
  echo "There are files below in '${TARGET_BUCKET_URL}' GS bucket:"
  gs_list_files ${TARGET_BUCKET_URL}
fi

# check parameters
if [ "x${TARGET_PUBLIC_BUCKET_URL}" == "x" ]; then
  echo "ERROR: The environment variable TARGET_PUBLIC_BUCKET_URL must be specified." 1>&2
  exit 1
fi

TARGET_BUCKET_URL=${TARGET_PUBLIC_BUCKET_URL}

# output final file list
if [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "s3" ]; then
  echo "There are files below in '${TARGET_BUCKET_URL}' S3 bucket:"
  s3_list_files ${TARGET_BUCKET_URL}
elif [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "gs" ]; then
  echo "There are files below in '${TARGET_BUCKET_URL}' GS bucket:"
  gs_list_files ${TARGET_BUCKET_URL}
fi

# output Cludflare R2 account bucket file list
if [ "x${CLOUDFLARE_ACCOUNT_ID}" != "x" ]; then
  echo "There are files below in '${CLOUDFLARE_R2_PUBLIC_BUCKET}' R2 bucket:"
  r2_list_files ${CLOUDFLARE_ACCOUNT_ID} ${CLOUDFLARE_API_TOKEN} ${CLOUDFLARE_R2_PUBLIC_BUCKET}

  echo "There are files below in '${CLOUDFLARE_R2_PRIVATE_BUCKET}' R2 bucket:"
  r2_list_files ${CLOUDFLARE_ACCOUNT_ID} ${CLOUDFLARE_API_TOKEN} ${CLOUDFLARE_R2_PRIVATE_BUCKET}
fi