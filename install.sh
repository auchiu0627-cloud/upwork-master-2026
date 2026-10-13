#!/usr/bin/env bash
# Upwork Master 2026 — 一键安装脚本（解密 + 落位 + 自检）
# 用法：
#   bash install.sh [--src <技能源目录>] [--dir <目标 skills 目录>] [--password <密码>]
# 不传 --src 时自动用本脚本所在目录；不传 --dir 时自动探测用户级 skills 目录；
# 不传 --password 时从环境变量 UPWORK_PAYLOAD_PASSWORD 读取，仍无则报错退出。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR"
DIR=""
PASSWORD="${UPWORK_PAYLOAD_PASSWORD:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    --src) SRC="$2"; shift 2;;
    --dir) DIR="$2"; shift 2;;
    --password) PASSWORD="$2"; shift 2;;
    *) echo "[install] 未知参数: $1"; exit 1;;
  esac
done

# --- 规范化源目录：`--src .` 时 basename 会得到 "."，必须转成绝对路径再取目录名 ---
if [ ! -d "$SRC" ]; then
  echo "[install] ❌ 源目录不存在：$SRC"; exit 1
fi
SRC="$(cd "$SRC" && pwd)"
SKILL_NAME="$(basename "$SRC")"
if [ -z "$SKILL_NAME" ] || [ "$SKILL_NAME" = "." ] || [ "$SKILL_NAME" = "/" ]; then
  echo "[install] ❌ 无法从源目录解析技能名称：$SRC"; exit 1
fi
echo "[install] 技能源：$SRC (名称: $SKILL_NAME)"

# --- 探测 python3 ---
PYTHON="$(command -v python3 || command -v python)"
if [ -z "$PYTHON" ]; then
  echo "[install] ❌ 找不到 python3，请先安装 Python 3。"; exit 1
fi

# --- 自动探测目标 skills 目录 ---
if [ -z "$DIR" ]; then
  for cand in "$HOME/.workbuddy/skills" "$HOME/.claude/skills" "$HOME/.codebuddy/skills"; do
    if [ -d "$cand" ]; then DIR="$cand"; break; fi
  done
  if [ -z "$DIR" ]; then DIR="$HOME/.workbuddy/skills"; fi
fi
TARGET="$DIR/$SKILL_NAME"
echo "[install] 目标目录：$TARGET"

if [ -z "$PASSWORD" ]; then
  echo "[install] ❌ 未提供密码。请通过 --password 传入，或设置环境变量 UPWORK_PAYLOAD_PASSWORD。"
  echo "[install] 密码请在小红书关注「美金小蝴蝶」→ 加入「美元小时工」群 → 查看群公告获取。"
  exit 1
fi

# --- 临时目录先解密，成功才落位（避免半成品）---
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
# 只复制技能本体：排除 .git / .gitignore / .pwcheck 等无关文件
mkdir -p "$TMP/$SKILL_NAME"
for f in "$SRC"/*; do
  b="$(basename "$f")"
  case "$b" in
    .git|.gitignore|.pwcheck|*.bak-*) continue;;
  esac
  cp -R "$f" "$TMP/$SKILL_NAME/" 2>/dev/null
done

# ================= 预检：隔离「密码问题」与「文件问题」 =================
# 目的：让使用者（或其 Agent）能确定性判断失败原因，而不是笼统的"密码错误或文件损坏"。
# 判断依据：password_check.enc 是用同一密码加密的独立小校验块。
#   校验块解不开  -> 密码错（与 payload 文件无关）
#   校验块能解开  -> 密码对，若 payload 仍失败/大小不符 -> 文件损坏
EXPECTED_SIZE=39381
STAGE="$TMP/$SKILL_NAME"
ACTUAL_SIZE=$(wc -c < "$STAGE/payload.enc" 2>/dev/null | tr -d ' ')
echo "[check] payload.enc 实际大小：${ACTUAL_SIZE} 字节（正确应为 ${EXPECTED_SIZE}）"

PW_OK=0
if [ -f "$STAGE/password_check.enc" ]; then
  if "$PYTHON" "$STAGE/crypto_tool.py" decrypt --in "$STAGE/password_check.enc" --out "$STAGE/.pwcheck" --password "$PASSWORD" >/dev/null 2>&1; then
    PW_OK=1
  fi
  rm -f "$STAGE/.pwcheck"
fi

if [ "$PW_OK" -eq 0 ]; then
  echo "[check] 密码校验块：❌ 未能解开"
  echo "[check] ===== 结论：PASSWORD_WRONG（密码错误，与文件无关）====="
  echo "[check] 处理：重新到小红书「美金小蝴蝶」→「美元小时工」群公告完整复制密码。"
  echo "[check] 提醒：请整段复制，勿带首尾空格、勿手动换行；大小写必须与原密码一致。"
  exit 2
fi

echo "[check] 密码校验块：✅ 密码正确"
if [ "$ACTUAL_SIZE" != "$EXPECTED_SIZE" ]; then
  echo "[check] ===== 结论：FILE_CORRUPT（文件不完整/损坏，密码是对的）====="
  echo "[check] 处理：重新下载完整仓库 —— GitHub 页面 Code → Download ZIP。"
  echo "[check] 注意：不要用 Raw 页面「另存为」，也不要经网盘/聊天工具中转后再解压。"
  exit 3
fi
# ================= 预检结束 =================

echo "[install] 正在解密 payload.enc …"
if ! "$PYTHON" "$STAGE/crypto_tool.py" decrypt --in "$STAGE/payload.enc" --out "$STAGE/UPWORK_MASTER_GUIDE.md" --password "$PASSWORD" 2>/tmp/um_err.log; then
  echo "[install] ===== 结论：FILE_TAMPERED（密码正确、大小正常，但密文校验未通过）====="
  echo "[install] 处理：payload.enc 内容被替换或损坏，请重新下载仓库（Code → Download ZIP）。"
  [ -s /tmp/um_err.log ] && sed 's/^/    /' /tmp/um_err.log
  exit 4
fi

# --- 落位（同名先备份）---
if [ -d "$TARGET" ]; then
  BAK="$TARGET.bak-$(date +%Y%m%d%H%M%S)"
  echo "[install] 已存在同名技能，备份到 $BAK"
  mv "$TARGET" "$BAK"
fi
mkdir -p "$DIR"
cp -R "$STAGE" "$TARGET"

# --- 落位后生成 ATTRIBUTION.md（署名冗余，供 verify_attribution.py 比对）---
"$PYTHON" - "$TARGET" <<'PYEOF'
import sys, hashlib, os
target = sys.argv[1]
attrib = '''# 署名与权属声明（不可移除）

本文件由 install.sh 在安装时自动生成，与 SKILL.md、payload.enc 解密正文三处署名保持一致。

## 作者 / 算法来源

1. **Sarmad M.**（平面设计师 / 自由职业者）
2. **Vollna**（2026 算法分析）
3. **Upwork 官方帮助中心**（2026 版，用于校正上面 1–2 中过时的产品 / 政策描述）
4. **Upwork 官方 MCP 技能**（upwork-workflows / write-proposal v0.2.0）—— WORKFLOW M 章节来源；本技能只摘录 Freelancer 部分

## 整理者的话

我把 Sarmad M. 和 Vollna 的 skill 进行了整理优化，并接入了 Upwork 官方 MCP（仅 Freelancer 线），免费分享给想要做 Upwork 的同学们。

作为一个老营销人的感悟：营销不是为了让你变成写文案的专家，是让你把精力留在你最擅长的地方。

但由于担心被他人二次收费转包，所以对 Skill 进行了加密。请需要的同学下载之后，去找到某书的「美金小蝴蝶」账号，加入「美元小时工」群，在公告里找密码。

群里不会推任何广告。之前有同学想做 Upwork 被骗了钱，所以希望大家在做的过程中遇到任何困难，可以在群里问一问群里的老手，再决定是否需要付费去做。

祝大家都能用自己擅长的事情去赚更多。

> ⚠️ 本文件受整理者声明保护，不可移除或篡改。
'''
fp = hashlib.sha256(attrib.encode("utf-8")).hexdigest()
out = os.path.join(target, "ATTRIBUTION.md")
with open(out, "w", encoding="utf-8") as f:
    f.write(attrib)
    f.write("\n## 权属指纹\n\nSHA256(本文件署名文本) = `" + fp + "`\n")
print("[install] 已落位 ATTRIBUTION.md（署名冗余副本）")
PYEOF

# --- 自检 ---
echo ""
echo "========== 安装自检 =========="
OK=1
for f in SKILL.md payload.enc crypto_tool.py UPWORK_MASTER_GUIDE.md; do
  if [ -s "$TARGET/$f" ]; then echo "  ✅ $f ($(wc -c < "$TARGET/$f") 字节)"; else echo "  ❌ 缺少 $f"; OK=0; fi
done
FIRST="$(head -1 "$TARGET/SKILL.md")"
grep -q 'agent_created: true' "$TARGET/SKILL.md" && AC="✅" || AC="❌"
grep -q 'disable: true' "$TARGET/SKILL.md" && DIS="❌ 含 disable" || DIS="✅ 无 disable"
echo "  SKILL.md 首行: $FIRST"
echo "  agent_created: $AC | $DIS"
echo "  教程正文前 3 行："
sed -n '1,3p' "$TARGET/UPWORK_MASTER_GUIDE.md" | sed 's/^/    /'
echo "==============================="
if [ "$OK" -eq 1 ]; then echo "[install] ✅ 安装完成：$TARGET"; else echo "[install] ⚠️ 安装完成但有缺失，请检查。"; fi
