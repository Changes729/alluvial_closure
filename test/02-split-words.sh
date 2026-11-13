#!/bin/sh
# 02 —— 按空白拆词（多行/制表符/多余空白）
. "$(dirname "$0")/lib.sh"

printf '  a\t b\n\nc\n' > .echo
out=$("$SH" "$CLO" .echo)
ok "拆词" "a b c" "$out"

finish
