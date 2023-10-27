import boto3

def create_cloudflare_client(account_id, access_key, secret_key, region='auto'):
    endpoint_url = f'https://{account_id}.r2.cloudflarestorage.com'
    s3 = boto3.client(
        service_name='s3',
        endpoint_url=endpoint_url,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        region_name=region
    )
    return s3
