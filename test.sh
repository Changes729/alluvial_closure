#!/bin/sh
# test.sh —— 测试运行器：依次执行 test/ 下各用例文件（lib.sh 除外）
# 用法：./test.sh     或     SH=/bin/sh ./test.sh   （指定解释器）
# 单个用例可独立运行，如：sh test/05-dir-fuse.sh
set -u
cd "$(dirname "$0")"
SH=${SH:-sh}
CLO=$(pwd)/closure
export SH

# 仓库根演示条目：测试期间创建，结束后删除（trap 兜底）
# .cat 是链式演示条目：closure .cat → 以 .echo 为参数调用 cat → 读出 hello world
printf 'hello world\n' > .echo
printf '.echo\n' > .cat
trap 'rm -f .echo .cat' EXIT INT TERM

n=0
failed=0

# 仓库根条目冒烟：文件条目、链式参数
out=$("$SH" "$CLO" .cat 2>/dev/null); rc=$?
if [ "$rc" -eq 0 ] && [ "$out" = "hello world" ]; then
    printf 'ok   根演示条目（closure .cat → cat .echo → hello world）\n'
else
    printf 'FAIL 根演示条目：rc=%s out=[%s]\n' "$rc" "$out"
    failed=$((failed + 1))
fi

for t in test/[0-9]*.sh; do
    [ -f "$t" ] || continue
    n=$((n + 1))
    printf '\n== %s\n' "$t"
    "$SH" "$t" || failed=$((failed + 1))
done

printf '\nrunner: %d 个用例文件，失败 %d 个\n' "$n" "$failed"
[ "$failed" -eq 0 ]
