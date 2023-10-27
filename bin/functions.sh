# default settings
AWSCLI="/usr/bin/aws"
AWSCLI_COPY_OPT="s3 cp"
AWSCLI_LIST_OPT="s3 ls"
AWSCLI_DEL_OPT="s3 rm"
AWSCLIOPT=${AWSCLIOPT:-}
#AWSCLI_ENDPOINT_OPT=${AWSCLI_ENDPOINT_OPT:+"--endpoint-url ${AWSCLI_ENDPOINT_OPT}"}
AWSCLI_ENDPOINT_OPT=""

GCSCLI="/root/google-cloud-sdk/bin/gsutil"
GCSCLI_COPY_OPT="cp"
GCSCLI_LIST_OPT="ls"
GCSCLI_DEL_OPT="rm"
GCSCLIOPT=${GCSCLIOPT:-}

WRANGLERCLI="wrangler"

CLOUDFLARE_UPLOAD_SCRIPT="./clouflare_python/cloudflare_upload_file.py"

DATE_CMD="/bin/date"

# Check the existence of specified file.
# If it is found, this returns 0
# Otherwise, this returns 1(which aws returns)
# arguments: 1. s3 url (s3://.../...)
s3_exists() {
	if [ $# -ne 1 ]; then return 255; fi
	${AWSCLI} ${AWSCLI_ENDPOINT_OPT} ${AWSCLIOPT} ${AWSCLI_LIST_OPT} $1 >/dev/null
}
gs_exists() {
	if [ $# -ne 1 ]; then return 255; fi
	${GCSCLI} ${GCSCLIOPT} ${GCSCLI_LIST_OPT} $1 >/dev/null
}
# Check the existence of specified file on Cloudflare R2 bucket.
# arguments: 1. CLOUDFLARE_ACCOUNT_ID
#            2. CLOUDFLARE_API_TOKEN
#            3. CLOUDFLARE_R2_PUBLIC_BUCKET/<filename> or CLOUDFLARE_R2_PRIVATE_BUCKET/<filename>
r2_exists() {
	if [ $# -ne 3 ]; then return 255; fi
	CLOUDFLARE_ACCOUNT_ID=$1 CLOUDFLARE_API_TOKEN=$2 ${WRANGLERCLI} r2 object get $3 >/dev/null
}

# Output the list of the files on specified S3 URL.
# arguments: 1. s3 url (s3://...)
s3_list_files() {
	${AWSCLI} ${AWSCLI_ENDPOINT_OPT} ${AWSCLIOPT} ${AWSCLI_LIST_OPT} $1
}
gs_list_files() {
	${GCSCLI} ${GCSCLIOPT} ${GCSCLI_LIST_OPT} $1
}
# Output the list of the files on specified Cloudflare R2.
# arguments: 1. CLOUDFLARE_ACCOUNT_ID
#            2. CLOUDFLARE_API_TOKEN
#            3. CLOUDFLARE_R2_PUBLIC_BUCKET or CLOUDFLARE_R2_PRIVATE_BUCKET
r2_list_files() {
	if [ $# -ne 3 ]; then return 255; fi
	CLOUDFLARE_ACCOUNT_ID=$1 CLOUDFLARE_API_TOKEN=$2 ${WRANGLERCLI} r2 object get $3/
}

# Delete the specified file.
# arguments: 1. s3 url (s3://.../...)
s3_delete_file() {
	if [ $# -ne 1 ]; then return 255; fi
	${AWSCLI} ${AWSCLI_ENDPOINT_OPT} ${AWSCLIOPT} ${AWSCLI_DEL_OPT} $1
}
gs_delete_file() {
	if [ $# -ne 1 ]; then return 255; fi
	${GCSCLI} ${GCSCLIOPT} ${GCSCLI_DEL_OPT} $1
}
# Delete the specified file on Cloudflare R2 bucket.
# arguments: 1. CLOUDFLARE_ACCOUNT_ID
#            2. CLOUDFLARE_API_TOKEN
#            3. CLOUDFLARE_R2_PUBLIC_BUCKET/<filename> or CLOUDFLARE_R2_PRIVATE_BUCKET/<filename>
r2_delete_file() {
	if [ $# -ne 3 ]; then return 255; fi
	CLOUDFLARE_ACCOUNT_ID=$1 CLOUDFLARE_API_TOKEN=$2 ${WRANGLERCLI} r2 object delete $3
}

# Copy the specified file.
# arguments: 1. local filename
#            2. target s3 url (s3://...)
#                  or
#            1. target s3 url (s3://...)
#            2. local filename
#                  or
#            1. source s3 url (s3://...)
#            2. target s3 url (s3://...)
s3_copy_file() {
	echo ${AWSCLI} ${AWSCLI_ENDPOINT_OPT} ${AWSCLIOPT} ${AWSCLI_COPY_OPT} $1 $2
	if [ $# -ne 2 ]; then return 255; fi
	${AWSCLI} ${AWSCLI_ENDPOINT_OPT} ${AWSCLIOPT} ${AWSCLI_COPY_OPT} $1 $2
}
gs_copy_file() {
	if [ $# -ne 2 ]; then return 255; fi
	${GCSCLI} ${GCSCLIOPT} ${GCSCLI_COPY_OPT} $1 $2
}
r2_copy_file() {
	# echo "CLOUDFLARE_ACCOUNT_ID=$1 CLOUDFLARE_API_TOKEN=$2 ${WRANGLERCLI} r2 object put $3/$4 --file $5"
	if [ $# -ne 5 ]; then return 255; fi
	# CLOUDFLARE_ACCOUNT_ID=$1 CLOUDFLARE_API_TOKEN=$2 ${WRANGLERCLI} r2 object put $3/$4 --file $5

	echo "python ${CLOUDFLARE_UPLOAD_SCRIPT} $1 $2 $3 $4 $5"
	python3 ${CLOUDFLARE_UPLOAD_SCRIPT} $1 $2 $3 $4 $5
}

# Create current datetime string(YYYYmmddHHMMSS)
create_current_yyyymmddhhmmss() {
	echo `/bin/date +%Y%m%d%H%M%S`
}

# Create date string of n days ago
# arguments: 1. how many days ago
create_past_yyyymmdd() {
	if [ $# -ne 1 ]; then return 255; fi
	echo `/bin/date +%Y%m%d -d "$1 days ago"`
}

# Check whether the day is deleting backup file or not
# arguments: 1. how many days ago to be deleted
#            2. divide number
check_is_delete_backup_day() {
	if [ $# -ne 2 ]; then return 255; fi
	MOD_COUNT=`/usr/bin/expr $(/bin/date +%s -d "$1 days ago") / 86400 % $2`
	if [ ${MOD_COUNT} -ne 0 ]; then
		return 0
	else
		return 255
	fi
}

# arguments: 1. s3 url (s3://.../...)
#            2. how many days ago to be deleted
#            3. divide number
s3_delete_file_if_delete_backup_day() {
	if [ $# -ne 3 ]; then return 255; fi
	if check_is_delete_backup_day $2 $3; then
		if s3_exists $1; then
			s3_delete_file $1
			echo "DELETED past backuped file on S3: $1"
		else
			echo "not found past backuped file on S3: $1"
		fi
	fi
}
gs_delete_file_if_delete_backup_day() {
	if [ $# -ne 3 ]; then return 255; fi
	if check_is_delete_backup_day $2 $3; then
		if gs_exists $1; then
			gs_delete_file $1
			echo "DELETED past backuped file on GS: $1"
		else
			echo "not found past backuped file on GS: $1"
		fi
	fi
}
# arguments: 1. CLOUDFLARE_ACCOUNT_ID
#            2. CLOUDFLARE_API_TOKEN
#            3. CLOUDFLARE_R2_PUBLIC_BUCKET/<filename> or CLOUDFLARE_R2_PRIVATE_BUCKET/<filename>
#			 4. how many days ago to be deleted
#            5. divide number
r2_delete_file_if_delete_backup_day() {
	if [ $# -ne 5 ]; then return 255; fi
	if check_is_delete_backup_day $4 $5; then
		if r2_exists $1 $2 $3; then
			r2_delete_file $1 $2 $3
			echo "DELETED past backuped file on R2: $3"
		else
			echo "Not found past backuped file on R2: $3"
		fi
	fi
}
