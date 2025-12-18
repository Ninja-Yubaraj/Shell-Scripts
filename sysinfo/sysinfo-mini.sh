#!/usr/bin/env bash

echo "OS      : $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"
echo "Kernel  : $(uname -r) $(uname -m)"
echo "Uptime  : $(uptime -p)"

echo
echo "CPU     : $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
echo "Load    : $(cut -d' ' -f1-3 /proc/loadavg)"

echo
echo "Memory:"
free -h | awk 'NR==1||NR==2||NR==3'

echo
echo "Disk:"
df -hT -x tmpfs -x devtmpfs

echo
echo "Network:"
ip -br addr
ip route
ping -c1 8.8.8.8 >/dev/null 2>&1 && echo "Internet: OK" || echo "Internet: FAIL"

echo
echo "Failed services:"
command -v systemctl >/dev/null && systemctl --failed --no-pager || echo "N/A"

echo
echo "Kernel errors:"
dmesg | tail -n 5
