#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  install.sh - one-shot installer for the encp / decp tools
#
#  It copies the two scripts into your Termux $HOME, marks them
#  executable, and prepares the password file if it is missing.
#
#  Usage:  bash install.sh
# ============================================================
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME"

green(){ echo -e "\033[32m$*\033[0m"; }
yellow(){ echo -e "\033[33m$*\033[0m"; }
red(){ echo -e "\033[31m$*\033[0m"; }

for f in encp decp; do
  if [ ! -f "$HERE/$f" ]; then
    red "missing file: $HERE/$f"
    exit 1
  fi
done

command -v openssl >/dev/null 2>&1 || {
  yellow "openssl not found, installing..."
  pkg install -y openssl
}

cp "$HERE/encp" "$TARGET/encp"
cp "$HERE/decp" "$TARGET/decp"
chmod 700 "$TARGET/encp" "$TARGET/decp"
green "installed: $TARGET/encp"
green "installed: $TARGET/decp"

if [ ! -f "$TARGET/.aes_pass" ]; then
  echo "CHANGE_ME_STRONG_PASSWORD" > "$TARGET/.aes_pass"
  chmod 600 "$TARGET/.aes_pass"
  yellow "created placeholder password file: $TARGET/.aes_pass"
  yellow "IMPORTANT: edit it and set your own strong password:"
  yellow "  echo 'your-strong-password' > ~/.aes_pass && chmod 600 ~/.aes_pass"
else
  green "password file already exists: $TARGET/.aes_pass (kept)"
fi

echo
echo "Done. Usage:"
echo "  cd ~"
echo "  ./encp    # encrypt photos & videos from the last 10 minutes, then delete originals"
echo "  ./decp    # decrypt them into /sdcard/encryptpho/decrypho/"
echo
echo "Tip: set WINDOW_MIN to change the look-back window, e.g.  WINDOW_MIN=30 ./encp"
exit 0
