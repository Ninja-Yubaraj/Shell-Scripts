#!/usr/bin/env bash

# ==================================================
# Minimal Linux System Info (AI-friendly)
# No external packages required
# ==================================================

set -e

echo "===== SYSTEM ====="
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "OS        : $PRETTY_NAME"
else
    echo "OS        : $(uname -s)"
fi
echo "Kernel    : $(uname -r)"
echo "Arch      : $(uname -m)"
echo "Hostname  : $(hostname)"
echo "Uptime    : $(uptime -p)"

echo
echo "===== CPU ====="
echo "Model     : $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"
echo "Cores     : $(nproc)"
echo "Load Avg  : $(cut -d' ' -f1-3 /proc/loadavg)"

echo
echo "===== MEMORY ====="
free -h | awk 'NR==1 || NR==2 || NR==3'

echo
echo "===== STORAGE ====="
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
echo
df -hT -x tmpfs -x devtmpfs

echo
echo "===== NETWORK ====="
ip -br addr
echo
ip route
echo
ping -c 1 8.8.8.8 >/dev/null 2>&1 && \
    echo "Internet : OK" || echo "Internet : FAILED"

echo
echo "===== SERVICES ====="
if command -v systemctl >/dev/null 2>&1; then
    systemctl --failed --no-pager || echo "No failed services"
else
    echo "systemd not present"
fi

echo
echo "===== KERNEL LOG (last 10) ====="
dmesg | tail -n 10

echo
echo "===== END ====="
