#!/bin/sh
# 14 —— 预演模式（按调用名识别，硬链接测试）：*-dryrun 只打印不运行；原名字照常运行
. "$(dirname "$0")/lib.sh"

printf 'hello world' > .echo
ln -f "$CLO" "$CLO-dryrun"              # 硬链接：与 $CLO 同目录，同文件系统
out=$("$SH" "$CLO-dryrun" .echo X Y); st=$?
ok "dryrun-状态" 0 "$st"
ok "dryrun-输出" "echo hello world X Y" "$out"

rm -rf .touch marker
mkdir .touch && : > .touch/.touch
"$SH" "$CLO-dryrun" .touch marker >/dev/null
ok "dryrun-未运行" "missing" "$([ -e marker ] && echo ran || echo missing)"

rm -rf .cp
mkdir .cp
printf 'DIRDATA' > .cp/in.txt
printf 'in.txt out.txt' > .cp/.cp
out=$("$SH" "$CLO-dryrun" .cp)
ok "dryrun-目录条目" "cp in.txt out.txt" "$out"

: > .definitely_not_an_app_xyz
out=$("$SH" "$CLO-dryrun" .definitely_not_an_app_xyz 2>&1); st=$?
ok "dryrun-无应用静默" "" "$out"
ok "dryrun-无应用状态" 0 "$st"

rm -f "$CLO-dryrun"                      # 测试结束删除硬链接（trap 兜底）
out=$("$SH" "$CLO" .echo); st=$?
ok "原名照常运行" "hello world" "$out"

finish
