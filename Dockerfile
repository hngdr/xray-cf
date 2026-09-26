FROM alpine:latest

# 安装 Xray（VLESS/VMess 内核）
RUN apk add --no-cache ca-certificates curl unzip \
    && mkdir -p /usr/local/bin /etc/xray \
    && curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip -q /tmp/xray.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/xray \
    && rm -f /tmp/xray.zip \
    && apk del curl unzip

COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
