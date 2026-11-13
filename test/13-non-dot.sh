#!/bin/sh
# 13 —— 非 . 开头条目：报错退出 2
. "$(dirname "$0")/lib.sh"

"$SH" "$CLO" echo >/dev/null 2>&1; st=$?
ok "非点条目" 2 "$st"

finish
