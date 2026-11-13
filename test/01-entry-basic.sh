#!/bin/sh
# 01 —— 规范示例：.echo 内容原样作为参数
. "$(dirname "$0")/lib.sh"

printf 'hello world\n' > .echo
out=$("$SH" "$CLO" .echo); st=$?
ok "echo-状态" 0 "$st"
ok "echo-输出" "hello world" "$out"

finish
