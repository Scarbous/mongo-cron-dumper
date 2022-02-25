FROM alpine:3

ENV CRON_TIME="4 2 * * *"
ENV MAX_BACKUPS=7
ENV EXTRA_ARGUMENTS="--gzip"
ENV EXTRA_OPTS_RESTORE="--gzip"
ENV MONGODB_DB=
ENV MONGODB_DB_FILE=
ENV MONGODB_HOST="mongo"
ENV MONGODB_HOST_FILE=
ENV MONGODB_PORT="27017"
ENV MONGODB_PORT_FILE=
ENV MONGODB_USER=
ENV MONGODB_USER_FILE=
ENV MONGODB_PASS=
ENV MONGODB_PASS_FILE=


RUN apk --update add --no-cache bash mongodb-tools \
    && rm -rf /var/cache/apk/*

ADD ./entripoint.sh /scripts/entripoint.sh
ADD ./dumper.sh /scripts/dumper.sh
RUN chmod +x /scripts/*.sh \
    && mkdir /backup

VOLUME ["/backup"]

ENTRYPOINT [ "/scripts/entripoint.sh" ]

