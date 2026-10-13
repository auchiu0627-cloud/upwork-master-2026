# 权属证据（第三方不可篡改记录）

本文件证明 upwork-master-2026 技能的署名归属。

- **第一层（本地冗余）**：SKILL.md 明文层 + payload.enc 解密正文 + install 落位的 ATTRIBUTION.md + 正文章节隐形水印。
- **第二层（本地自检）**：`verify_attribution.py` 比对四处署名关键词，被改即报错退出非零。
- **第三层（本文件，唯一真正不可篡改）**：证据存于第三方，任何人拿到文件都无法删除这一层。

---

## 署名文本（权威版，不可移除）

1. **Sarmad M.**（平面设计师 / 自由职业者）
2. **Vollna**（2026 算法分析）
3. **Upwork 官方帮助中心**（2026 版，用于校正上面 1–2 中过时的产品 / 政策描述）
4. **Upwork 官方 MCP 技能**（upwork-workflows / write-proposal v0.2.0）—— WORKFLOW M 章节来源；本技能只摘录 Freelancer 部分

整理者：美金小蝴蝶。整理者的话：我把 Sarmad M. 和 Vollna 的 skill 进行了整理优化，并接入 Upwork 官方 MCP（仅 Freelancer 线），免费分享给想要做 Upwork 的同学们；由于担心被他人二次收费转包，所以对 Skill 进行了加密，请到小红书「美金小蝴蝶」的「美元小时工」群公告取密码。

---

## 第三方权属记录

### 1. GitHub 公开仓（commit 不可改）
https://github.com/auchiu0627-cloud/upwork-master-2026

本技能的 SKILL.md / payload.enc / ATTRIBUTION.md / verify_attribution.py / install.sh / README.md 均已提交，公开可查、带有明确时间戳。任何人都可查看历史 commit 证明原始署名归属。

### 2. 比特币时间戳（OpenTimestamps）— 已重打

`ATTRIBUTION.md` 的署名内容已两次提交比特币时间戳日历，最新一枚随本技能一同分发（`ATTRIBUTION.md.ots`）：

| 项目 | 值 |
|---|---|
| 时间戳文件 | `ATTRIBUTION.md.ots` |
| 首次提交 | 2026-09-04（v1 署名版，已因内容更新而失效，不再分发） |
| 最新提交 | 2026-10-13（v2 署名版，含 Upwork 官方 MCP 技能来源） |
| 被证明文件 | `ATTRIBUTION.md`（整文件 SHA256 = `ac466a770e67837331bdcea1f4f9e967e63e2b503cf3d51350aae6d976f2c321`） |
| 署名主体 SHA256 | `0f330a2af3ffb060686b0526f6a4f5fc487203e34dec16caa42e4816e402a3a3` |
| 日历服务器 | a.pool.opentimestamps.org / b.pool.opentimestamps.org / a.pool.eternitywall.com / ots.btc.catallaxy.com |
| 当前状态 | 已提交承诺，等待写入比特币区块（Pending → 通常数小时至数天后 Confirm） |

任何人拿到 `.ots` 都可独立验证，不依赖本技能、不依赖任何平台：

```bash
ots verify ATTRIBUTION.md.ots      # 需 ATTRIBUTION.md 在同目录
ots info  ATTRIBUTION.md.ots       # 查看详细证明链
```

上链完成后可升级为完整比特币区块证明：

```bash
ots upgrade ATTRIBUTION.md.ots
```

> 说明：「Pending」已具备证明力——日历服务器已对文件哈希签名并承诺写入比特币区块链，只是区块尚未确认。
> ⚠️ 时间戳与**文件内容**绑定：ATTRIBUTION.md 每次改动都必须重打 `.ots`，否则旧证明指向的哈希已不存在。

---

## 纠纷时如何举证

对方若删除本地署名，可用：
1. GitHub 公开仓的 commit 历史（证明原始版本带此署名）；
2. `ATTRIBUTION.md.ots` 时间戳（证明署名在某时间点已存在）。

署名不可拆分关键词：**Sarmad M.** / **Vollna** / **Upwork 官方帮助中心** / **Upwork 官方 MCP 技能** / **美金小蝴蝶**。

---

## 当前指纹（v2 署名版）

| 项 | SHA256 |
|---|---|
| `ATTRIBUTION.md` 整文件（时间戳证明的即此值） | `ac466a770e67837331bdcea1f4f9e967e63e2b503cf3d51350aae6d976f2c321` |
| `ATTRIBUTION.md` 署名主体（不含指纹段，install.sh 落位值） | `0f330a2af3ffb060686b0526f6a4f5fc487203e34dec16caa42e4816e402a3a3` |

本地复算方式：

```bash
python - <<'PY'
import hashlib
raw = open("ATTRIBUTION.md", "rb").read()
print("整文件  :", hashlib.sha256(raw).hexdigest())
s = raw.decode("utf-8").split("## 权属指纹")[0].rstrip() + "\n"
print("署名主体:", hashlib.sha256(s.encode("utf-8")).hexdigest())
PY
```

> 两个值用途不同：**整文件哈希**用于核对 `.ots` 时间戳；**署名主体哈希**用于核对 install.sh 落位的 ATTRIBUTION.md 与源一致。
