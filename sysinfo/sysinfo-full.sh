#!/usr/bin/env bash

# ==========================================================
# System Information Collection Script
# Works on most Linux distributions
# No additional packages required
# ==========================================================

set -e

SEP="=========================================================="

echo "$SEP"
echo "SYSTEM OVERVIEW"
echo "$SEP"

# ---------------- OS INFO ----------------
echo
echo "[ OS INFORMATION ]"
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "OS Name       : $NAME"
    echo "OS Version    : $VERSION"
    echo "OS ID         : $ID"
    echo "Pretty Name   : $PRETTY_NAME"
else
    uname -a
fi
echo "Kernel        : $(uname -r)"
echo "Architecture  : $(uname -m)"
echo "Hostname      : $(hostname)"
echo "Uptime        : $(uptime -p)"

# ---------------- CPU INFO ----------------
echo
echo "[ CPU INFORMATION ]"
echo "CPU Model     : $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"
echo "CPU Cores     : $(grep -c '^processor' /proc/cpuinfo)"
echo "CPU Threads   : $(nproc)"
echo "CPU Frequency : $(grep -m1 'cpu MHz' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //') MHz"
lscpu | grep -E 'Socket|Thread|Core|Vendor' || true

# ---------------- RAM INFO ----------------
echo
echo "[ MEMORY (RAM) INFORMATION ]"
free -h
echo
echo "Detailed Memory Info:"
grep -E 'MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree' /proc/meminfo

# ---------------- STORAGE INFO ----------------
echo
echo "[ STORAGE INFORMATION ]"
echo "Block Devices:"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
echo
echo "Disk Usage:"
df -hT -x tmpfs -x devtmpfs

# ---------------- FILESYSTEM / FSTAB ----------------
echo
echo "[ FILESYSTEM CONFIGURATION ]"
cat /etc/fstab 2>/dev/null || echo "No /etc/fstab found"

# ---------------- NETWORK INFO ----------------
echo
echo "[ NETWORK INFORMATION ]"
echo "Interfaces:"
ip -br addr
echo
echo "Routing Table:"
ip route
echo
echo "DNS Configuration:"
cat /etc/resolv.conf

# ---------------- CONNECTIVITY CHECK ----------------
echo
echo "[ NETWORK STATUS ]"
ping -c 2 8.8.8.8 >/dev/null 2>&1 && \
    echo "Internet Access : OK" || \
    echo "Internet Access : FAILED"

# ---------------- SYSTEM LOAD ----------------
echo
echo "[ SYSTEM LOAD ]"
uptime
echo
top -b -n1 | head -n 15

# ---------------- PROCESS / SERVICE INFO ----------------
echo
echo "[ RUNNING SERVICES (systemd) ]"
if command -v systemctl >/dev/null 2>&1; then
    systemctl list-units --type=service --state=running --no-pager | head -n 20
else
    echo "systemd not available"
fi

# ---------------- HARDWARE INFO ----------------
echo
echo "[ HARDWARE OVERVIEW ]"
echo "PCI Devices:"
lspci 2>/dev/null || echo "lspci not available"
echo
echo "USB Devices:"
lsusb 2>/dev/null || echo "lsusb not available"

# ---------------- SECURITY / LIMITS ----------------
echo
echo "[ SECURITY & LIMITS ]"
echo "SELinux Status:"
command -v sestatus >/dev/null 2>&1 && sestatus || echo "SELinux not installed"
echo
echo "Open Files Limit:"
ulimit -n

# ---------------- LOG HINTS ----------------
echo
echo "[ LOG FILE HINTS ]"
echo "Recent dmesg (last 20 lines):"
dmesg | tail -n 20

echo
echo "$SEP"
echo "END OF SYSTEM REPORT"
echo "$SEP"
