#!/bin/sh
set -e

# Cloud Foundry 会通过 $PORT 环境变量告诉容器监听哪个端口（每次可能不同）
PORT=${PORT:-8080}

# UUID 优先用你自己设的；没设就随机生成一个
UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}

# WebSocket 路径，相当于第二道密码
WS_PATH=${WS_PATH:-/ray}

# 用环境变量渲染出真正的配置文件
sed -e "s/__PORT__/${PORT}/g" \
 -e "s/__UUID__/${UUID}/g" \
 -e "s#__WS_PATH__#${WS_PATH}#g" \
 /etc/xray/config.json > /tmp/config.json

echo "Starting xray: port=${PORT} ws_path=${WS_PATH}"

# 如果设置了 Cloudflare Tunnel 的 token，就在后台启动 cloudflared
# 注意：不要把 token 打到日志里
if [ -n "$CF_TUNNEL_TOKEN" ]; then
  echo "Starting cloudflared tunnel..."
  /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "$CF_TUNNEL_TOKEN" &
else
  echo "CF_TUNNEL_TOKEN not set, skipping cloudflared."
fi

exec /usr/local/bin/xray run -c /tmp/config.json
