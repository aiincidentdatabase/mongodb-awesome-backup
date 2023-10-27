import sys
import boto3

CLOUDFLARE_ACCOUNT_ID = sys.argv[1]
CLOUDFLARE_R2_ACCESS_KEY = sys.argv[2]
CLOUDFLARE_R2_SECRET_KEY = sys.argv[3]
R2_BUCKET_NAME = sys.argv[4]
FILE_PATH = sys.argv[5]
FILE_KEY = sys.argv[6]

s3 = boto3.client(
    service_name = 's3',
    endpoint_url = 'https://' +  CLOUDFLARE_ACCOUNT_ID + '.r2.cloudflarestorage.com',
    aws_access_key_id = CLOUDFLARE_R2_ACCESS_KEY,
    aws_secret_access_key = CLOUDFLARE_R2_SECRET_KEY,
    region_name='auto', # Must be one of: wnam, enam, weur, eeur, apac, auto
)

# Upload the file to the R2 bucket
with open(FILE_PATH, 'rb') as f:
    s3.upload_fileobj(f, R2_BUCKET_NAME, FILE_KEY)

print('-----------------------------')
print('Successfully uploaded file ' + FILE_PATH + ' to R2 bucket ' + R2_BUCKET_NAME)
print('-----------------------------')

# Print the contents of the object
# fileRespose = s3.get_object(Bucket=R2_BUCKET_NAME, Key=FILE_PATH)
# print(fileRespose['Body'].read().decode('utf-8'))

# delete the object
# s3.delete_object(Bucket=R2_BUCKET_NAME, Key=FILE_PATH)
