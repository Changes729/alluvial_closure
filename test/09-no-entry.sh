#!/bin/sh
# 09 —— 条目不存在：报错退出 2
. "$(dirname "$0")/lib.sh"

out=$("$SH" "$CLO" .no_such 2>&1); st=$?
ok "无条目-状态" 2 "$st"
ok "无条目-报错" "closure: 条目不存在：.no_such" "$out"

finish
