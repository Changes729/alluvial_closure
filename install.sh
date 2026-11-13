#!/bin/sh
# install.sh —— 安装 closure 与预演别名 closure-dryrun
#
# 本地安装：  ./install.sh
# curl 安装： curl -fsSL <仓库 raw 地址>/install.sh | sh
#
# 默认安装到 ~/.local/bin，可用环境变量覆盖：
#   PREFIX=/usr/local ./install.sh     # 装到 /usr/local/bin
#   REPO=<raw 地址> ./install.sh       # 覆盖远程下载源
set -u

# curl 远程安装时，closure 本体的下载源
REPO=${REPO:-https://raw.githubusercontent.com/Changes729/closure/master}

PREFIX=${PREFIX:-"$HOME/.local"}
DEST="$PREFIX/bin"
TMP=""

say() { printf '%s\n' "$*"; }
die() { printf 'install.sh: %s\n' "$*" >&2; exit 1; }

cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

# ---- 取得 closure 本体：本地有就用本地，否则从 REPO 下载 ----------------
fetch() {
    TMP=$(mktemp -d) || die "无法创建临时目录"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REPO/closure" -o "$TMP/closure" || die "curl 下载失败：$REPO/closure"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TMP/closure" "$REPO/closure" || die "wget 下载失败：$REPO/closure"
    else
        die "远程安装需要 curl 或 wget"
    fi
    echo "$TMP/closure"
}

src=""
here=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd -P) || here=""
if [ -n "$here" ] && [ -f "$here/closure" ]; then
    src="$here/closure"
    say "来源：本地 $src"
else
    src=$(fetch)
    say "来源：远程 $REPO/closure"
fi

# ---- 安装 ----------------------------------------------------------------
mkdir -p "$DEST" || die "无法创建安装目录：$DEST"
cp "$src" "$DEST/closure" || die "写入失败：$DEST/closure"
chmod +x "$DEST/closure" || die "chmod 失败"
ln -f "$DEST/closure" "$DEST/closure-dryrun" 2>/dev/null ||
    ln -sf closure "$DEST/closure-dryrun"

# ---- 自检与提示 ----------------------------------------------------------
if "$DEST/closure" -h >/dev/null 2>&1; then
    say "安装完成：$DEST/closure"
    say "预演别名：$DEST/closure-dryrun"
else
    die "安装后自检失败，请检查 $DEST/closure"
fi

case ":$PATH:" in
    *":$DEST:"*) ;;
    *) say "提示：$DEST 不在 PATH 中，请将其加入 PATH" ;;
esac
