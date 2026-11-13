#!/bin/sh
# 06 —— 额外参数追加在拼装参数之后
. "$(dirname "$0")/lib.sh"

printf 'hello world' > .echo
out=$("$SH" "$CLO" .echo X Y)
ok "额外参数" "hello world X Y" "$out"

finish
