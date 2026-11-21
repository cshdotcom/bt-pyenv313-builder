#!/bin/bash
# 用法: bash deploy-on-target.sh /tmp/pyenv313-ubuntu2604-x86_64.tar.gz
set -euo pipefail

PKG="${1:-}"
[ -f "$PKG" ] || { echo "找不到压缩包: $PKG"; exit 1; }

echo "== 1) 前置检查 =="
[ "$(uname -m)" = "x86_64" ] || { echo "仅支持 x86_64"; exit 1; }
grep -qi "26.04" /etc/os-release || { echo "仅支持 Ubuntu 26.04"; exit 1; }
df -Pm / | awk 'NR==2{print "剩余磁盘: "$4" MB"}'

echo "== 2) 解压到 /www/server/panel =="
rm -rf /www/server/panel/pyenv313
tar -xzf "$PKG" -C /www/server/panel
[ -x /www/server/panel/pyenv313/bin/python3.13 ] || { echo "解压后缺少 python3.13"; exit 1; }

echo "== 3) 校验二进制 =="
/www/server/panel/pyenv313/bin/python3.13 -V
/www/server/panel/pyenv313/bin/python3.13 -c "import ssl,sqlite3,ctypes,hashlib,lzma;print('OPENSSL',ssl.OPENSSL_VERSION,'SQLITE',sqlite3.sqlite_version)"

echo "== 4) 替换面板 Python 环境 =="
wget -q -O /tmp/upgrade_py313.sh https://cmcc1-node.bt.cn/install/pyenv/upgrade_py313.sh
bash /tmp/upgrade_py313.sh --replace

echo "== 5) 结果 =="
/etc/init.d/bt restart
sleep 3
ps -ef | grep -E "BT-Panel" | grep -v grep
echo "如需切换到 3.13 组件文件，再执行:"
echo "curl -kfsSL https://download.miku.ci/install/update_panel.sh | bash"
