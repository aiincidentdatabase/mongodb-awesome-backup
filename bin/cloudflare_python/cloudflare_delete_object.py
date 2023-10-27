import sys
import boto3
import cloudflare_client

R2_BUCKET_NAME = sys.argv[4]
FILE_PATH = sys.argv[5]

s3 = cloudflare_client.create_cloudflare_client(account_id=sys.argv[1], access_key=sys.argv[2], secret_key=sys.argv[3])

# delete the object
s3.delete_object(Bucket=R2_BUCKET_NAME, Key=FILE_PATH)
print('-----------------------------')
print('Successfully deleted file ' + FILE_PATH + ' from R2 bucket ' + R2_BUCKET_NAME)
print('-----------------------------')