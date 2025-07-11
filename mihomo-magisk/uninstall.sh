#!/system/bin/sh
# Mihomo Magisk Uninstall Script
# 卸载时安全清理日志和 pid 文件，仅限本模块产生的内容

# 日志文件路径
LOG_FILE="/data/adb/box/mihomo/mihomo-magisk.log"
LOG_BAK="/data/adb/box/mihomo/mihomo-magisk.log.1"
# PID 文件路径（假定模块目录下）
MODDIR="${0%/*}"
PID_FILE="$MODDIR/mihomo.pid"

# 删除日志文件（仅限本模块产生的）
rm -f "$LOG_FILE" "$LOG_BAK"
# 删除 pid 文件
rm -f "$PID_FILE"
