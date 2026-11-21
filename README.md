# bt-pyenv313-builder

在 GitHub Actions 里用 `ubuntu:26.04` 容器源码编译宝塔面板的 **pyenv313**，产出可直接搬到目标机使用的压缩包。

## 为什么这么做

目标机（Ubuntu 26.04、3.4G 内存、磁盘紧张）跑 `make -j4` 编译 CPython 3.13 会被内核 OOM Killer 杀掉。
宝塔脚本对该失败**返回 EXIT=0 并打印「修复成功」**，属于假成功，`pyenv313` 实际不存在。

宝塔官方没有 Ubuntu 26.04 的预编译包（`download.bt.cn/install/pyenv/` 下所有候选 404），只能源码编译。
所以把编译搬到云端，用 Actions 的 4 核 / 16G 机器完成，只把成品拉回来。

## 运行

```bash
# 手动触发（jobs 默认 2）
gh workflow run build-py313.yml -R cshdotcom/bt-pyenv313-builder -f jobs=2

# 或网页 Actions → build-pyenv313 → Run workflow
```

产物：Artifacts → `pyenv313-ubuntu2604-x86_64` → `pyenv313-ubuntu2604-x86_64.tar.gz`

## 目标机部署

```bash
# 1. 清理旧残留
bash scripts/cleanup-local.sh

# 2. 上传压缩包到 /tmp 后
bash scripts/deploy-on-target.sh /tmp/pyenv313-ubuntu2604-x86_64.tar.gz

# 3. 切换面板组件到 3.13
curl -kfsSL https://download.miku.ci/install/update_panel.sh | bash
```

## 硬性约束

- 只能用于 **x86_64 + Ubuntu 26.04**。跨 Ubuntu 大版本会因 glibc / OpenSSL 版本不匹配报 `GLIBC_x.xx not found`。
- 编译必须在 `ubuntu:26.04` 容器里做，不能在 Actions 宿主（ubuntu-24.04）直接编译。
- 压缩包内路径写死为 `/www/server/panel/pyenv313`，解压位置必须是 `/www/server/panel`。

## 注意

- 脚本 `upgrade_py313.sh` 属于第三方（宝塔官方 CDN），这里只做下载执行，未做校验。
- Actions 免费额度有限，单次构建约 10–25 分钟。
