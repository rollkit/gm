FROM ghcr.io/rollkit/gm:v0.1.0

USER root

# hadolint ignore=DL3018
RUN apk --no-cache add \
        curl \
        jq

COPY setup.sh entrypoint.sh /home/

RUN /bin/sh /home/setup.sh

USER ${USER_NAME}

ENTRYPOINT [ "/bin/sh", "/home/entrypoint.sh" ]
