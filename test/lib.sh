# lib.sh —— 用例公共库（被 test/ 下各用例文件 source）
# 提供：SH/CLO 变量、ok() 断言、独立临时工作目录与清理、finish() 收尾
set -u

cd "$(dirname "$0")/.."            # 仓库根
SH=${SH:-sh}
CLO=$(pwd)/closure

pass=0
fail=0

# ok 名称 期望值 实际值
ok() {
    if [ "$2" = "$3" ]; then
        pass=$((pass + 1))
        printf 'ok   %s\n' "$1"
    else
        fail=$((fail + 1))
        printf 'FAIL %s\n  expected: [%s]\n  actual:   [%s]\n' "$1" "$2" "$3"
    fi
}

# 每个用例独立临时目录；硬链接预演名一并清理（不存在时 rm -f 无害）
work=$(mktemp -d) || exit 1
trap 'rm -rf "$work"; rm -f "$CLO-dryrun"' EXIT
cd "$work"

# 用例收尾：打印小结，失败则非 0 退出（供运行器聚合）
finish() {
    printf '%s: pass=%d fail=%d\n' "${0##*/}" "$pass" "$fail"
    [ "$fail" -eq 0 ]
}
