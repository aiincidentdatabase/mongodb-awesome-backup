import sys
import boto3

CLOUDFLARE_ACCOUNT_ID = sys.argv[1]
CLOUDFLARE_R2_ACCESS_KEY = sys.argv[2]
CLOUDFLARE_R2_SECRET_KEY = sys.argv[3]
R2_BUCKET_NAME = sys.argv[4]

s3 = boto3.client(
    service_name = 's3',
    endpoint_url = 'https://' +  CLOUDFLARE_ACCOUNT_ID + '.r2.cloudflarestorage.com',
    aws_access_key_id = CLOUDFLARE_R2_ACCESS_KEY,
    aws_secret_access_key = CLOUDFLARE_R2_SECRET_KEY,
    region_name='auto', # Must be one of: wnam, enam, weur, eeur, apac, auto
)

# List all objects in the R2 bucket
response = s3.list_objects_v2(Bucket=R2_BUCKET_NAME)

# Print the object keys
for obj in response['Contents']:
    print(obj['Key'], 'size:', obj['Size'])
print('-----------------------------')
