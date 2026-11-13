#!/bin/sh
# 11 —— 空配置文件：正常调用应用本身
. "$(dirname "$0")/lib.sh"

: > .true
out=$("$SH" "$CLO" .true 2>&1); st=$?
ok "空配置-状态" 0 "$st"
ok "空配置-静默" "" "$out"

finish
