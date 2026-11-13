#!/bin/sh
# 03 —— 目录条目：只用同名配置 .echo/.echo；缺失时应用以空参数运行（不拼接其他文件）
. "$(dirname "$0")/lib.sh"

mkdir .echo
printf 'hello' > .echo/a.txt
printf 'world' > .echo/b.txt
mkdir .echo/sub
printf 'noise' > .echo/sub/c.txt
out=$("$SH" "$CLO" .echo)
ok "目录条目-无同名配置" "" "$out"

finish
