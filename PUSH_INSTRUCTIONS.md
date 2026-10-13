# 推送到 GitHub（最后一步：在你自己的终端执行）

沙箱里的 GitHub connector 是**只读 token**（写操作全部 403），且沙箱 git 没有你的
GitHub 凭据，所以 push 必须由你在本机 Mac 终端完成。你的钥匙串已存 GitHub 凭据
（`credential.helper = osxkeychain`），推送时不会再要账号密码。

## 已完成的处置（2026-10-13）

**远端旧库（含 Nazik 历史的 v1）已按 rename 路线封存**：改名 → 转 Private → Archive，
公开仓库列表中已不可见。**新库已创建**：`auchiu0627-cloud/upwork-master-2026`
（public、0 KB 空库、无初始提交，2026-10-13T15:38Z）。

已发布视频中的下载方式「去 GitHub 安装 auchiu0627-cloud/upwork-master-2026」
**无需任何改动**——同名新库占用该地址后自动指向清洗后的 v2 干净版。

> 注：本文件已被 .gitignore 忽略（本地指引，不进仓库）。

## 第一步：终端执行（关联新库 + 推送清洗后的历史）

```bash
cd /Users/autumn/WorkBuddy/2026-07-22-21-26-21/upwork-master-2026
git remote add origin https://github.com/auchiu0627-cloud/upwork-master-2026.git
git push -u origin main
```

本地历史已重写为 10 个干净提交（移除 Nazik 署名、密码前 5 位与长度/构成提示、
v1 加密载荷脱敏重加密），旧对象已强制清除。新库是空的，无需 force。

## 第二步：推送后自检（三条，期望值已标注）

```bash
cd /Users/autumn/WorkBuddy/2026-07-22-21-26-21/upwork-master-2026

# 1. 远端 payload 大小应为 39381
git fetch origin && git cat-file -s origin/main:payload.enc

# 2. 远端历史零残留（无输出 = 干净）
git rev-list origin/main --objects | awk '{print $1}' | sort -u | while read o; do
  t=$(git cat-file -t "$o" 2>/dev/null)
  [ "$t" = blob ] && git cat-file -p "$o" 2>/dev/null | grep -qE 'Nazik|lMRad|32 ?位|第 ?1 ?位' && echo "残留: $o"
done; echo "自检完成"

# 3. SKILL.md 应含 MCP 线（期望 ≥1）
git show origin/main:SKILL.md | grep -c "WORKFLOW M"
```

## 下载者验证（推完之后）

```bash
git clone https://github.com/auchiu0627-cloud/upwork-master-2026.git
cd upwork-master-2026
bash install.sh --dir ~/.workbuddy/skills --password '<群公告密码>'
```

期望：`payload.enc` 实际大小 39381 = 正确值、密码校验块 ✅、安装完成退出码 0。

## 遗留事项

- **旧库（Private + Archived）**：含 Nazik 历史的 v1 原样封存在内，仅你本人可见；
  归档为只读，将来想公开需先 unarchive + 改 visibility。本地另有完整备份
  `/tmp/payload_check/git_backup_pre_filter`（v1 全部 8 个文件 + 3 个提交）。
- 视频/文章发布内容无需改动：地址不变，观众下载到的是 v2 干净版；README 已把
  39381 写成自检基准，安装脚本会预检，老观众按原步骤操作无卡点。
