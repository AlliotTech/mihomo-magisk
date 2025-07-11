#!/system/bin/sh
MODDIR="${0%/*}"
# Mihomo Magisk Action Script
# 响应用户操作，提供“启动/停止”按钮

MODDIR="${0%/*}"
SERVICE_SH="$MODDIR/service.sh"
MODULE_PROP="$MODDIR/module.prop"

# 获取 mihomo 当前状态
getStatus() {
  status=$("$SERVICE_SH" status)
  if [ "$status" = "running" ]; then
    echo "running"
  else
    echo "stopped"
  fi
}

# 更新 module.prop 的 description 字段
updateDescription() {
  statusEmoji=$1
  statusText=$2
  # 只替换 description 行，限制总长度50字符内
  desc="Mihomo $statusEmoji $statusText"
  desc=$(echo "$desc" | cut -c1-50)
  sed -i "s/^description=.*/description=$desc/" "$MODULE_PROP"
}

# 主逻辑：根据用户输入切换状态
case "$1" in
  start)
    "$SERVICE_SH" start
    updateDescription "🚀" "已启动 | 后台守护运行中"
    ;;
  stop)
    "$SERVICE_SH" stop
    updateDescription "🛑" "已停止 | 未在运行"
    ;;
  status)
    getStatus
    ;;
  ""|toggle)
    # 优化：每次切换前先获取实际状态再决定操作
    currentStatus=$(getStatus)
    if [ "$currentStatus" = "running" ]; then
      "$SERVICE_SH" stop
      updateDescription "🛑" "已停止 | 未在运行"
    else
      "$SERVICE_SH" start
      updateDescription "🚀" "已启动 | 后台守护运行中"
    fi
    ;;
  *)
    echo "用法: $0 {start|stop|status}"
    ;;
esac
