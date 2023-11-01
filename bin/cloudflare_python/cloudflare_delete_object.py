import argparse
import boto3
import cloudflare_client

# Create the parser
parser = argparse.ArgumentParser(description='Delete an object from a Cloudflare R2 bucket')

# Add the arguments
parser.add_argument('--account_id', required=True, help='Cloudflare account ID')
parser.add_argument('--access_key', required=True, help='Cloudflare access key')
parser.add_argument('--secret_key', required=True, help='Cloudflare secret key')
parser.add_argument('--bucket_name', required=True, help='R2 bucket name')
parser.add_argument('--file_path', required=True, help='Path to the file to be deleted')

# Parse the arguments
args = parser.parse_args()

s3 = cloudflare_client.create_cloudflare_client(account_id=args.account_id, access_key=args.access_key, secret_key=args.secret_key)

# delete the object
s3.delete_object(Bucket=args.bucket_name, Key=args.file_path)
print('-----------------------------')
print('Successfully deleted file ' + args.file_path + ' from R2 bucket ' + args.bucket_name)
print('-----------------------------')