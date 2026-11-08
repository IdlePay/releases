FROM alpine:3.20

ARG VERSION
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/IdlePay/releases" \
      org.opencontainers.image.title="IdlePay" \
      org.opencontainers.image.description="IdlePay bandwidth-sharing client" \
      org.opencontainers.image.url="https://idlepay.io/download"

RUN set -eu; \
    test -n "$VERSION"; \
    apk add --no-cache ca-certificates; \
    base="https://github.com/IdlePay/releases/releases/download/v${VERSION}"; \
    asset="idlepay_linux_${TARGETARCH}"; \
    wget -qO /usr/local/bin/idlepay "$base/$asset"; \
    want="$(wget -qO- "$base/$asset.sha256" | cut -d' ' -f1)"; \
    echo "$want  /usr/local/bin/idlepay" | sha256sum -c -; \
    chmod 755 /usr/local/bin/idlepay

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENV IDLEPAY_CONFIG=/etc/idlepay/config.json
VOLUME /etc/idlepay

ENTRYPOINT ["/entrypoint.sh"]
