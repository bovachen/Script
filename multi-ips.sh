#!/bin/bash

# 确保脚本以 root 用户运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本"
  exit 1
fi

# 创建 systemd 服务文件
SERVICE_FILE="/etc/systemd/system/add-multiple-ips.service"
echo "创建 systemd 服务文件：$SERVICE_FILE"
cat <<EOL > $SERVICE_FILE
[Unit]
Description=Add multiple IP addresses to network interface
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /usr/local/bin/add-multiple-ips.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOL

# 创建添加 IP 的脚本
SCRIPT_FILE="/usr/local/bin/add-multiple-ips.sh"
echo "创建 IP 添加脚本：$SCRIPT_FILE"
cat <<EOL > $SCRIPT_FILE
#!/bin/bash

# 添加多个 IP 地址到 ens5 接口
ip addr add 172.31.50.246/20 dev ens5
ip addr add 172.31.50.67/20 dev ens5
ip addr add 172.31.50.142/20 dev ens5
ip addr add 172.31.50.113/20 dev ens5
EOL

# 设置脚本可执行权限
chmod +x $SCRIPT_FILE
echo "赋予脚本可执行权限"

# 重新加载 systemd 配置
echo "重新加载 systemd 配置"
systemctl daemon-reload

# 启用并启动服务
echo "启用服务并设置开机自动运行"
systemctl enable add-multiple-ips.service
systemctl start add-multiple-ips.service

# 验证 IP 是否成功附加
echo "验证 IP 是否成功附加："
ip addr show dev ens5

echo "脚本执行完成！所有 IP 已添加并设置为开机自动附加。"
