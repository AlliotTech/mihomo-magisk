# mihomo-magisk

一个简单的 Magisk 模块，用于以 root 权限在后台运行 mihomo 内核。 初衷是为了实现使用 mihomo 内核自带的 tun 模式来管理网， 模块仅管理内核进程， 不操作任何路由规则与 iptables。   
使用了与 box4magisk 相同的配置路径与内核路径。  

## 项目简介
mihomo-magisk 通过后台运行 `/data/adb/box/bin/mihomo -d /data/adb/box/mihomo` 启动 mihomo 内核，并将运行日志输出到指定日志文件。模块通过 action.sh 提供“启动/停止”操作，并在 module.prop 的 description 字段中反馈 mihomo 当前状态。

## 主要功能
- 后台以 root 权限运行 mihomo 内核
- 日志输出至 `/data/adb/box/mihomo/mihomo-magisk.log`，并定期轮换，防止日志过大
- 通过 action.sh 响应用户“启动/停止”操作
- 操作后自动更新 module.prop 的 description 字段，显示 mihomo 状态  

## 安装方法
1. 确保你的设备已安装 Magisk 并已获取 root 权限。
2. 下载本模块的 zip 包，通过 Magisk Manager 安装。
3. 安装完成后，重启设备。

## 使用方法
- 进入 Magisk Manager，找到 mihomo-magisk 模块。
- 点击“启动”或“停止”按钮以控制 mihomo 内核。
- 每次操作后，可在模块信息中查看 mihomo 当前状态。
- 日志文件位于 `/data/adb/box/mihomo/mihomo-magisk.log`。

## 注意事项
- **请勿直接操作 `/data/adb/box` 路径**，该路径属于 box4magisk 模块，直接操作可能让 box4magisk 模块无法正常使用。 
- 日志轮换仅操作日志目录下的日志文件，防止误删其他文件。
- 由于模块拥有系统全部权限，涉及 `rm` 等高危操作时请务必确保安全。

## 贡献方式
欢迎提交 issue 或 pull request 参与本项目开发。

## 许可证
本项目采用 MIT License。 