#!/system/bin/sh
# Mihomo Magisk Service Script
# 启动 mihomo 内核为守护进程，并输出日志

# 模块目录
MODDIR="${0%/*}"
# mihomo 二进制路径
MIHOMO_BIN="/data/adb/box/bin/mihomo"
# mihomo 数据目录
MIHOMO_DATA="/data/adb/box/mihomo"
# 日志文件路径
LOG_FILE="$MIHOMO_DATA/mihomo-magisk.log"
# PID 文件路径
PID_FILE="$MODDIR/mihomo.pid"

# 检查 mihomo 是否已在运行
isMihomoRunning() {
  if [ -f "$PID_FILE" ]; then
    pid=$(cat "$PID_FILE")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      # 校验 /proc/$pid/exe 指向的可执行文件名
      exe_link=$(readlink "/proc/$pid/exe" 2>/dev/null)
      if [ "$exe_link" = "$MIHOMO_BIN" ]; then
        return 0
      fi
      # 或进一步校验 /proc/$pid/cmdline
      cmdline=$(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ')
      case "$cmdline" in
        *"$MIHOMO_BIN"*) return 0;;
      esac
    fi
  fi
  return 1
}

# 日志轮换函数，不加锁，仅操作日志目录下的日志文件
rotateLogs() {
  LOG_DIR="$MIHOMO_DATA"
  MAX_LOG_SIZE=1048576  # 1MB
  LOG_BAK="$LOG_FILE.1"

  if [ -f "$LOG_FILE" ]; then
    logSize=$(stat -c%s "$LOG_FILE" 2>/dev/null || stat -f%z "$LOG_FILE")
    if [ "$logSize" -ge "$MAX_LOG_SIZE" ]; then
      mv "$LOG_FILE" "$LOG_BAK"
      touch "$LOG_FILE"
      echo "[日志轮换] mihomo-magisk.log 已轮换为 mihomo-magisk.log.1" >> "$LOG_FILE"
    fi
  fi
}

# 启动 mihomo（增强：检测二进制）
startMihomo() {
  if isMihomoRunning; then
    echo "mihomo 已在运行 (PID: $(cat $PID_FILE))"
    return 0
  fi
  # 检查二进制
  if [ ! -x "$MIHOMO_BIN" ]; then
    echo "[错误] 未找到可执行的 mihomo 二进制：$MIHOMO_BIN"
    return 1
  fi
  rotateLogs
  nohup "$MIHOMO_BIN" -d "$MIHOMO_DATA" >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  echo "mihomo 已启动 (PID: $(cat $PID_FILE))"
}

# 停止 mihomo
stopMihomo() {
  if isMihomoRunning; then
    pid=$(cat "$PID_FILE")
    kill "$pid" 2>/dev/null
    rm -f "$PID_FILE"
    echo "mihomo 已停止"
  else
    echo "mihomo 未在运行"
  fi
}

# 入口：根据参数执行操作
case "$1" in
  start)
    startMihomo
    ;;
  stop)
    stopMihomo
    ;;
  status)
    if isMihomoRunning; then
      echo "running"
    else
      echo "stopped"
    fi
    ;;
  *)
    echo "用法: $0 {start|stop|status}"
    ;;
esac