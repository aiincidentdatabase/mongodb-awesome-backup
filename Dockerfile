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

ENV AWS_DEFAULT_REGION=ap-northeast-1

COPY bin /opt/bin
WORKDIR /opt/bin
ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["backup_snapshot", "prune", "list", "backup_csv_data", "prune", "list"]
