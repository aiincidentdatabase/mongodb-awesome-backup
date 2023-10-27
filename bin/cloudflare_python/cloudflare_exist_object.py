import sys
import boto3
import cloudflare_client

R2_BUCKET_NAME = sys.argv[4]
FILE_PATH = sys.argv[5]

s3 = cloudflare_client.create_cloudflare_client(account_id=sys.argv[1], access_key=sys.argv[2], secret_key=sys.argv[3])

# Check if the object exists in the R2 bucket
s3.get_object(Bucket=R2_BUCKET_NAME, Key=FILE_PATH)
