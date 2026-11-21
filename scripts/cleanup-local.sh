#!/bin/bash
# 在目标机（小内存宿主）执行：清除所有 py313 编译残留，回到升级前状态。不碰网站/数据库/面板配置。
set -u

echo "== 1) 删除 pyenv313 半成品 =="
rm -rf /www/server/panel/pyenv313 /www/server/panel/extract_temp

echo "== 2) 删除 /tmp 编译残留 =="
rm -rf /tmp/Python-3.13.* /tmp/python-3.13.* /tmp/py313* /tmp/panel.zip
rm -rf /tmp/*.tar.xz /tmp/*.tar.gz /tmp/*.sh /tmp/extract_temp

echo "== 3) 删除本地脚本/日志/垫片 =="
rm -f /root/fix_py313.sh /root/py313.log /root/py313_final.log
rm -f /usr/local/bin/getconf

echo "== 4) 回收 swap 文件 =="
swapoff /swapfile_bt 2>/dev/null
rm -f /swapfile_bt

echo "== 5) 清缓存与旧日志 =="
apt-get clean
journalctl --vacuum-size=15M 2>/dev/null
find /www/wwwlogs -type f -name "*.log" -size +50M -delete 2>/dev/null

echo "== 6) 重启面板（回到旧 pyenv/python3.7） =="
/etc/init.d/bt restart
sleep 3

echo "== 校验 =="
ls -ld /www/server/panel/pyenv313 2>/dev/null || echo "pyenv313 已删除 OK"
/www/server/panel/pyenv/bin/python3.7 -V
ps -ef | grep -E "BT-Panel|BT-Tasks" | grep -v grep
df -h /
