#!/bin/sh
# Costruisce l'immagine ISO di Nido.
# Va eseguito su Debian 13 (trixie) amd64 con il pacchetto live-build installato:
#   sudo apt install live-build
set -e

# live-build richiede i permessi di root
if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

cd "$(dirname "$0")"
chmod +x auto/* config/hooks/live/*.hook.chroot \
  config/includes.chroot/usr/local/bin/nido-session \
  config/includes.chroot/usr/lib/nido/nido-shell.py

lb clean --purge
lb config
lb build

ISO=$(ls -1 *.iso 2>/dev/null | head -n 1)
if [ -n "$ISO" ]; then
  mv "$ISO" nido-amd64.iso
  echo "Fatto: $(pwd)/nido-amd64.iso"
else
  echo "Build terminata senza ISO: controlla build.log" >&2
  exit 1
fi
