#!/bin/sh
# 04 —— 目录自带同名配置：只用 .echo/.echo，其余文件忽略；带尾部斜杠调用等价
. "$(dirname "$0")/lib.sh"

mkdir .echo
printf 'inner args' > .echo/.echo
printf 'noise' > .echo/a.txt
out=$("$SH" "$CLO" .echo)
ok "目录同名配置" "inner args" "$out"

out=$("$SH" "$CLO" .echo/)
ok "尾部斜杠" "inner args" "$out"

finish
