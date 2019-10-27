FROM alpine:latest

ARG BUILD_RFC3339="1970-01-01T00:00:00Z"
ARG COMMIT="local"
ARG VERSION="dirty"

STOPSIGNAL SIGKILL

LABEL org.opencontainers.image.ref.name="jnovack/flexget" \
      org.opencontainers.image.created=$BUILD_RFC3339 \
      org.opencontainers.image.authors="Justin J. Novack <jnovack@gmail.com>" \
      org.opencontainers.image.documentation="https://github.com/jnovack/docker-flexget/README.md" \
      org.opencontainers.image.description="Simple Flexget Container" \
      org.opencontainers.image.licenses="GPLv3" \
      org.opencontainers.image.source="https://github.com/jnovack/docker-flexget" \
      org.opencontainers.image.revision=$COMMIT \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.url="https://hub.docker.com/r/jnovack/flexget/"

ENV BUILD_RFC3339 "$BUILD_RFC3339"
ENV COMMIT "$COMMIT"
ENV VERSION "$VERSION"

RUN mkdir /opt/flexget && \
    apk add --update --no-cache python3 ca-certificates && \
    pip3 install --no-cache-dir --upgrade pip flexget transmissionrpc

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

VOLUME /opt/flexget
WORKDIR /opt/flexget

ENTRYPOINT [ "/entrypoint.sh" ]
COPY entrypoint.sh /
