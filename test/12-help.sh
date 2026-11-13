#!/bin/sh
# 12 —— help
. "$(dirname "$0")/lib.sh"

out=$("$SH" "$CLO" -h 2>&1); st=$?
ok "help-状态" 0 "$st"
case $out in
    usage:*) ok "help-用法" yes yes ;;
    *) ok "help-用法" yes "no:$out" ;;
esac

finish
