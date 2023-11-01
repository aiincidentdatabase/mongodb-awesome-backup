import argparse
import boto3
import cloudflare_client

# Create the parser
parser = argparse.ArgumentParser(description='Upload a file to a Cloudflare R2 bucket')

# Add the arguments
parser.add_argument('--account_id', required=True, help='Cloudflare account ID')
parser.add_argument('--access_key', required=True, help='Cloudflare access key')
parser.add_argument('--secret_key', required=True, help='Cloudflare secret key')
parser.add_argument('--bucket_name', required=True, help='R2 bucket name')
parser.add_argument('--file_path', required=True, help='Path to the file to be uploaded')
parser.add_argument('--file_key', required=True, help='Key under which the file should be stored in the bucket')

# Parse the arguments
args = parser.parse_args()

s3 = cloudflare_client.create_cloudflare_client(account_id=args.account_id, access_key=args.access_key, secret_key=args.secret_key)

# Upload the file to the R2 bucket
with open(args.file_path, 'rb') as f:
    s3.upload_fileobj(f, args.bucket_name, args.file_key, ExtraArgs={'ContentType': 'application/x-bzip2'})

print('-----------------------------')
print('Successfully uploaded file ' + FILE_PATH + ' to R2 bucket ' + R2_BUCKET_NAME)
print('-----------------------------')
