#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Upwork Master 2026 — 加密载荷工具 (AES-256-GCM)
用法：
  python crypto_tool.py encrypt --in guide.md --out payload.enc --password <pass>
  python crypto_tool.py decrypt --in payload.enc --out guide.md --password <pass>
  （不传 --password 时会交互式隐藏输入；仍可用环境变量 UPWORK_PAYLOAD_PASSWORD）

文件格式： salt(16B) | nonce(12B) | ciphertext
算法：PBKDF2-HMAC-SHA256, 1,000,000 次迭代, 派生 32 字节密钥
"""
import os
import sys
import argparse
import base64

# ---- 依赖自检：缺 cryptography 时自动安装 ----
try:
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    from cryptography.hazmat.primitives import hashes
except ImportError:
    import subprocess
    print("[crypto_tool] 缺少 cryptography 库，正在自动安装…")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--quiet", "cryptography"])
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    from cryptography.hazmat.primitives import hashes

SALT_LEN = 16
NONCE_LEN = 12
PBKDF2_ITERS = 1_000_000


def _derive_key(password: str, salt: bytes) -> bytes:
    kdf = PBKDF2HMAC(hashes.SHA256(), length=32, salt=salt, iterations=PBKDF2_ITERS)
    return kdf.derive(password.encode("utf-8"))


def encrypt(in_path: str, out_path: str, password: str) -> None:
    with open(in_path, "rb") as f:
        data = f.read()
    salt = os.urandom(SALT_LEN)
    nonce = os.urandom(NONCE_LEN)
    key = _derive_key(password, salt)
    aes = AESGCM(key)
    ct = aes.encrypt(nonce, data, None)
    with open(out_path, "wb") as f:
        f.write(salt + nonce + ct)
    print(f"[crypto_tool] 加密完成：{out_path}（{len(data)} → {len(salt)+len(nonce)+len(ct)} 字节）")


def decrypt(in_path: str, out_path: str, password: str) -> None:
    with open(in_path, "rb") as f:
        blob = f.read()
    if len(blob) < SALT_LEN + NONCE_LEN + 1:
        raise ValueError("文件过短，不是合法的 payload.enc")
    salt = blob[:SALT_LEN]
    nonce = blob[SALT_LEN:SALT_LEN + NONCE_LEN]
    ct = blob[SALT_LEN + NONCE_LEN:]
    key = _derive_key(password, salt)
    aes = AESGCM(key)
    try:
        data = aes.decrypt(nonce, ct, None)
    except Exception:
        raise ValueError("解密失败：密码错误或文件损坏")
    with open(out_path, "wb") as f:
        f.write(data)
    print(f"[crypto_tool] 解密完成：{out_path}（{len(data)} 字节）")


def _get_password(args) -> str:
    if args.password:
        return args.password
    env = os.environ.get("UPWORK_PAYLOAD_PASSWORD")
    if env:
        return env
    import getpass
    return getpass.getpass("请输入解密密码：")


def main():
    ap = argparse.ArgumentParser(description="Upwork Master 2026 加密工具")
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name in ("encrypt", "decrypt"):
        p = sub.add_parser(name)
        p.add_argument("--in", dest="in_path", required=True)
        p.add_argument("--out", dest="out_path", required=True)
        p.add_argument("--password", default="")
    args = ap.parse_args()
    if args.cmd == "encrypt":
        encrypt(args.in_path, args.out_path, args.password)
    else:
        decrypt(args.in_path, args.out_path, _get_password(args))


if __name__ == "__main__":
    main()
