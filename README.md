# closure

closure 是一个命令行辅助工具，从 Plan Alluvial 衍伸而来（同门工具：[`alluvial_fuse`](https://github.com/Changes729/alluvial_fuse)）。

[English](#english)


当某个目录下存在一个 `.应用名` 配置文件，或者配置文件目录时，closure 会自动链接同名应用，构成应用闭包完成调用。

## 基本用法

`echo` 命令可以输出后面跟随的字符串。假设当前文件夹下存在一个名为 `.echo` 的配置文件：

```sh
$ ls -a
.echo

$ cat .echo
hello world

$ closure .echo
hello world        # 相当于执行了 echo hello world
```

带额外参数时，额外参数原样追加在拼装参数之后：

```sh
closure .echo --flag
```

## 配置目录

目录条目（如 `.echo/`）只以其中与目录同名的文件为配置（即 `.echo/.echo`），不拼接目录内其他文件；缺失时按空配置处理。

目录条目的运行方式——工具依次帮用户完成：

1. 在同目录创建去点同级目录（`.echo/` → `echo/`）；
2. 在 tmp 下创建一个 work 目录；
3. 执行 `alluvial_fuse --mount=.echo --upperdir=echo --workdir=<tmp 目录>` 挂载；
4. 进入 `.echo`，执行拼装好的命令（应用在挂载点内运行）；
5. 回到上级目录；
6. 解除 FUSE 挂载，清理 work 目录；同级目录若为空（应用无输出）则一并删除。

效果：输入读目录原内容（lower 层，永不被写入），输出经 upper 层落在同级 `echo/`。目录条目依赖 [`alluvial_fuse`](https://github.com/Changes729/alluvial_fuse) 与 `fusermount3`。

## 预演模式

按**调用名**识别：以 `-dryrun` 结尾的名字（建个硬链接/符号链接即可，如 `closure-dryrun`）只打印将执行的命令行（应用 + 拼装参数 + 额外参数），不运行；名字为 `closure` 则正常运行。

```sh
closure-dryrun .echo     # 输出：echo hello world
```

## 注意点

1. closure 不处理非 `.` 开头的文件和文件夹（显式条目必须以 `.` 开头）；
2. 如果找不到对应的应用，closure 不会做任何事情（静默，退出 0），因此闭包可跨环境复用；
3. 基本原理是把配置内容拼装为命令行参数后执行——按空白字面拆词，不展开引号、变量、通配符。

## 安装

curl 一行安装（默认装到 `~/.local/bin`，同时创建预演别名 `closure-dryrun`）：

```sh
curl -fsSL https://raw.githubusercontent.com/Changes729/closure/master/install.sh | sh
```

自定义安装位置：

```sh
PREFIX=/usr/local ./install.sh    # 装到 /usr/local/bin
```

或从仓库手动安装：

```sh
ln -sf "$PWD/closure" ~/.local/bin/closure
ln -f ~/.local/bin/closure ~/.local/bin/closure-dryrun   # 预演别名
```

## 测试

```sh
./test.sh              # 默认解释器
SH=/bin/sh ./test.sh   # 指定解释器
```

用例在 `test/` 下按编号拆分为独立文件，可单独执行，如：`sh test/05-dir-fuse.sh`；`test/lib.sh` 为公共库，各用例说明见 `test/README`。

更多设计与实现记录见 closure.md，原始需求见 doc/README。

## English

**closure** is a command-line helper tool derived from Plan Alluvial (sibling tool: [`alluvial_fuse`](https://github.com/Changes729/alluvial_fuse)).

When a directory contains a `.appname` config file or config directory, closure automatically links the same-named application, forming an application closure to complete the invocation.

### Basic Usage

The `echo` command prints the strings following it. Suppose the current directory contains a config file named `.echo`:

```sh
$ ls -a
.echo

$ cat .echo
hello world

$ closure .echo
hello world        # equivalent to: echo hello world
```

With extra arguments, they are appended verbatim after the assembled arguments:

```sh
closure .echo --flag
```

### Config Directories

For a directory entry (e.g. `.echo/`), only the file inside it that shares the directory's name is used as the config (i.e. `.echo/.echo`); no other files in the directory are appended. If it is missing, the entry is treated as an empty config.

How a directory entry runs — the tool performs these steps for you:

1. Create a dot-stripped sibling directory (`.echo/` → `echo/`);
2. Create a work directory under tmp;
3. Mount with `alluvial_fuse --mount=.echo --upperdir=echo --workdir=<tmp dir>`;
4. Enter `.echo` and execute the assembled command (the app runs inside the mount point);
5. Return to the parent directory;
6. Unmount the FUSE mount and clean up the work directory; if the sibling directory is empty (the app produced no output), it is removed as well.

Effect: input is the directory's original content (lower layer, never written to), and output lands in the sibling `echo/` via the upper layer. Directory entries depend on [`alluvial_fuse`](https://github.com/Changes729/alluvial_fuse) and `fusermount3`.

### Dry-Run Mode

Recognized by the **invocation name**: a name ending with `-dryrun` (just create a hard link or symbolic link, e.g. `closure-dryrun`) only prints the command line that would be executed (app + assembled args + extra args) without running it; the name `closure` runs normally.

```sh
closure-dryrun .echo     # outputs: echo hello world
```

### Notes

1. closure does not handle files or directories whose names do not start with `.` (explicit entries must start with `.`);
2. If the corresponding application cannot be found, closure does nothing (silent, exit 0), so closures can be reused across environments;
3. The basic principle is assembling the config content into command-line arguments and executing it — words are split on literal whitespace; quotes, variables, and globs are not expanded.

### Install

One-line install with curl (installs to `~/.local/bin` by default and creates the dry-run alias `closure-dryrun`):

```sh
curl -fsSL https://raw.githubusercontent.com/Changes729/closure/master/install.sh | sh
```

Custom install location:

```sh
PREFIX=/usr/local ./install.sh    # installs to /usr/local/bin
```

Or install manually from the repo:

```sh
ln -sf "$PWD/closure" ~/.local/bin/closure
ln -f ~/.local/bin/closure ~/.local/bin/closure-dryrun   # dry-run alias
```

### Testing

```sh
./test.sh              # default interpreter
SH=/bin/sh ./test.sh   # specify interpreter
```

Test cases live in `test/` as numbered standalone files and can be run individually, e.g. `sh test/05-dir-fuse.sh`; `test/lib.sh` is the shared library. See `test/README` for a description of each case.

See closure.md for more design and implementation notes, and doc/README for the original requirement.
