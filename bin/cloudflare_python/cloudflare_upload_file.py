import sys
import boto3
import cloudflare_client

R2_BUCKET_NAME = sys.argv[4]
FILE_PATH = sys.argv[5]
FILE_KEY = sys.argv[6]

s3 = cloudflare_client.create_cloudflare_client(account_id=sys.argv[1], access_key=sys.argv[2], secret_key=sys.argv[3])

# Upload the file to the R2 bucket
with open(FILE_PATH, 'rb') as f:
    s3.upload_fileobj(f, R2_BUCKET_NAME, FILE_KEY, ExtraArgs={'ContentType': 'application/x-bzip2'})

print('-----------------------------')
print('Successfully uploaded file ' + FILE_PATH + ' to R2 bucket ' + R2_BUCKET_NAME)
print('-----------------------------')
