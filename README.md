This is a quick port of the forked project to support JSON and CSV backups of the [AIID](https://incidentdatabase.ai/).

The complete state of the database will be backed up on a weekly basis in both JSON and CSV form. The backups can be downloaded from here: todo

What is mongodb-awesome-backup?
-------------------------------

mongodb-awesome-backup is the collection of scripts which backup MongoDB databases to Amazon S3.
You can set a custom S3 endpoint to use S3 based services like DigitalOcean Spaces instead of Amazon S3.


Requirements
------------

Amazon IAM Access Key ID/Secret Access Key, which must have the access rights of the target Amazon S3 bucket.

Usage
-----
Note that either AWS_ or GCP_ vars are required not both.

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=<Your IAM Access Key ID> \
  -e AWS_SECRET_ACCESS_KEY=<Your IAM Secret Access Key> \
  -e TARGET_BUCKET_URL=<Target Bucket URL ([s3://...|gs://...])> \
  [ -e BACKUPFILE_PREFIX=<Prefix of Backup Filename (default: "backup") \ ]
  [ -e MONGODB_URI=<Target MongoDB URI> \ ]
  [ -e MONGODB_HOST=<Target MongoDB Host (default: "mongo")> \ ]
  [ -e MONGODB_DBNAME=<Target DB name> \ ]
  [ -e MONGODB_USERNAME=<DB login username> \ ]
  [ -e MONGODB_PASSWORD=<DB login password> \ ]
  [ -e MONGODB_AUTHDB=<Authentication DB name> \ ]
  [ -e AWSCLI_ENDPOINT_OPT=<S3 endpoint URL (ex. https://fra1.digitaloceanspaces.com)> \ ]
  [ -v ~:/mab \ ]
  weseek/mongodb-awesome-backup
```

and after running this, `backup-YYYYMMdd.tar.bz2` will be placed on Target S3 Bucket.


Environment variables
---------

### For `backup`, `prune`, `list`

#### Required

| Variable              | Description                                                                    | Default |
| --------------------- | ------------------------------------------------------------------------------ | ------- |
| AWS_ACCESS_KEY_ID     | Your IAM Access Key ID                                                         | -       |
| AWS_SECRET_ACCESS_KEY | Your IAM Secret Access Key                                                     | -       |
| TARGET_BUCKET_URL     | Target Bucket URL ([s3://...\|gs://...]). **URL is needed to be end with '/'** | -       |

#### Optional

| Variable                          | Description                                                                                                                                                                                               | Default  |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| GCP_SERVICE_ACCOUNT_KEY_JSON_PATH | JSON file path to your GCP Service Account Key                                                                                                                                                            | -        |
| GCP_ACCESS_KEY_ID                 | Your GCP Access Key                                                                                                                                                                                       | -        |
| GCP_SECRET_ACCESS_KEY             | Your GCP Secret                                                                                                                                                                                           | -        |
| GCP_PROJECT_ID                    | Your GCP Project ID                                                                                                                                                                                       | -        |
| BACKUPFILE_PREFIX                 | Prefix of Backup Filename                                                                                                                                                                                 | "backup" |
| MONGODB_URI                       | Target MongoDB URI (ex. `mongodb://mongodb?replicaSet=rs0`). If set, the other `MONGODB_*` variables will be ignored.                                                                                     | -        |
| MONGODB_HOST                      | Target MongoDB Host                                                                                                                                                                                       | "mongo"  |
| MONGODB_DBNAME                    | Target DB name                                                                                                                                                                                            | -        |
| MONGODB_USERNAME                  | DB login username                                                                                                                                                                                         | -        |
| MONGODB_PASSWORD                  | DB login password                                                                                                                                                                                         | -        |
| MONGODB_AUTHDB                    | Authentication DB name                                                                                                                                                                                    | -        |
| CRONMODE                          | If set "true", this container is executed in cron mode.  In cron mode, the script will be executed with the specified arguments and at the time specified by CRON_EXPRESSION.                             | "false"  |
| CRON_EXPRESSION                   | Cron expression (ex. "CRON_EXPRESSION=0 4 * * *" if you want to run at 4:00 every day)                                                                                                                    | -        |
| AWSCLI_ENDPOINT_OPT               | Set a custom S3 endpoint if you use a S3 based service like DigitalOcean Spaces. (ex. AWSCLI_ENDPOINT_OPT="https://fra1.digitaloceanspaces.com") If not set the Amazon S3 standard endpoint will be used. | -        |
| AWSCLIOPT                         | Other options you want to pass to `aws` command                                                                                                                                                           | -        |
| GCSCLIOPT                         | Other options you want to pass to `gsutil` command                                                                                                                                                        | -        |
| HEALTHCHECKS_URL                  | URL that gets called after a successful backup (eg. https://healthchecks.io)                                                                                                                              | -        |
