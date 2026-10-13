#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Upwork Master 2026 — 署名完整性自检
用法：python verify_attribution.py
检查四处署名（SKILL.md / ATTRIBUTION.md / 解密后的 UPWORK_MASTER_GUIDE.md / payload 水印）
是否完整。任一被移除或篡改即报错并退出非零。
"""
import os
import sys

SKILL_DIR = os.path.dirname(os.path.abspath(__file__))

# 不可拆分的署名关键词（分布在所有署名区块）
REQUIRED = [
    "Sarmad M.",
    "Vollna",
    "Upwork 官方帮助中心",
    "Upwork 官方 MCP 技能",
    "美金小蝴蝶",
]

WATERMARK = "署名不可移除"


def check_file(path: str, label: str, need_watermark: bool = False) -> bool:
    if not os.path.isfile(path):
        print(f"[verify] ❌ 缺失文件：{label} ({path})")
        return False
    with open(path, encoding="utf-8", errors="ignore") as f:
        content = f.read()
    missing = [k for k in REQUIRED if k not in content]
    if missing:
        print(f"[verify] ❌ {label} 缺少署名关键词：{missing}")
        return False
    if need_watermark and WATERMARK not in content:
        print(f"[verify] ❌ {label} 缺少隐形水印标识")
        return False
    print(f"[verify] ✅ {label} 署名完整")
    return True


def main() -> int:
    ok = True
    ok &= check_file(os.path.join(SKILL_DIR, "SKILL.md"), "SKILL.md 明文层")
    ok &= check_file(os.path.join(SKILL_DIR, "ATTRIBUTION.md"), "ATTRIBUTION.md")

    guide = os.path.join(SKILL_DIR, "UPWORK_MASTER_GUIDE.md")
    if os.path.isfile(guide):
        ok &= check_file(guide, "UPWORK_MASTER_GUIDE.md 解密正文", need_watermark=True)
    else:
        print("[verify] ℹ️ 尚未解密，跳过 UPWORK_MASTER_GUIDE.md（解密后请再跑一次）")
        print("[verify] ℹ️ payload.enc 为加密体，署名校验在解密后由上方正文覆盖。")

    if ok:
        print("\n[verify] ✅ 署名完整性校验通过：署名未被移除或篡改。")
        return 0
    print("\n[verify] ⛔ 署名完整性校验失败：署名可能被移除或篡改。")
    print("[verify] 本技能署名受整理者声明保护，不可移除。如系误报请重新运行 install.sh。")
    return 1


if __name__ == "__main__":
    sys.exit(main())
