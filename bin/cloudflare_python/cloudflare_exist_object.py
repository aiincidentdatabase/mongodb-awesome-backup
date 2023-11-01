import argparse
import boto3
import cloudflare_client

# Create the parser
parser = argparse.ArgumentParser(description='Check if an object exists in a Cloudflare R2 bucket')

# Add the arguments
parser.add_argument('--account_id', required=True, help='Cloudflare account ID')
parser.add_argument('--access_key', required=True, help='Cloudflare access key')
parser.add_argument('--secret_key', required=True, help='Cloudflare secret key')
parser.add_argument('--bucket_name', required=True, help='R2 bucket name')
parser.add_argument('--file_path', required=True, help='Path to the file to be checked')

# Parse the arguments
args = parser.parse_args()

s3 = cloudflare_client.create_cloudflare_client(account_id=args.account_id, access_key=args.access_key, secret_key=args.secret_key)

# Check if the object exists in the R2 bucket
s3.get_object(Bucket=args.bucket_name, Key=args.file_path)