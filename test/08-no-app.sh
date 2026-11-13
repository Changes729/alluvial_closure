#!/bin/sh
# 08 —— 找不到对应应用：什么都不做（静默，退出 0）
. "$(dirname "$0")/lib.sh"

: > .definitely_not_an_app_xyz
out=$("$SH" "$CLO" .definitely_not_an_app_xyz 2>&1); st=$?
ok "无应用-状态" 0 "$st"
ok "无应用-静默" "" "$out"

finish
