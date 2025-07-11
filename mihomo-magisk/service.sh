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

# 检查 mihomo 是否已在运行（增强：校验进程名）
isMihomoRunning() {
  if [ -f "$PID_FILE" ]; then
    pid=$(cat "$PID_FILE")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      # 校验进程名是否为 mihomo
      pname=$(ps -p "$pid" -o comm= 2>/dev/null | tr -d '\n')
      if [ "$pname" = "mihomo" ]; then
        return 0
      fi
    fi
  fi
  return 1
}

# 日志轮换函数，仅操作日志目录下的日志文件，防止误删其他文件（加锁）
rotateLogs() {
  LOG_DIR="$MIHOMO_DATA"
  MAX_LOG_SIZE=1048576  # 1MB
  LOG_BAK="$LOG_FILE.1"
  LOCK_FILE="$LOG_FILE.lock"

  # 加锁，避免并发写
  exec 9>"$LOCK_FILE"
  flock 9

  if [ -f "$LOG_FILE" ]; then
    logSize=$(stat -c%s "$LOG_FILE" 2>/dev/null || stat -f%z "$LOG_FILE")
    if [ "$logSize" -ge "$MAX_LOG_SIZE" ]; then
      mv "$LOG_FILE" "$LOG_BAK"
      touch "$LOG_FILE"
      echo "[日志轮换] mihomo-magisk.log 已轮换为 mihomo-magisk.log.1" >> "$LOG_FILE"
    fi
  fi

  # 解锁
  flock -u 9
  rm -f "$LOCK_FILE"
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
