ARG CURRENT_VERSION_MICRO

FROM pfillion/mobycron:latest as mobycron
FROM nginx:$CURRENT_VERSION_MICRO

# Build-time metadata as defined at https://github.com/opencontainers/image-spec
ARG DATE
ARG COMMIT
ARG AUTHOR

LABEL \
    org.opencontainers.image.created=$DATE \
    org.opencontainers.image.url="https://hub.docker.com/r/pfillion/reverse-proxy" \
    org.opencontainers.image.source="https://github.com/pfillion/reverse-proxy" \
    org.opencontainers.image.version=$CURRENT_VERSION_MICRO \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor="pfillion" \
    org.opencontainers.image.title="reverse-proxy" \
    org.opencontainers.image.description="A nginx reverse proxy with more modules and tools" \
    org.opencontainers.image.authors=$AUTHOR \
    org.opencontainers.image.licenses="MIT"

RUN apk add --update --no-cache \
    lego \
    libressl \
    nginx-mod-stream

COPY rootfs /
COPY --from=mobycron /usr/bin/mobycron /usr/bin

ENV LEGO_MODE=staging
ENV MOBYCRON_ENABLED=true

ENTRYPOINT [ "entrypoint.sh" ]