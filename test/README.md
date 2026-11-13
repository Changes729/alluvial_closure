# closure 测试用例

每个 `.sh` 文件是一个独立用例：自带 fixture，在独立临时目录运行，互不依赖。
下面逐个说明每个用例**模拟的用户具体操作**，以及工具应有的反应。

## 运行

```sh
./test.sh                    # 运行全部（上级目录的运行器）
SH=/bin/sh ./test.sh         # 指定解释器
sh test/05-dir-fuse.sh       # 单独运行一个用例
```

运行器按退出码聚合结果（`finish()` 失败时非 0 退出），末尾输出总览。

---

## 01-entry-basic.sh —— 基本调用

模拟用户在某个目录准备了一个 `.echo` 配置文件，想用 `echo` 输出它写好的内容：

```sh
$ cat .echo
hello world
$ closure .echo
hello world          # 相当于执行了 echo hello world
```

断言：退出码 0、输出与配置内容一致。

## 02-split-words.sh —— 按空白拆词

模拟用户的配置写得比较随意——多余空格、制表符、空行：

```sh
$ cat .echo
  a	 b

c
$ closure .echo
a b c                # 三个参数 a、b、c，空白被归一
```

断言：输出为 `a b c`。

## 03-dir-missing-config.sh —— 目录条目但没有同名配置

模拟用户建了目录条目 `.echo/`，往里放了几个文件（`a.txt`、`b.txt`、`sub/c.txt`），
但没有创建 `.echo/.echo` 同名配置文件，然后调用 `closure .echo`：

期望：工具**不拼接**目录内任何文件，`echo` 以空参数运行（无输出、退出 0）。
这验证目录条目只认同名配置文件。

## 04-dir-samename.sh —— 目录自带同名配置

模拟用户在目录条目里放了自己的配置和其他文件：

```sh
$ mkdir .echo && cd .echo
$ echo 'inner args' > .echo      # 同名配置
$ echo 'noise'      > a.txt      # 干扰文件
$ cd ..
$ closure .echo
inner args           # a.txt 被忽略
```

第二段模拟用户带尾部斜杠调用 `closure .echo/`——与 `closure .echo` 完全等价。

## 05-dir-fuse.sh —— 目录条目 FUSE overlay 运行

模拟用户的转换场景：输入文件放在条目目录里，希望输出落在同级目录。

用户执行 `closure .cat` 后，工具依次帮用户完成：

1. 在同目录创建 `cat/`（条目名去掉开头的点）；
2. 在 tmp 下创建一个 work 目录；
3. 执行 `alluvial_fuse --mount=.cat --upperdir=cat --workdir=<tmp 目录>` 挂载；
4. 进入 `.cat`，执行 `cat in.txt`（应用在挂载点内运行）；
5. 回到上级目录；
6. 解除 FUSE 挂载，清理 work 目录；同级目录为空（应用无输出）则一并删除。

本用例分两段验证：

**读**：`.cat/` 配置写 `in.txt`，应用在挂载点内执行 `cat in.txt`，
读到的就是 `.cat/in.txt` 的原内容，输出 `DIRDATA`；运行结束后挂载已解除，
且应用无输出，自动创建的同级 `cat/` 被清理（不留空目录）。

**写**：`.cp/` 配置写 `in.txt out.txt`，应用在挂载点内执行
`cp in.txt out.txt`；生成的 `out.txt` 落在同级 `cp/` 目录，
`.cp/` 内没有新文件，内容与原文件一致；有输出，`cp/` 保留。

## 06-extra-args.sh —— 额外参数

模拟用户临时追加参数：

```sh
$ cat .echo
hello world
$ closure .echo X Y
hello world X Y      # 拼装参数在前，X Y 原样追加在后
```

## 07-literal.sh —— 字面拆词

模拟用户配置里写了引号和星号，期望原样传递而非被 shell 解释：

```sh
$ cat .echo
"a  b" *
$ closure .echo
"a b" *              # 引号不配对、星号不展开，词内空白归一后按字面传给应用
```

## 08-no-app.sh —— 找不到应用

模拟配置条目跨环境复用：当前机器没有 `.definitely_not_an_app_xyz`
对应的应用（创建了条目但应用不存在）。用户运行 `closure .definitely_not_an_app_xyz`：

期望：什么都不做、无任何输出、退出 0（规则 2）——闭包在缺应用的机器上静默跳过。

## 09-no-entry.sh —— 条目不存在

模拟用户敲错名字：`closure .no_such`，当前目录没有这个条目。

期望：stderr 报错 `closure: 条目不存在：.no_such`，退出码 2。

## 10-no-args.sh —— 裸调用

模拟用户直接敲 `closure` 不带条目（扫描模式已移除）。

期望：stderr 打印 `usage:` 用法说明，退出码 2。

## 11-empty-config.sh —— 空配置

模拟用户建了一个空配置文件 `.true`，只想起个「调用这个应用」的作用：

期望：`true` 正常被调用（退出 0），无额外输出——空配置等于零参数。

## 12-help.sh —— 帮助

模拟用户敲 `closure -h` 查看用法。

期望：退出码 0，stderr 输出以 `usage:` 开头的说明。

## 13-non-dot.sh —— 非 . 开头

模拟用户误传普通名字 `closure echo`（没有点前缀）。

期望：报错退出 2——条目必须以 `.` 开头（规则 1）。

## 14-dryrun.sh —— 预演模式

模拟用户想先看看命令长什么样再真正执行。用户把脚本硬链接一份：

```sh
$ ln closure closure-dryrun
$ closure-dryrun .echo X Y
echo hello world X Y     # 只打印将执行的命令，什么都不运行
$ closure .echo
hello world              # 原名字照常真正执行
```

硬链接建在 `${CLO}-dryrun`（与脚本同目录，保证同文件系统），用完即删，
trap 兜底防中途夭折。另验证：目录路径转换在预览中如实呈现（`cp .cp/in.txt out.txt`）、
预演下应用确实未运行（marker 文件未产生）、无应用时同样静默。

---

## lib.sh 提供

- `SH` 解释器（透传运行器的 `SH=` 环境变量，默认 `sh`）、`CLO` 被测脚本绝对路径
- `ok 名称 期望值 实际值` 断言，自动计数并打印 `ok`/`FAIL`
- 独立 `mktemp` 工作目录，`trap` 退出时清理（含 `${CLO}-dryrun` 硬链接兜底）
- `finish` 收尾：打印 `pass/fail` 小结，失败则非 0 退出

## 新增用例

1. 按 `NN-主题.sh` 命名（`NN` 递增，运行器按 glob 顺序执行）；
2. 首行 `source "$(dirname "$0")/lib.sh"`，末行 `finish`；
3. fixture 在用例内自建，不依赖其他用例的残留状态；
4. 在本 README 增加对应小节，写清模拟的用户操作与期望行为。
