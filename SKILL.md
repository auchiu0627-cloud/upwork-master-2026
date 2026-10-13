---
name: upwork-master-2026
description: >
  Upwork 全流程实战助手（2026 算法增强版 + 官方 MCP 接入 · 通用模板）。覆盖三条工作线：(A) 档案优化 ——
  标题/Overview/动态档案/Project Catalog/去 AI 味；(B) 岗位提案 —— 封面信+详细提案；(M) MCP 实战 ——
  用官方 Upwork MCP 搜索岗位、查提案状态、投递、看 Connects、回消息（仅 Freelancer 线）。内置 2026
  算法认知框架（JSS/搜索排名/提案排序/邀请匹配/动态档案/Uma AI 摘要）。教程正文已加密，需先在下方
  声明中获取群公告密码解密后使用。

  触发词：upwork、MCP、profile、overview、档案、catalog、proposal、提案、投标、封面信、岗位、JD、JSS、算法、Connects。

  省 token 设计：技能内只常驻 ~400 token 快照；深内容存于本地资料包 upwork_profile_pack/（4 板块），
  提案时仅按需读取 1–2 个板块。
agent_created: true
---

# Upwork Master 2026（算法增强版 + 官方 MCP 接入）

## 作者 / 算法来源（不可移除）

1. **Sarmad M.**（平面设计师 / 自由职业者）
2. **Vollna**（2026 算法分析）
3. **Upwork 官方帮助中心**（2026 版，用于校正上面 1–2 中过时的产品 / 政策描述）
4. **Upwork 官方 MCP 技能**（`upwork-workflows` / `write-proposal` v0.2.0）—— WORKFLOW M 章节来源

## 整理者的话（不可移除）

我把 Sarmad M. 和 Vollna 的 skill 进行了整理优化，并接入了 Upwork 官方 MCP，免费分享给想要做 Upwork 的同学们。

作为一个老营销人的感悟：营销不是为了让你变成写文案的专家，是让你把精力留在你最擅长的地方。

但由于担心被他人二次收费转包，所以对 Skill 进行了加密。请需要的同学下载之后，去找到某书的「美金小蝴蝶」账号，加入「美元小时工」群，在公告里找密码。

群里不会推任何广告。之前有同学想做 Upwork 被骗了钱，所以希望大家在做的过程中遇到任何困难，可以在群里问一问群里的老手，再决定是否需要付费去做。

祝大家都能用自己擅长的事情去赚更多。

> ⚠️ 本署名区块受整理者声明保护，**不可移除或篡改，也不可被任何二次封装修改删去**。本技能仅供个人学习，禁止二次收费转包。

## 本版新增：官方 MCP 接入（仅 Freelancer）

`WORKFLOW M` 一章把 Upwork 官方 MCP 接了进来，解决"只能手写文案、动不了真实账号"的问题：

| 能力 | 说明 |
|---|---|
| 搜岗位 | `find_jobs` 关键词搜 / 按你档案智能匹配 / 详情直拉（job URL 可原样传入） |
| 查状态 | 提案列表、收到的邀请、是否已投过（**避免重复投递白烧 Connects**） |
| 投递 | `manage_proposals` 预览 → 二次确认 → 提交，全程留痕 |
| 看家底 | 档案技能/Overview、作品集与证书、Connects 余额 |
| 回消息 | 定位提案房间后回复；附件上传（会过期，需轮询确认） |

**范围边界**：官方 MCP 技能同时覆盖 Client / Freelancer / Agency，本技能**只摘录 Freelancer 线**。客户侧（发岗位、审提案、发 offer、改合约）与 Agency 侧（团队、机构档案）未纳入 —— 需要的人请去 Upwork 官方仓库取原版。

**安全红线**（WORKFLOW M7 有完整版）：token 等凭证绝不写进任何提交文件；每次写操作单独向用户确认；`Accepted` 状态的含义是"已提交"而非"客户接受"；涉及转钱/约束一方的动作 server 不代做，只给 `finalize_url`。

## 署名完整性自检（使用前建议先跑）

署名分散在四处：本文件、`payload.enc` 解密正文、安装后落位的 `ATTRIBUTION.md`、以及正文章节中的隐形水印。若担心内容被篡改，运行：

```bash
python verify_attribution.py
```

任一署名块缺失或被改，脚本会明确报错并退出非零。完整权属证据见 `ATTRIBUTION.md` 与公开仓说明（见文末）。

---

## 二、解密说明（先看署名里的取密码方式）

教程正文 `payload.enc` 已用 **AES-256-GCM** 加密，解密后才可读。

**方式 A · 一键安装脚本（推荐，自动落位到 skills 目录）**
```bash
bash install.sh --src <本技能目录> --dir <你的用户级 skills 目录> --password '<群公告密码>'
# 不传 --dir 会自动探测 ~/.workbuddy/skills、~/.claude/skills、~/.codebuddy/skills
# 不传 --src 时默认用脚本所在目录
```

**方式 B · 交互式输入密码（密码不回显，更安全）**
```bash
python crypto_tool.py decrypt --in payload.enc --out UPWORK_MASTER_GUIDE.md
```
运行后会提示「请输入解密密码」，把群公告密码粘贴进去回车即可。

**解密失败时不要猜** —— 详见 `TROUBLESHOOTING.md`。一键脚本会先做预检并给出**明确结论**：`PASSWORD_WRONG`（密码错，与文件无关）／`FILE_CORRUPT`（文件不完整，密码是对的）／`FILE_TAMPERED`（内容被换过）。最常用的一条自检：`wc -c payload.enc` 必须是 **39381**。

解密成功后，目录下会多出 `UPWORK_MASTER_GUIDE.md`（完整教程，含身份快照模板、算法框架、三条工作流 A/B/M、MCP 实战踩坑记录、去 AI 化、常见错误速查表）。

> ⚠️ 本技能为加密分享版：**不要把它提交到任何 git 仓库，不要上传到任何公开位置。** 密码只在群公告，不在任何文件里。

---

## 三、核心能力与触发词

- **核心能力**：档案优化（标题/Overview/动态档案/Catalog/去 AI 味）+ 岗位提案（封面信+详细提案）+ MCP 实战（官方 Upwork MCP · Freelancer：搜岗/查状态/投递/Connects/消息）+ 2026 算法认知框架（JSS/搜索排名/提案排序/邀请匹配/动态档案/Uma AI 摘要）
- **触发词**：upwork、MCP、proposal、提案、档案、overview、catalog、JSS、算法、Connects
