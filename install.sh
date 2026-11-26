#!/bin/bash
# Theme Pterodactyl HomeServer by DalangStore from Indonesia
# Smart CLI wrapper, ID EN, direct GitHub pull, silent pull, y/n critical, auto update tools.
set -euo pipefail

GITHUB_USER="ajisetio8765-blip"
GITHUB_REPO="installhome"
BRANCH="main"
RELEASE_TAG="v1.0.0"

SELF_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/install.sh"
ARCHIVE_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/homeserver-theme.tar.gz"
ARCHIVE_URL_LATEST="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/latest/download/homeserver-theme.tar.gz"

if [ "$(id -u)" != "0" ]; then
  if command -v sudo >/dev/null 2>&1; then
    if [ -f "${0:-}" ] && [ "${0:-bash}" != "bash" ] && [ "$0" != "-bash" ] && [ "$0" != "/dev/fd/63" ] && [[ "$0" != /dev/fd/* ]]; then
      exec sudo -E bash "$0" "$@"
    else
      TMP_SELF="$(mktemp /tmp/hscli.XXXXXX)"
      curl -fsSL "$SELF_URL" -o "$TMP_SELF"
      chmod +x "$TMP_SELF"
      exec sudo -E bash "$TMP_SELF" "$@"
    fi
  else
    echo "ERROR: run as root or install sudo first" >&2
    exit 1
  fi
fi

HS_LANG="${HOMESERVER_LANG:-${HS_LANG:-}}"
ACTION_IN="${1:-}"
if [ -z "$HS_LANG" ]; then
  case "${ACTION_IN:-}" in
    id|ID|indonesia|Indonesian) HS_LANG="id"; shift || true ;;
    en|EN|english|English) HS_LANG="en"; shift || true ;;
  esac
fi
if [ $# -eq 0 ] && [ ! -t 0 ]; then
  HS_LANG="${HS_LANG:-id}"
  set -- install
fi

C_RESET="\033[0m"; C_GREY="\033[90m"; C_DARK="\033[38;5;235m"; C_PURPLE="\033[38;5;93m"; C_BLUE="\033[38;5;39m"; C_VIOLET="\033[38;5;135m"; C_WHITE="\033[37m"; C_GREEN="\033[38;5;42m"; C_RED="\033[38;5;196m"; C_YELLOW="\033[38;5;226m"
say() { printf "%b%s%b\n" "$1" "$2" "$C_RESET"; }
is_en() { [ "$HS_LANG" = "en" ]; }
T() { if is_en; then printf "%s" "$2"; else printf "%s" "$1"; fi; }

banner() {
  if [ -t 1 ]; then clear 2>/dev/null || true; fi
  say "$C_PURPLE" "   _   _                      ____"
  say "$C_PURPLE" "  | | | | ___  _ __ ___   ___/ ___|  ___ _ ____   _____ _ __"
  say "$C_VIOLET" "  | |_| |/ _ \| '_ \` _ \ / _ \___ \ / _ \ '__\ \ / / _ \ '__|"
  say "$C_BLUE" "  |  _  | (_) | | | | | |  __/___) |  __/ |   \ V /  __/ |"
  say "$C_GREY" "  |_| |_|\___/|_| |_| |_|\___|____/ \___|_|    \_/ \___|_|"
  say "$C_PURPLE" "  Theme Pterodactyl HomeServer"
  say "$C_GREY" "  by DalangStore from Indonesia | v1.15.2 | MIT"
  echo ""
}

lang_menu() {
  banner
  say "$C_WHITE" "  Choose language / Pilih bahasa:"
  say "$C_BLUE" "  [1] Indonesia"
  say "$C_PURPLE" "  [2] English"
  echo ""
  printf "%b" "$C_GREY"
  if [ -t 0 ]; then
    read -r -p "  homeserver@panel:~\$ lang [1-2] (default 1): " LANG_PICK
  elif [ -c /dev/tty ] 2>/dev/null; then
    read -r -p "  homeserver@panel:~\$ lang [1-2] (default 1): " LANG_PICK < /dev/tty
  else
    LANG_PICK="1"
  fi
  printf "%b" "$C_RESET"
  LANG_PICK="${LANG_PICK:-1}"
  case "$LANG_PICK" in
    2|en|EN|english|English) HS_LANG="en" ;; *) HS_LANG="id" ;;
  esac
  export HOMESERVER_LANG="$HS_LANG"
  export HS_LANG="$HS_LANG"
}

confirm() {
  local qid="$1" qen="$2"
  local ans=""
  if [ -t 0 ]; then
    printf "%b" "$C_YELLOW"
    read -r -p "  homeserver@panel:~\$ $(T "$qid" "$qen") [y/N]: " ans
    printf "%b" "$C_RESET"
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    printf "%b" "$C_YELLOW" > /dev/tty
    read -r -p "  homeserver@panel:~\$ $(T "$qid" "$qen") [y/N]: " ans < /dev/tty
    printf "%b" "$C_RESET" > /dev/tty
  else
    return 1
  fi
  case "$ans" in y|Y|ya|YA|yes|YES) return 0 ;; *) return 1 ;; esac
}

menu() {
  banner
  if is_en; then
    say "$C_WHITE" "  Select action:"
    say "$C_BLUE" "  [1] Install theme"
    say "$C_BLUE" "  [7] Update"
    say "$C_BLUE" "  [8] Reinstall"
    say "$C_GREY" "  [2] Check system"
    say "$C_VIOLET" "  [3] Backup"
    say "$C_PURPLE" "  [4] Rollback"
    say "$C_RED" "  [6] Uninstall theme"
    say "$C_GREY" "  [0] Language  [5] Exit"
  else
    say "$C_WHITE" "  Pilih aksi:"
    say "$C_BLUE" "  [1] Install theme"
    say "$C_BLUE" "  [7] Update"
    say "$C_BLUE" "  [8] Reinstall"
    say "$C_GREY" "  [2] Cek sistem"
    say "$C_VIOLET" "  [3] Backup"
    say "$C_PURPLE" "  [4] Rollback"
    say "$C_RED" "  [6] Uninstall theme"
    say "$C_GREY" "  [0] Bahasa  [5] Keluar"
  fi
  echo ""
  say "$C_DARK" "  ─────────────────────────────"
  printf "%b" "$C_GREY"
  if [ -t 0 ]; then
    read -r -p "  homeserver@panel:~\$ run [0-8] (default 1): " PICK
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    read -r -p "  homeserver@panel:~\$ run [0-8] (default 1): " PICK < /dev/tty
  else
    PICK="1"
  fi
  printf "%b" "$C_RESET"
  PICK="${PICK:-1}"
  case "$PICK" in
    1) ACTION="install" ;; 2) ACTION="check" ;; 3) ACTION="backup" ;; 4) ACTION="rollback" ;; 6) ACTION="uninstall" ;;
    7) ACTION="update" ;; 8) ACTION="reinstall" ;;
    0) lang_menu; menu; return 0 ;;
    5) say "$C_GREEN" "  $(T "Sampai jumpa." "Bye.")"; exit 0 ;;
    *) ACTION="install" ;;
  esac
}

spinner() {
  local msg="$1"; shift
  local frames="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"
  printf "%b" "$C_PURPLE" >&2
  "$@" >"$TMP_DIR/job.log" 2>&1 &
  local pid=$!
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i + 1) % 10 ))
    printf "\r\033[K  %s %s" "$(echo "$frames" | cut -d' ' -f$((i + 1)))" "$msg" >&2
    sleep 0.12
  done
  wait $pid
  local code=$?
  printf "\r\033[K%b" "$C_RESET" >&2
  return $code
}

PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"
ACTION=""
if [ $# -gt 0 ]; then
  case "${1:-}" in install|check|backup|rollback|uninstall|update|reinstall) ACTION="$1"; shift || true ;; *) ACTION="" ;; esac
fi

if [ -z "$HS_LANG" ]; then
  if [ -n "$ACTION" ]; then
    HS_LANG="id"
  elif [ -t 0 ]; then
    lang_menu
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    lang_menu </dev/tty || HS_LANG="id"
  else
    HS_LANG="id"
  fi
fi
HS_LANG="${HS_LANG:-id}"
export HOMESERVER_LANG="$HS_LANG"
export HS_LANG="$HS_LANG"

if [ -z "$ACTION" ]; then
  if [ -t 0 ]; then
    menu
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    menu </dev/tty || ACTION="install"
  else
    ACTION="install"
  fi
fi
case "$ACTION" in install|check|backup|rollback|uninstall|update|reinstall) ;; *) ACTION="install" ;; esac

if [ "$ACTION" = "install" ]; then
  if [ -t 0 ]; then
    confirm "Lanjut install HomeServer" "Continue HomeServer install" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  elif [ -c /dev/tty ] 2>/dev/null; then
    :
  fi
fi
if [ "$ACTION" = "update" ]; then
  if [ -t 0 ]; then
    confirm "Update ke versi terbaru, data server aman" "Update to latest, server data safe" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    confirm "Update ke versi terbaru, data server aman" "Update to latest, server data safe" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  fi
fi
if [ "$ACTION" = "reinstall" ]; then
  if [ -t 0 ]; then
    confirm "Install ulang penuh, .env dan database server aman" "Full reinstall, .env and server database safe" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    confirm "Install ulang penuh, .env dan database server aman" "Full reinstall, .env and server database safe" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  fi
fi
if [ "$ACTION" = "uninstall" ]; then
  if [ -t 0 ]; then
    confirm "Uninstall ke vanilla resmi, lanjut" "Uninstall to official vanilla, continue" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    confirm "Uninstall ke vanilla resmi, lanjut" "Uninstall to official vanilla, continue" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  fi
fi
if [ "$ACTION" = "rollback" ]; then
  if [ -t 0 ]; then
    confirm "Rollback ke backup terakhir, lanjut" "Rollback to latest backup, continue" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  elif [ -c /dev/tty ] 2>/dev/null && [ -t 1 ]; then
    confirm "Rollback ke backup terakhir, lanjut" "Rollback to latest backup, continue" || { say "$C_GREY" "  $(T "Dibatalkan." "Cancelled.")"; exit 0; }
  fi
fi

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT
log() { say "$C_GREY" "  ○ $1"; }
ok() { say "$C_GREEN" "  ● $1"; }
fail() { say "$C_RED" "  ✕ ERROR: $1"; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "$1 $(T "belum ada." "missing.")"; }

auto_update_tools() {
  local missing=0
  for b in curl tar rsync unzip; do command -v "$b" >/dev/null 2>&1 || missing=1; done
  if ! command -v mysqldump >/dev/null 2>&1; then missing=1; fi
  if [ "$missing" = "1" ]; then
    log "$(T "Auto update tools yang kurang..." "Auto updating missing tools...")"
    apt-get update -qq >/dev/null 2>&1 || true
    command -v rsync >/dev/null 2>&1 || apt-get install -y -qq rsync >/dev/null 2>&1 || true
    command -v mysqldump >/dev/null 2>&1 || apt-get install -y -qq mariadb-client >/dev/null 2>&1 || true
    command -v curl >/dev/null 2>&1 || apt-get install -y -qq curl >/dev/null 2>&1 || true
    command -v tar >/dev/null 2>&1 || apt-get install -y -qq tar >/dev/null 2>&1 || true
    command -v unzip >/dev/null 2>&1 || apt-get install -y -qq unzip >/dev/null 2>&1 || true
  fi
  if ! command -v composer >/dev/null 2>&1; then
    if [ -f "$PANEL_DIR/vendor/autoload.php" ]; then
      log "$(T "Composer dilewati, vendor sudah ada." "Composer skipped, vendor present.")"
    else
      log "$(T "Auto pasang composer..." "Auto installing composer...")"
      curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php >/dev/null 2>&1 || true
      php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet >/dev/null 2>&1 || true
      rm -f /tmp/composer-setup.php
    fi
  fi
}

find_panel() {
  if [ -f "$1/config/app.php" ] && [ -f "$1/artisan" ]; then echo "$1"; return 0; fi
  return 1
}

banner
say "$C_GREY" "  homeserver@panel:~\$ $ACTION"
auto_update_tools

if ! find_panel "$PANEL_DIR" >/dev/null 2>&1; then
  FOUND=""
  for d in /var/www/pterodactyl /var/www/panel /srv/pterodactyl /opt/pterodactyl; do
    if find_panel "$d" >/dev/null 2>&1; then FOUND="$d"; break; fi
  done
  if [ -n "$FOUND" ]; then
    PANEL_DIR="$FOUND"
  else
    fail "$(T "Panel tidak ketemu." "Panel not found.")"
  fi
fi

need curl

ARCHIVE="$TMP_DIR/theme.pkg"
EXTRACT="$TMP_DIR/extract"
mkdir -p "$EXTRACT"

download_pkg() {
  curl -fSL --retry 3 "$ARCHIVE_URL_LATEST" -o "$ARCHIVE" 2>/dev/null || curl -fSL --retry 3 "$ARCHIVE_URL" -o "$ARCHIVE"
}

spinner "$(T "Mengunduh paket dari GitHub..." "Downloading package from GitHub...")" download_pkg || fail "$(T "Gagal unduh paket dari GitHub (cek koneksi/rilis)." "Failed to download package from GitHub.")"
[ -s "$ARCHIVE" ] || fail "$(T "File paket kosong." "Package file is empty.")"

MAGIC="$(head -c 2 "$ARCHIVE" 2>/dev/null || true)"
if [ "$MAGIC" = "PK" ]; then
  need unzip
  unzip -tq "$ARCHIVE" >/dev/null 2>&1 || fail "$(T "Arsip ZIP rusak." "Broken ZIP archive.")"
  ok "$(T "Paket siap (ZIP)." "Package ready (ZIP).")"
  unzip -q "$ARCHIVE" -d "$EXTRACT" >/dev/null 2>&1 || fail "$(T "Ekstrak ZIP gagal." "ZIP extraction failed.")"
else
  need tar
  tar -tzf "$ARCHIVE" >/dev/null 2>&1 || fail "$(T "Arsip TAR.GZ rusak." "Broken TAR.GZ archive.")"
  ok "$(T "Paket siap (TAR.GZ)." "Package ready (TAR.GZ).")"
  tar -xzf "$ARCHIVE" -C "$EXTRACT" >/dev/null 2>&1 || fail "$(T "Ekstrak TAR.GZ gagal." "TAR.GZ extraction failed.")"
fi

SWITCHER_INSTALL="$(find "$EXTRACT" -maxdepth 3 -path "*/theme-switcher/install.sh" | head -n 1)"
[ -n "$SWITCHER_INSTALL" ] || fail "theme-switcher/install.sh $(T "hilang." "missing.")"
SWITCHER_DIR="$(dirname "$SWITCHER_INSTALL")"

if [ -f "$SWITCHER_DIR/backend/patch.sh" ]; then
  sed -i 's/    })$/    });/' "$SWITCHER_DIR/backend/patch.sh"
fi

say "$C_PURPLE" "  ─────────────────────────────"
PANEL_DIR="$PANEL_DIR" HOMESERVER_LANG="$HS_LANG" HS_LANG="$HS_LANG" bash "$SWITCHER_INSTALL" "$ACTION"
