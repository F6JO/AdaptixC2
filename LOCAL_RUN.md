# macOS 原生本地运行

此目录使用已安装的 Go、Clang、CMake、Qt 6.12 和 OpenSSL 3，不通过 Docker 运行。下面的启动脚本不会安装或升级软件，也不会修改 shell 配置或注册后台服务。

## 启动和停止

终端一启动服务端：

```bash
cd /Users/admin/cursor/pro/AdaptixC2
./start-server.sh
```

终端二启动桌面客户端：

```bash
cd /Users/admin/cursor/pro/AdaptixC2
./start-client.sh
```

客户端选择 `Local` 配置后点击 Connect。若没有该配置，可点击 Load Profile，选择项目中的 `.local/Local.adaptixProfile`。

连接地址：`https://127.0.0.1:4321/endpoint`，用户名为 `local`。随机生成的密码保存在 `.local/connection.txt` 和 `.local/server/profile.yaml` 中。连接资料、私钥和服务端配置仅允许当前用户读写，并已通过 `.gitignore` 排除。

关闭客户端窗口即可退出客户端；在服务端终端按 Ctrl+C 停止服务端。脚本以前台方式运行，不自动驻留或开机启动。

## 项目内文件位置

| 内容 | 相对项目根目录的位置 |
| --- | --- |
| 已有服务端和七个扩展 | `dist/` |
| 客户端构建和可执行文件 | `build/native-client/` |
| 服务端配置、自签名证书和私钥 | `.local/server/` |
| 服务端 SQLite 和运行数据 | `.local/server/data/` |
| 客户端配置数据库、主题 | `.local/client/` |
| 客户端各项目文件 | `.local/projects/` |
| 本地连接资料与导入文件 | `.local/connection.txt`、`.local/Local.adaptixProfile` |
| 构建、启动检查日志 | `.local/logs/` |
| 临时文件和工具缓存 | `.local/tmp/`、`.local/cache/`、`.local/go/` |

Qt、OpenSSL、Clang 等已安装工具仍从原安装位置读取；不会复制或改动它们。操作系统可能自行产生系统日志。通过文件选择器主动选择其他目录时，文件会写入所选位置。

服务端只绑定 `127.0.0.1:4321`。证书覆盖 `localhost` 和 `127.0.0.1`，有效期一年；无需导入系统钥匙串。

`start-client.sh` 使用 `ADAPTIX_DATA_DIR` 和 `ADAPTIX_PROJECTS_DIR` 指定项目内存储。直接双击客户端二进制或绕过启动脚本，会回到上游默认的用户目录存储方式。

## 重新编译客户端

```bash
cd /Users/admin/cursor/pro/AdaptixC2
./build-client.sh
```

该脚本使用现有 Qt 和 OpenSSL，不安装依赖。它显式指定当前 macOS SDK 的 libc++ 头文件目录，避免此机器上 Clang 默认搜索路径缺少 `type_traits` 的问题。

默认并行编译数为 6，可通过 `ADAPTIX_BUILD_JOBS=4 ./build-client.sh` 调整。Qt 和 OpenSSL 默认路径分别为 `/opt/homebrew/opt/qt` 和 `/opt/homebrew/opt/openssl@3`，可通过 `ADAPTIX_QT_PREFIX` 和 `ADAPTIX_OPENSSL_PREFIX` 指向其他已安装版本。

服务端及插件复用本次配置前已经生成的 arm64 产物。后续如需重编译，应确保服务端与七个插件使用相同的 Go 工具链、依赖版本和 `GOEXPERIMENT=jsonv2,greenteagc`；不要设置 `CGO_ENABLED=0`。`make` 默认目标和 `make server-ext` 会清理 `dist/`，不应在有运行数据时随意使用。

本地启动环境将后续 Go 缓存放到项目中，并关闭 Go 工具链自动切换；项目内 Go 模块缓存目前不保证齐全。额外生成内容如果缺少依赖，仍可能需要下载，执行前应先确认。

## 本次验证

- arm64 客户端已编译成功。
- 服务端已临时启动，使用本地证书校验通过的 HTTPS 登录取得正常响应；启动日志没有插件加载错误。
- 客户端已在 offscreen 模式下初始化，项目内 SQLite 数据库和 `Local` 连接配置可正常读取。
- 用户目录的 `.adaptix` 和 `AdaptixProjects` 目录状态未变化；检查结束后已停止测试进程。

这些检查覆盖编译、服务端启动和登录、客户端无界面初始化；尚未通过实际桌面窗口验证点击连接。检查记录见 `.local/logs/native-check.json`、`.local/logs/server-check.log` 和 `.local/logs/client-check.log`。
