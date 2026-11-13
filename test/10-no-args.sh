#!/bin/sh
# 10 —— 无参数：打印用法并以状态 2 退出
. "$(dirname "$0")/lib.sh"

out=$("$SH" "$CLO" 2>&1); st=$?
ok "无参数-状态" 2 "$st"
case $out in
    usage:*) ok "无参数-用法" yes yes ;;
    *) ok "无参数-用法" yes "no:$out" ;;
esac

finish
