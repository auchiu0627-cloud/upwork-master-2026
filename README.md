# upwork-master-2026

Upwork 全流程实战助手 · **2026 算法增强版 + 官方 MCP 接入（通用模板）**。

覆盖三条工作线：(A) 档案优化 —— 标题 / Overview / 动态档案 / Project Catalog / 去 AI 味；(B) 岗位提案 —— 封面信 + 详细提案；(M) MCP 实战 —— 官方 Upwork MCP（仅 Freelancer：搜岗位 / 查提案状态 / 投递 / Connects / 回消息）。内置 2026 算法认知框架（JSS / 搜索排名 / 提案排序 / 邀请匹配 / 动态档案 / Uma AI 摘要）。

> 本仓库由「美金小蝴蝶」整理制作，**免费分享，仅供个人学习使用**，禁止二次收费转包。

---

## 作者 / 算法来源

1. **Sarmad M.**（平面设计师 / 自由职业者）
2. **Vollna**（2026 算法分析）
3. **Upwork 官方帮助中心**（2026 版，用于校正上面 1–2 中过时的产品 / 政策描述）
4. **Upwork 官方 MCP 技能**（`upwork-workflows` / `write-proposal` v0.2.0）—— WORKFLOW M 章节来源

## 整理者的话

我把 Sarmad M. 和 Vollna 的 skill 进行了整理优化，并接入了 Upwork 官方 MCP，免费分享给想要做 Upwork 的同学们。

作为一个老营销人的感悟：营销不是为了让你变成写文案的专家，是让你把精力留在你最擅长的地方。

但由于担心被他人二次收费转包，所以对 Skill 进行了加密。请需要的同学下载之后，去找到某书的「美金小蝴蝶」账号，加入「美元小时工」群，在公告里找密码。

群里不会推任何广告。之前有同学想做 Upwork 被骗了钱，所以希望大家在做的过程中遇到任何困难，可以在群里问一问群里的老手，再决定是否需要付费去做。

祝大家都能用自己擅长的事情去赚更多。

---

## 下载仓库

```bash
git clone https://github.com/auchiu0627-cloud/upwork-master-2026.git
cd upwork-master-2026
```

克隆到本地后，按下方「安装方式」操作即可。不会用 git 的同学，也可以直接点仓库页面的 **Code → Download ZIP** 下载压缩包解压。

---

## 获取解密密码（重要）

本仓库的 `payload.enc` 已用 **AES-256-GCM** 加密，**解密密码不在本仓库内**。

获取方式：在小红书关注账号 **「美金小蝴蝶」** → 加入 **「美元小时工」群** → 在群公告中找到本技能的密码。

> 设计意图：保留一个轻量门槛，防止有人拿去二次收费。群里不推广告，纯交流。

**密码不对或解密失败？** 别猜，看 [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)。安装脚本会先做预检并直接给出结论：`PASSWORD_WRONG`（密码错）／`FILE_CORRUPT`（文件不完整）／`FILE_TAMPERED`（内容被换过）。最快的一条自检是 `wc -c payload.enc`，正确必须为 **39381**。

---

## 安装方式

### 方式 A · 一键安装脚本（推荐）

```bash
# 在已克隆/解压的仓库目录下运行：
bash install.sh --dir ~/.workbuddy/skills --password '<群公告里的密码>'
```

- `--dir` 不传时会自动探测用户级 skills 目录（WorkBuddy / Claude Code / CodeBuddy 通用）
- 脚本会**先在临时目录解密成功才落位**，密码错误不留半成品
- 只复制技能本体，不会把 `.git` 等无关文件带进安装目录
- 同名技能自动备份

### 方式 B · 手动解密

```bash
pip install cryptography        # 如未安装
python crypto_tool.py decrypt --in payload.enc --out UPWORK_MASTER_GUIDE.md
# 按提示输入群公告密码
```

解密后得到 `UPWORK_MASTER_GUIDE.md`（完整教程正文，含 WORKFLOW A / B / M 三条工作流）。

---

## 本版新增：官方 MCP 接入（仅 Freelancer）

`WORKFLOW M` 一章接入 Upwork 官方 MCP，从"只能手写文案"升级到"能操作真实账号"：

| 能力 | 工具 |
|---|---|
| 搜岗位 | `find_jobs`（`search` / `smart_search` / `get`，job URL 可原样传入） |
| 查状态 | `list_freelancer_proposals`（提案 / 邀请 / 房间） |
| 投递 | `manage_proposals`（预览 → 二次确认 → 提交） |
| 看家底 | `get_profile`（档案 / 作品集与证书 / Connects 余额） |
| 回消息 | `get_messages` + `send_message` |
| 附件 | `start_attachment_upload` / `get_upload_status` / `confirm_attachment_upload` |

配套收录了 **7 个官方文档没写、实测才会遇到的坑**（参数嵌套结构、响应三层嵌套、session id 只在响应头、UA 被网关 403 等），以及 MCP 配置与 OAuth 2.1 + PKCE 授权的完整接法。

**范围边界**：官方 MCP 技能同时覆盖 Client / Freelancer / Agency 三条线，本技能**只摘录 Freelancer 线**。客户侧（发岗位、审提案、发 offer、改合约）与 Agency 侧（团队、机构档案）未纳入 —— 需要的人请去 Upwork 官方仓库取原版。

---

## 文件说明

| 文件 | 作用 |
|---|---|
| `SKILL.md` | 技能明文包装层（署名声明 + 安装说明），下载即见 |
| `payload.enc` | 加密后的完整教程正文（AES-256-GCM，39381 字节） |
| `crypto_tool.py` | 加解密工具（encrypt / decrypt） |
| `install.sh` | 一键安装脚本（自动探测目录、临时解密落位、失败自检） |
| `password_check.enc` | 密码校验块，用于区分「密码错」与「文件坏」 |
| `verify_attribution.py` | 署名完整性自检 |
| `ATTRIBUTION.md` / `PROOF.md` / `ATTRIBUTION.md.ots` | 权属证据（含比特币时间戳） |

---

## 安全与许可

- 教程正文已加密，未授权无法读取。
- MCP 的 access token 等凭证**绝不写入本仓库**（详见 WORKFLOW M7）。
- **禁止**将解密后的明文二次收费转包。
- 免费分享，欢迎学习使用。
