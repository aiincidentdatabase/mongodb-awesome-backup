FROM alpine:3.12

LABEL maintainer="Sean McGregor <mongodb-awesome-backup@seanbmcgregor.com>"

RUN apk add --no-cache \
    coreutils \
    bash \
    tzdata \
    py3-pip \
    mongodb-tools \
    curl

# install awscli
RUN pip install awscli

# install wrangler (Cloudflare R2 cli)
RUN pip install wrangler

ENV AWS_DEFAULT_REGION=ap-northeast-1

COPY bin /opt/bin
WORKDIR /opt/bin
ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["backup_full_snapshot", "backup_filtered_data", "prune", "list"]
