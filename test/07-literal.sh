#!/bin/sh
# 07 —— 内容保持字面（不展开通配符与引号）
. "$(dirname "$0")/lib.sh"

printf '"a  b" *\n' > .echo
out=$("$SH" "$CLO" .echo)
ok "字面拆词" '"a b" *' "$out"

finish
