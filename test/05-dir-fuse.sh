#!/bin/sh
# 05 —— 目录条目 FUSE overlay 运行：应用在挂载点内运行；
#       输入读 lower（目录原内容），写入经 upper 落在同级去点目录；
#       结束自动卸载；同级目录为空（应用无输出）则一并删除
. "$(dirname "$0")/lib.sh"

# 输入：应用在挂载点内读到 lower 原内容
mkdir .cat
printf 'DIRDATA' > .cat/in.txt
printf 'in.txt' > .cat/.cat
out=$("$SH" "$CLO" .cat 2>&1)
ok "挂载内读 lower 输入" "DIRDATA" "$out"

# 卸载干净
if command -v mountpoint >/dev/null 2>&1; then
    if mountpoint -q .cat 2>/dev/null; then r=still; else r=unmounted; fi
else
    r=unmounted
fi
ok "运行后自动卸载" "unmounted" "$r"

# 应用无输出：自动创建的同级去点目录若为空则被清理
ok "无输出不留空同级目录" "gone" "$([ -e cat ] && echo there || echo gone)"

# 输出：写入经 upper 落在同级去点目录（.cp/ → cp/），lower（原目录）不动
mkdir .cp
printf 'DIRDATA' > .cp/in.txt
printf 'in.txt out.txt' > .cp/.cp
"$SH" "$CLO" .cp >/dev/null 2>&1
ok "输出落在同级 upper" "ran" "$([ -f cp/out.txt ] && echo ran || echo missing)"
ok "目录内无输出" "no" "$([ -e .cp/out.txt ] && echo yes || echo no)"
ok "复制内容正确" "DIRDATA" "$(cat cp/out.txt)"
ok "有输出保留同级目录" "kept" "$([ -d cp ] && echo kept || echo gone)"

finish
