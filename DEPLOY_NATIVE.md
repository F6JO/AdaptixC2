# Linux 原生常规版本

此版本强制关闭 Beacon 的 IAT Hiding。生成界面禁用该选项；后端同时忽略旧客户端或已保存配置中的 `iat_hiding: true`，保留标准 C/C++ 运行库链接。

## 构建

使用 Linux x86_64、已安装的 Go >= 1.25.4、Clang/GCC、Make 和 MinGW x64 交叉编译器。脚本不会安装工具；首次构建会按 go.mod 下载 Go 依赖。

```bash
ADAPTIX_GO=/root/AdaptixC2/tools/go1.26.1/bin/go \
ADAPTIX_STATE_ROOT=/root/AdaptixC2/.local \
ADAPTIX_BUILD_JOBS=1 \
./build-server-linux.sh /root/AdaptixC2/releases/<commit>
```

服务端和七个 Go 插件由同一工具链、依赖工作区和编译参数构建。Beacon 的四个协议目录包含模板、Windows x64 对象和输出所需资源；如果系统已有 x86 交叉编译器，也会构建 x86。配置、私钥、证书和数据库不进入构建产物。

## 保留现有运行目录

已有运行目录继续保存 `profile.yaml`、证书和 `data/`。部署前对这些文件及其他服务的状态做快照，数据库使用 SQLite 在线备份，并在停止旧进程后保存最终一致的副本。

仅将运行目录中的 `adaptixserver`、`extenders` 和 `404page.html` 指向已验证的 release。旧文件移入项目内备份目录以便回滚。保持服务端工作目录不变；配置中的相对路径和原有数据库由此保持有效。

不要在运行目录执行 `make clean`、`make server-ext`，也不要复制示例 profile 覆盖现有配置。

## screen 托管

确认原 Adaptix 进程及 screen 会话的身份后，只停止该进程，再使用已有 `c2` 会话中的专用窗口启动：

```bash
/root/AdaptixC2/source/scripts/run-screen-server.sh \
  /root/AdaptixC2/adaptix-server-linux-x64 \
  /root/AdaptixC2/releases/<commit> \
  /root/AdaptixC2/tools/go1.26.1/bin/go
```

`screen -r c2` 查看会话，`Ctrl+A` 再按 `D` 分离。screen 只负责断开 SSH 后保持进程运行，不提供主机重启后的自动启动。

验收应覆盖：实际监听地址、HTTPS 登录、七个插件加载、原 listener 恢复、关闭 IAT Hiding 的常规构建，以及配置/证书/业务数据和其他服务状态的一致性。不得以日志中单独出现 ready 判断全部成功。
