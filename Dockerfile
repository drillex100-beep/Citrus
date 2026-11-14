FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS builder
ARG TARGETPLATFORM
RUN echo "I'm building for $TARGETPLATFORM"

RUN apk add --no-cache gzip && \
    mkdir /citrus-config && \
    wget -O /citrus-config/geoip.metadb https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb && \
    wget -O /citrus-config/geosite.dat https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat && \
    wget -O /citrus-config/geoip.dat https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat

COPY docker/file-name.sh /citrus/file-name.sh
WORKDIR /citrus
COPY bin/ bin/
RUN FILE_NAME="$(sh file-name.sh).gz" && \
    gzip -dc "bin/$FILE_NAME" > citrus && chmod +x citrus
FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
LABEL org.opencontainers.image.source="https://github.com/getmikan/Citrus"

RUN apk add --no-cache ca-certificates tzdata iptables

VOLUME ["/root/.config/citrus/"]

COPY --from=builder /citrus-config/ /root/.config/citrus/
COPY --from=builder /citrus/citrus /citrus
ENTRYPOINT [ "/citrus" ]
