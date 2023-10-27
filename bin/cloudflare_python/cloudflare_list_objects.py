import sys
import boto3
import cloudflare_client

R2_BUCKET_NAME = sys.argv[4]

s3 = cloudflare_client.create_cloudflare_client(account_id=sys.argv[1], access_key=sys.argv[2], secret_key=sys.argv[3])

# List all objects in the R2 bucket
response = s3.list_objects_v2(Bucket=R2_BUCKET_NAME)

# Print the object keys
for obj in response['Contents']:
    print(obj['Key'], 'size:', obj['Size'])
print('-----------------------------')
