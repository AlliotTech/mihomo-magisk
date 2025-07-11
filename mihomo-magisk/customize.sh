#!/system/bin/sh
# Reserved for custom installation logic. Currently empty.

# 使用 Magisk 官方 set_perm 赋权，确保所有脚本可执行
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/customize.sh" 0 0 0755
