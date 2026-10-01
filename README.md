# termux-cam-crypt

Lightweight **Termux** tools to encrypt the photos & videos you just shot,
wipe the originals, and immediately refresh the Android gallery so no stale
thumbnail is left behind.

Two commands are provided:

| Command | What it does |
|---------|--------------|
| `encp`  | Finds camera photos **and** videos modified in the last **10 minutes**, encrypts them into `/sdcard/encryptpho/`, verifies the result, then **deletes the originals** (no recycle bin). Finally it purges the media-store cache and refreshes the gallery. |
| `decp`  | Decrypts the `.enc` files created in the last 10 minutes into `/sdcard/encryptpho/decrypho/`, overwriting any existing file. |

---

## Why

When you shoot a photo, Android writes it into `/sdcard/DCIM/Camera` and the
MediaStore immediately caches a thumbnail. If you encrypt + delete the file
quickly, that cached thumbnail can still be visible in the gallery for a while.
`encp` therefore **purges the MediaStore records and rescans the volume**
right after deleting the originals.

---

## Requirements

* Termux (from F-Droid or GitHub, **not** the Play Store build).
* `openssl` inside Termux:
  ```sh
  pkg install openssl
  ```
* To refresh the gallery automatically you need **one** of:
  1. **Root** (a working `su`)  — most reliable, fully purges the MediaStore.
  2. **Shizuku** with `rish` installed.
  3. **Termux:API** add-on (`termux-media-scan`).

Without any of those, `encp` still encrypts and deletes correctly, but it can
only send a legacy media-scanner broadcast which recent Android versions may
ignore.

---

## Install

1. Copy this folder onto the phone (or clone the repo inside Termux).
2. From inside the folder, run:
   ```sh
   bash install.sh
   ```
3. Set your own strong password (used for both encrypt and decrypt):
   ```sh
   echo 'your-strong-password' > ~/.aes_pass && chmod 600 ~/.aes_pass
   ```

`install.sh` copies `encp` and `decp` to your Termux `$HOME` and makes them
executable.

---

## Usage

```sh
cd ~
./encp     # encrypt the last 10 minutes of photos & videos, then delete them
./decp     # decrypt them back into /sdcard/encryptpho/decrypho/
```

Change the look-back window with the `WINDOW_MIN` environment variable:

```sh
WINDOW_MIN=30 ./encp
WINDOW_MIN=5  ./decp
```

---

## Paths

| Purpose | Path |
|---------|------|
| Source (camera) | `/sdcard/DCIM/Camera` |
| Encrypted output | `/sdcard/encryptpho/` |
| Decrypted output | `/sdcard/encryptpho/decrypho/` |
| Password file | `~/.aes_pass` (first line only) |

---

## Encryption scheme

* AES-256-CBC with PBKDF2 key derivation (100,000 iterations, random salt),
  via the system `openssl`:
  ```
  openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt
  ```
* Encrypted files keep their original name plus a `.enc` suffix.
* `encp` decrypts each fresh ciphertext in memory and compares the SHA-256 of
the round-tripped bytes with the original file *before* deleting it.

---

## Supported extensions

* **Images:** `jpg jpeg png heic heif webp dng gif bmp`
* **Videos:** `mp4 mov mkv avi 3gp m4v webm ts flv wmv`

---

## Safety

* Deletion is **permanent** (`shred -u`, falling back to `rm -f`). Nothing goes
  to the recycle bin.
* **If you lose `~/.aes_pass`, your encrypted files cannot be recovered.**
* Changing the password makes previously encrypted files undecryptable.

---

## License

MIT
