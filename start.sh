#!/usr/bin/env bash

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

print_old_log() {
  echo "--------------------print old log begin--------------------"
  [ -f $SCRIPT_DIR/debug.log ] && cat $SCRIPT_DIR/debug.log
  echo "--------------------print old log end--------------------"
}
# if [ "${BASH_SOURCE[0]}" = "$0" ]; then
#   print_old_log
# fi

print_info() {
  echo "--------------------print env begin--------------------"
  env | sort
  echo "--------------------print env end--------------------"

  echo "--------------------print basic info begin--------------------"
  id
  whoami
  uname -a
  arch
  dpkg --print-architecture
  cat /etc/os-release
  cat /proc/version
  uptime
  nproc
  free -h
  df -h
  lscpu
  cat /proc/meminfo
  cat /proc/cpuinfo
  systemd-detect-virt
  ps -p 1 -o comm=
  ps -p 1 -o args=
  cat /proc/1/comm
  cat /proc/1/cmdline | tr '\0' ' ' && echo
  cat /proc/1/cgroup
  cat /sys/fs/cgroup/cpu.max
  cat /sys/fs/cgroup/cpuset.cpus.effective
  cat /sys/fs/cgroup/cpu.stat
  cat /sys/fs/cgroup/memory.max
  cat /sys/fs/cgroup/memory.current
  cat /sys/fs/cgroup/memory.stat
  cat /sys/fs/cgroup/memory.events
  curl http://ip.cloudflare.nyc.mn?lang=zh-CN -4
  curl http://ip.cloudflare.nyc.mn?lang=zh-CN -6
  ss -tulnp
  echo "--------------------print basic info end--------------------"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -x
  exec > >(tee -a $SCRIPT_DIR/debug.log) 2>&1

  print_info
  # exec bash -i
fi

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -euxo pipefail
fi

log() {
  echo "[$(date '+%F %T')] $*"
}

export DEFAULT_SSH_PUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3XJGLkzeHo0OKEZl7USi7ao5Sk0KH8gXxF9uDizJrj5Hd6Q5WmsaQhdJjmtKlt9/AUjvpaRZNHejcwssr0srW0KL/ZkBrJlqfIuwIp5aKj9SEohsQ2jApBqDjwOYfSAhJuqKXuiW5g9qIxpDZNhLk9uLtRkQvSwQR66pArzuvz1h+5xF1aW9ZDjkXCv/RdqJQRFeqwLxjgDyH9Tl/iu4RolAQtwTVrqiNG6MECSA/sElfXUGy8Te6TJAgsTp6HR8GyYqOlP/DhU3yjmCSH5XVmbPr8keCkPQ8MaPBU4KWhEX2Wqc96GMLSeguyqcZOx+CsyiPkCvZFY1xs2fMjkkdJtcZ/mf5ETjc+3Ss7d7kwjIo0Ajpb5uyLh+ZR+iylSdgJXwAmtm8WpZuBHjbbWKK2VfzpNhzvuGgSWkIs0ZvX1E6Tsn3ng/o496VQ3XLJWkbpJsFY+b2w7xArwJjpucP8z0Y0lU3MqCo3y6rDvtkWpZmZL0r5pReNo5WSN3VKhTtuQOvOARnIeEx8a4Dp9G1wQX60gYzPlIM2d6wi4DAyLKt+AXpJyHA6MyoA+tuYZcQuryMTfnojtn0/TAYagDlk2XdQRlLeI7/RUlFmrLFdnBtWrUGUK/OcJjnaiwGewu8Oa4ELlkONqvjF6o3CflZsugXNEHD0uHj78wd9CrgkQ=='

if [ -f "$SCRIPT_DIR/.pd_env" ]; then
  set -a
  source "$SCRIPT_DIR/.pd_env"
  set +a
fi

if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

export ROOT=${ROOT:-$SCRIPT_DIR}
export HOST_GOTTY=${HOST_GOTTY:-0}
export IMAGE=${IMAGE:-ubuntu:26.04}
export PORT_NAME=${PORT_NAME:-}
export PORT=${PORT:-${SERVER_PORT:-5000}}
[ -n "$PORT_NAME" ] && export PORT=${!PORT_NAME:-${PORT}} || true
export PD_DAEMON=${PD_DAEMON:-0}
export FRONTEND_COMMAND=${FRONTEND_COMMAND:-'exec bash -i'}
export ROOTFS_PKGS="${ROOTFS_PKGS:-}"
export SUPERVISORD_DAEMON=${SUPERVISORD_DAEMON:-0}
export ROOTFS_FRONTEND_COMMAND=${ROOTFS_FRONTEND_COMMAND:-'exec bash -i'}
export SSLH_SSH_PORT=${SSLH_SSH_PORT:-2222}
export SSLH_HTTP_PORT=${SSLH_HTTP_PORT:-80}
export SSLH_TLS_PORT=${SSLH_TLS_PORT:-443}
export SSLH_DEFAULT_PORT=${SSLH_DEFAULT_PORT:-8000}
export SSH_PWD=${SSH_PWD:-}
export SSH_PUBKEY=${SSH_PUBKEY:-$DEFAULT_SSH_PUBKEY}
export HTTP_FILE=${HTTP_FILE:-0}
export HTTP_GOTTY_AUTH=${HTTP_GOTTY_AUTH:-}
export CLOUDFLARED_PORT=${CLOUDFLARED_PORT:-}
export CLOUDFLARED_TOKEN=${CLOUDFLARED_TOKEN:-}
export KOMARI_AGENT_ENDPOINT=${KOMARI_AGENT_ENDPOINT:-}
export KOMARI_AGENT_TOKEN=${KOMARI_AGENT_TOKEN:-}
export KOMARI_AGENT_COMMAND=${KOMARI_AGENT_COMMAND:-"agent -e ${KOMARI_AGENT_ENDPOINT} -i 5 -t ${KOMARI_AGENT_TOKEN}"}
export RUN_MC_PLAYER=${RUN_MC_PLAYER:-0}
export REBOOT_INTERVAL_SECS=${REBOOT_INTERVAL_SECS:-0}
export PD_ENVS="PORT ROOTFS_PKGS SUPERVISORD_DAEMON ROOTFS_FRONTEND_COMMAND SSLH_SSH_PORT SSLH_HTTP_PORT SSLH_TLS_PORT SSLH_DEFAULT_PORT SSH_PWD SSH_PUBKEY HTTP_FILE HTTP_GOTTY_AUTH CLOUDFLARED_PORT CLOUDFLARED_TOKEN KOMARI_AGENT_ENDPOINT KOMARI_AGENT_TOKEN KOMARI_AGENT_COMMAND RUN_MC_PLAYER REBOOT_INTERVAL_SECS"

: >"$SCRIPT_DIR/.pd_env"
for v in $PD_ENVS; do
  if [ -n "${!v+x}" ]; then
    # printf 'export %s=%q\n' "$v" "${!v}" >>"$SCRIPT_DIR/.pd_env"
    printf "%s='%s'\n" "$v" "$(printf '%s' "${!v}" | sed "s/'/'\\\\''/g")" >>"$SCRIPT_DIR/.pd_env"
  fi
done

read -r -a envs_arr <<<"ROOT HOST_GOTTY IMAGE PORT_NAME PD_DAEMON $PD_ENVS PD_ENVS"
for v in "${envs_arr[@]}"; do
  log "$v: ${!v-}"
done

export BIN_DIR="$ROOT/.bin"
export TMP_DIR="$ROOT/.tmp"
export LOG_DIR="$ROOT/.log"

export PATH=~/.local/bin:$PATH
export PATH=$BIN_DIR:$PATH

export DEBIAN_FRONTEND=noninteractive
export TZ="Asia/Shanghai"

have() { command -v "$1" >/dev/null 2>&1; }
install_pkg() {
  if ! env DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    NEEDRESTART_MODE=a \
    APT_LISTCHANGES_FRONTEND=none \
    APT_LISTBUGS_FRONTEND=none \
    UCF_FORCE_CONFFOLD=1 UCF_FORCE_CONFDEF=1 \
    apt-get install -y -qq \
    -o Dpkg::Options::="--force-confold" \
    -o Dpkg::Options::="--force-confdef" \
    "$@"; then
    echo "install pkg fail, trying fix for: $*" >&2
    fix_pkg "$@"
  fi
}
fix_pkg() {
  local pkg
  for pkg in "$@"; do
    case "$pkg" in -*) continue ;; esac
    pkg="${pkg%%=*}"
    dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok" || continue
    [ -f "/var/lib/dpkg/info/$pkg.postinst" ] || continue

    printf '#!/bin/sh\nexit 0\n' >"/var/lib/dpkg/info/$pkg.postinst"
    chmod +x "/var/lib/dpkg/info/$pkg.postinst"
    dpkg --configure "$pkg"
  done
  dpkg --configure -a
}
download() {
  local dst=$1 url=$2
  local tmp="$dst.tmp"
  rm -f "$tmp"
  if have curl; then
    curl -fsSL --retry 2 --connect-timeout 10 -o "$tmp" "$url" || {
      rm -f "$tmp"
      return 1
    }
  elif have wget; then
    wget -q --tries=2 --timeout=10 -O "$tmp" "$url" || {
      rm -f "$tmp"
      return 1
    }
  elif have python3; then
    local py='
import sys, urllib.request
url, dst = sys.argv[1], sys.argv[2]
with urllib.request.urlopen(url, timeout=10) as r, open(dst, "wb") as f:
    if getattr(r, "status", 200) != 200:
        sys.exit(1)
    f.write(r.read())
'
    python3 -c "$py" "$url" "$tmp" || {
      rm -f "$tmp"
      return 1
    }
  else
    log "no curl/wget/python3 to download"
    install_pkg curl wget || install_python || {
      log "install curl/wget fail"
      return 1
    }
    download "$dst" "$url"
    return $?
  fi
  mv -f "$tmp" "$dst"
}
exec_remote_script() {
  local url=$1
  shift
  local tmp="$(mktemp)"
  download "$tmp" "$url" || {
    rm -f "$tmp"
    return 1
  }
  chmod +x "$tmp"
  "$tmp" "$@"
  local ret=$?
  rm -f "$tmp"
  return $ret
}

sync_repo() {
  if ! have git; then
    install_pkg git || {
      log "install git fail"
      return 1
    }
  fi
  if [ -d .git ]; then
    git fetch --all
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
  else
    tmpdir=$(mktemp -d)
    git clone https://github.com/Alost/paas_container.git "$tmpdir"
    cp -a "$tmpdir"/. ./
    rm -rf "$tmpdir"
  fi
}
clean() {
  pd remove ct || true
  pip uninstall -y proot-distro || true
  rm -rf ~/.cache ~/.local
  rm -rf $BIN_DIR $TMP_DIR $LOG_DIR $ROOT/.venv $ROOT/.myrc
}

install_python() {
  log "install python"
  [ -f "$ROOT/.venv/bin/activate" ] && source $ROOT/.venv/bin/activate || true
  if have pip; then
    return 0
  fi
  download "$TMP_DIR/uv.tar.gz" https://github.com/astral-sh/uv/releases/download/0.13.1/uv-$(arch)-unknown-linux-musl.tar.gz
  tar xzf "$TMP_DIR/uv.tar.gz" -C "$BIN_DIR" --strip-components=1
  chmod +x "$BIN_DIR/uv"
  uv python install 3.15 --default
  rm -rf $ROOT/.venv
  uv venv $ROOT/.venv --seed
  source $ROOT/.venv/bin/activate
  # ~/.local/share/uv
}

# 解决java容器不回收孤儿进程导致pid耗尽问题
subreaper() {
  log "subreaper"
  [ "${SUBREAPER_ACTIVE:-0}" != 1 ] || return 0
  pid1_comm=$(cat /proc/1/comm 2>/dev/null)
  case "$pid1_comm" in
  java)
    echo "pid1 $pid1_comm is not init, restart with subreaper"
    install_python
    cat >$BIN_DIR/subreaper.py <<'EOF'
#!/usr/bin/env python3
import ctypes
import os
import signal
import subprocess
import sys
libc = ctypes.CDLL(None, use_errno=True)
PR_SET_CHILD_SUBREAPER = 36
if libc.prctl(PR_SET_CHILD_SUBREAPER, 1, 0, 0, 0) != 0:
    print('prctl(PR_SET_CHILD_SUBREAPER) fail', file=sys.stderr)
def reap(signum, frame):
    while True:
        try:
            pid, _ = os.waitpid(-1, os.WNOHANG)
            if pid == 0:
                break
        except ChildProcessError:
            break
signal.signal(signal.SIGCHLD, reap)
p = subprocess.Popen(sys.argv[1:])
sys.exit(p.wait())
EOF
    exec env SUBREAPER_ACTIVE=1 python3 $BIN_DIR/subreaper.py bash $ROOT/start.sh "$@" || exit 1
    ;;
  *)
    echo "pid1 $pid1_comm maybe init"
    ;;
  esac
}

install_gotty() {
  log "install gotty"
  if have gotty; then
    return 0
  fi
  download "$TMP_DIR/gotty.tar.gz" https://github.com/sorenisanerd/gotty/releases/download/v1.10.0/gotty_v1.10.0_linux_$(dpkg --print-architecture).tar.gz
  tar xzf "$TMP_DIR/gotty.tar.gz" -C "$BIN_DIR"
  chmod +x "$BIN_DIR/gotty"
}
run_host_gotty() {
  install_gotty
  gotty -p $PORT -w -c root:toor /bin/bash
}
install_proot() {
  log "install proot"
  export PROOT_NO_SECCOMP=1
  if [ -x "$BIN_DIR/proot" ]; then
    return 0
  fi
  download "$BIN_DIR/proot" https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-$(arch)-static
  chmod +x "$BIN_DIR/proot"
}
install_proot-distro() {
  log "install proot-distro"
  if have pd; then
    pd list
    ct_exec id
    return 0
  fi
  pip install --break-system-packages proot-distro
  pd install -q $IMAGE --name ct
  pd list
  pd login ct -- id
  ct_exec id
  ct_exec bash -s <<EOF
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -qq
# gnu-which for which, busybox for tar
apt-get install -y -qq gnu-which busybox
apt-get install -y -qq --no-install-recommends curl wget nano vim iproute2 less iputils-ping net-tools git psmisc
[ -z "$ROOTFS_PKGS" ] || apt-get install -y -qq --no-install-recommends ${ROOTFS_PKGS}
echo "127.0.1.1 $(hostname)" >> /etc/hosts
EOF
  # ~/.local/share/proot-distro/containers
}
ct_shell() {
  local -a envs=()
  local v
  for v in $PD_ENVS; do
    envs+=(-e "$v=${!v-}")
  done
  pd login ct -b "$ROOT:/root" \
    "${envs[@]}" \
    "$@"
}
ct_exec() {
  ct_shell -- "$@"
}
ct_exec_daemon() {
  ct_shell -d -- "$@"
}
config_bashrc() {
  cp -a ~/.local/share/proot-distro/containers/ct/rootfs/root/. $ROOT/
  cat >$ROOT/.bash_aliases <<'EOF'
alias reboot='pkill -9 -f run_ct'
reset_system() {
  touch ~/.clean; reboot
}
EOF
  cat >$ROOT/.myrc <<'EOF'
PS1='\u@ct:\w\$ '
export PATH=~/.bin:$PATH
chmod +x ~/.bin/*
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/start.sh ] && . ~/start.sh >/dev/null
EOF
  echo '[ "$(id -u)" -eq 0 ] && [ -f ~/.myrc ] && . ~/.myrc' >>$ROOT/.bashrc
}

# ct
_papt() {
  local pkg="$1" deps=0
  [ "$1" = "--deps" ] && {
    deps=1
    pkg="$2"
  }
  [ -n "$pkg" ] || {
    echo "usage: papt [--deps] <pkg>" >&2
    return 1
  }

  local work
  work=$(mktemp -d) || return 1
  cd "$work" || return 1

  local pkgs="$pkg"
  if [ "$deps" = 1 ]; then
    pkgs=$(apt-cache depends --recurse --no-recommends --no-suggests \
      --no-conflicts --no-breaks --no-replaces --no-enhances "$pkg" 2>/dev/null |
      awk '/^[[:alnum:]]/ && $1 !~ /^</ {print $1}' | sed 's/:.*$//' | sort -u)
    [ -n "$pkgs" ] || pkgs="$pkg"
  fi
  echo "papt will download and extract pkgs: $pkgs"

  echo "papt downloading"
  local p
  for p in $pkgs; do
    apt-get download "$p" || echo "papt: skip $p" >&2
  done
  echo "papt download finish"

  echo "papt extracting"
  local deb
  for deb in *.deb; do
    [ -f "$deb" ] && dpkg-deb -x "$deb" extract
  done
  [ -d extract ] || {
    echo "papt: nothing extracted" >&2
    cd ~
    rm -rf "$work"
    return 1
  }
  rm -rf extract/DEBIAN
  cp -a extract/. /
  ldconfig 2>/dev/null || true
  echo "papt extract finish"

  cd ~
  rm -rf "$work"
}
papt() {
  local pkg
  for pkg in "$@"; do
    _papt "$pkg"
  done
}
install_supervisor() {
  log "install supervisor"
  if have svd; then
    return 0
  fi
  echo 'tzdata tzdata/Areas select Asia' | debconf-set-selections
  echo 'tzdata tzdata/Zones/Asia select Shanghai' | debconf-set-selections
  install_pkg supervisor
  # /etc/supervisor/supervisord.conf
  # /etc/supervisor/conf.d/*.conf
  # /usr/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon
  cp -f /usr/bin/supervisord "$BIN_DIR/svd"
}
add_supervisor_service() {
  local name="$1" cmd="$2" workdir="${3:-/root}"
  if [ -z "$name" ] || [ -z "$cmd" ]; then
    echo "usage: add_supervisor_service <name> <cmd> [workdir]" >&2
    return 1
  fi
  log "add supervisor service: name=$name, cmd=$cmd, workdir=$workdir"
  local conf="/etc/supervisor/conf.d/$name.conf"
  cat >"$conf" <<EOF
[program:$name]
command=$cmd
directory=$workdir
user=root
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stopwaitsecs=10
redirect_stderr=true
stdout_logfile=/root/.log/$name.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=10
EOF
  if supervisorctl status >/dev/null 2>&1; then
    supervisorctl update
  else
    log "supervisord not running, skip update"
  fi
}
sv() {
  local cmd="${1:-}"
  shift 1 || true
  case "$cmd" in
  add)
    add_supervisor_service "$@"
    ;;
  status | list | ls | "")
    supervisorctl status "$@"
    ;;
  remove | delete | rm)
    supervisorctl remove "$@"
    for app in "$@"; do
      rm -f /etc/supervisor/conf.d/$app.conf
    done
    supervisorctl update
    ;;
  update | reload)
    supervisorctl update
    ;;
  cat)
    local dir=/etc/supervisor/conf.d
    if [[ $# -eq 0 ]]; then
      echo "# $dir"
      ls -lh $dir
      return
    fi
    for app in "$@"; do
      local f=$dir/$app.conf
      if [ -f $f ]; then
        echo "# $f" && cat "$f" && echo
      else
        echo "$f not exists"
      fi
    done
    ;;
  tail | log)
    supervisorctl tail "$@"
    ;;
  *)
    supervisorctl "$cmd" "$@"
    ;;
  esac
}
install_java() {
  log "install java"
  export JAVA_HOME=/usr/lib/jvm/java-26-openjdk-amd64
  if have java; then
    return 0
  fi
  install_pkg openjdk-26-jre-headless ca-certificates-java
  dpkg-reconfigure ca-certificates-java
  ls -lh /etc/ssl/certs/java/cacerts
}
install_dropbear() {
  log "install dropbear"
  if have sctrl; then
    return 0
  fi
  install_pkg dropbear
  # /etc/default/dropbear
  # ~/.ssh/authorized_keys
  # dropbear -R -E -p $PORT -F
  cp -f /usr/sbin/dropbear "$BIN_DIR/sctrl"
  add_supervisor_service dropbear "sctrl -R -E -p $SSLH_SSH_PORT -F"
}
config_ssh() {
  [ -z "$SSH_PWD" ] || printf 'root:%s\n' "$SSH_PWD" | chpasswd
  mkdir -p ~/.ssh
  cat >~/.ssh/authorized_keys <<EOF
$SSH_PUBKEY
EOF
  chmod 600 ~/.ssh/authorized_keys
}
install_openssh() {
  log "install openssh"
  if have sshd; then
    return 0
  fi
  # Assertion failed: length2 > 0 (./path/path.c: compare_paths2: 547)
  # install_pkg --no-install-recommends openssh-server
  papt --deps openssh-server
  cp -a /usr/share/openssh/sshd_config /etc/ssh/sshd_config
  ssh-keygen -A
  groupadd sshd
  useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd
  mkdir -p /run/sshd && chmod 755 /run/sshd
  cat >/etc/ssh/sshd_config.d/my.conf <<EOF
#Port $SSLH_SSH_PORT
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
UsePrivilegeSeparation no
UsePAM no
PrintMotd no
KbdInteractiveAuthentication no
UseDNS no
GSSAPIAuthentication no
X11Forwarding no
ClientAliveInterval 60
ClientAliveCountMax 5
EOF
  # Operation not permitted [preauth]
  # add_supervisor_service openssh "/usr/sbin/sshd -D -e -p $SSLH_SSH_PORT"
}
install_sslh() {
  log "install sslh"
  if have smux; then
    return 0
  fi
  echo 'sslh sslh/inetd_or_standalone select standalone' | debconf-set-selections
  install_pkg --no-install-recommends sslh
  cp -f /usr/sbin/sslh "$BIN_DIR/smux"
  add_supervisor_service sslh "smux -f -p 0.0.0.0:$PORT -p [::]:$PORT --ssh 127.0.0.1:$SSLH_SSH_PORT --http 127.0.0.1:$SSLH_HTTP_PORT --tls 127.0.0.1:$SSLH_TLS_PORT --anyprot 127.0.0.1:$SSLH_DEFAULT_PORT"
}
run_startup() {
  log "run startup"
  if [ ! -f ~/.startup ]; then
    cat >~/.startup <<'EOF'
#!/usr/bin/env bash
JITTER_MAX=${JITTER_MAX:-3600}
[ "${REBOOT_INTERVAL_SECS:-0}" -gt 0 ] && {
    while :; do
        sleep $((REBOOT_INTERVAL_SECS + RANDOM % JITTER_MAX))
        log "startup reboot with interval $REBOOT_INTERVAL_SECS"
        reboot
    done
} &
EOF
  fi
  . ~/.startup
}
run_http_file() {
  log "run http file"
  add_supervisor_service http_file "/root/.venv/bin/python3 -u -m http.server $SSLH_HTTP_PORT"
}
run_http_gotty() {
  log "run http gotty"
  install_gotty
  add_supervisor_service http_gotty "gotty -p $SSLH_HTTP_PORT -w -c $HTTP_GOTTY_AUTH /bin/bash"
}
install_cloudflared() {
  log "install cloudflared"
  if have cfd; then
    return 0
  fi
  download "$TMP_DIR/cloudflared" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$(dpkg --print-architecture)
  mv -f "$TMP_DIR/cloudflared" "$BIN_DIR/cfd"
  chmod +x "$BIN_DIR/cfd"
  if [ -n "$CLOUDFLARED_PORT" ]; then
    add_supervisor_service cloudflared_fast "cfd tunnel --edge-ip-version auto --protocol http2 --url http://localhost:$CLOUDFLARED_PORT"
    # grep -o 'https://[^ ]*\.trycloudflare\.com' ~/.log/cloudflared_fast.log | tail -n 1
  fi
  if [ -n "$CLOUDFLARED_TOKEN" ]; then
    add_supervisor_service cloudflared "cfd tunnel --edge-ip-version auto --protocol http2 run --token $CLOUDFLARED_TOKEN"
    # ssh -o ProxyCommand="cloudflared access ssh --hostname %h" root@infrlo.cosy.dns-dynamic.net
  fi
}
install_komari_agent() {
  log "install komari-agent"
  if have agent; then
    return 0
  fi
  download "$TMP_DIR/agent" https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-$(dpkg --print-architecture)
  mv -f "$TMP_DIR/agent" "$BIN_DIR/agent"
  chmod +x "$BIN_DIR/agent"
  add_supervisor_service komari-agent "$KOMARI_AGENT_COMMAND"
}
run_mc_player() {
  log "run mc_player"
  if [ ! -f "$BIN_DIR/mc_player.py" ]; then
    cat >"$BIN_DIR/mc_player.py" <<'EOF'
import asyncio, random, sys
from minecraft.networking.connection import Connection
async def play(host, port, name, playTime):
    conn = Connection(host, port, username=name)
    try:
        print(f'play start, {host=}, {port=}, {name=}, {playTime=}s')
        conn.connect()
        await asyncio.sleep(playTime)
        print(f'play finish, {host=}, {port=}, {name=}, {playTime=}s')
    except Exception as e:  # noqa: BLE001
        print(f'connect fail, {host=}, {port=}, {name=}, {e=}')
    finally:
        try:
            conn.disconnect()
        except Exception as e:  # noqa: BLE001
            print(f'disconnect fail, {host=}, {port=}, {name=}, {e=}')
async def player(host, port, name, fixed=False):
    while True:
        if fixed or random.choice([True, False]):
            playTime = random.randint(60 * 60, 6 * 60 * 60)
            await play(host, port, name, playTime)
            await asyncio.sleep(60)
        else:
            await asyncio.sleep(6 * 60 * 60)
async def main(host, port):
    names = ['Ethan', 'Olivia', 'Lucas', 'Sophia']
    tasks = [asyncio.create_task(player(host, port, 'King', True))]
    tasks.extend([asyncio.create_task(player(host, port, name)) for name in names])
    await asyncio.gather(*tasks, return_exceptions=True)
if __name__ == '__main__':
    host, port = sys.argv[1], int(sys.argv[2])
    try:
        asyncio.run(main(host, port))
    except KeyboardInterrupt:
        pass
EOF
  fi
  install_python
  pip install pycraft-minecraft
  add_supervisor_service mc-player "/root/.venv/bin/python3 -u $BIN_DIR/mc_player.py localhost $PORT"
}

run_ct() {
  set -euxo pipefail
  log "run ct"

  install_supervisor

  install_dropbear
  config_ssh
  install_sslh

  run_startup

  if [ "$HTTP_FILE" = 1 ]; then
    run_http_file
  elif [ -n "$HTTP_GOTTY_AUTH" ]; then
    run_http_gotty
  fi

  if [ -n "$CLOUDFLARED_PORT" ] || [ -n "$CLOUDFLARED_TOKEN" ]; then
    install_cloudflared
  fi
  if [ -n "$KOMARI_AGENT_ENDPOINT" ] && [ -n "$KOMARI_AGENT_TOKEN" ]; then
    install_komari_agent
  fi

  if [ "$SUPERVISORD_DAEMON" = 0 ]; then
    svd -c /etc/supervisor/supervisord.conf --nodaemon
  else
    nohup svd -c /etc/supervisor/supervisord.conf --nodaemon >~/.log/supervisord.log 2>&1 &
    case "$ROOTFS_FRONTEND_COMMAND" in
    *java\ *) install_java ;;
    esac
    if [ "$RUN_MC_PLAYER" = 1 ]; then
      (
        sleep 10
        run_mc_player
      ) &
    fi
    eval $ROOTFS_FRONTEND_COMMAND
  fi
}
start_ct() {
  config_bashrc
  if [ "$PD_DAEMON" = 0 ]; then
    ct_exec bash -i -c 'run_ct'
  else
    ct_exec_daemon bash -i -c 'run_ct'
    eval $FRONTEND_COMMAND
  fi
}

main() {
  log "start main"

  if [ -f "$ROOT/.clean" ]; then
    clean
    rm -f "$ROOT/.clean"
  fi

  mkdir -p "$BIN_DIR" "$TMP_DIR" "$LOG_DIR"

  subreaper

  if [ "$HOST_GOTTY" = 1 ]; then
    run_host_gotty
    return $?
  fi

  install_python
  install_proot
  install_proot-distro

  if [ -f "$ROOT/.debug" ]; then
    exec bash -i
  else
    start_ct
  fi
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
