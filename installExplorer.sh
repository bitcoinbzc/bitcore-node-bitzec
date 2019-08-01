
#!/bin/bash

# install needed dependencies
cd
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
sudo apt-get install -y libzmq3-dev

# MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.1 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.1.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl enable mongod
sudo service mongod start

#bitcore-node-bitzec
cd
git clone https://github.com/bitzec/bitcore-node-bitzec
cd bitcore-node-bitzec
npm install
cd bin
chmod +x bitcore-node
cp ~/bitzec/src/bitzecd ~/bitcore-node-bitzec/bin
./bitcore-node create mynode
cd mynode

rm bitcore-node.json

cat << EOF > bitcore-node.json
{
  "network": "livenet",
  "port": 3001,
  "services": [
    "bitcoind",
    "insight-api-bitzec",
    "insight-ui-bitzec",
    "web"
  ],
  "messageLog": "",
  "servicesConfig": {
      "web": {
      "disablePolling": false,
      "enableSocketRPC": false
    },
    "bitcoind": {
      "sendTxLog": "./data/pushtx.log",
      "spawn": {
        "datadir": "./data",
        "exec": "../bitzecd",
        "rpcqueue": 1000,
        "rpcport": 8732,
        "zmqpubrawtx": "tcp://127.0.0.1:28732",
        "zmqpubhashblock": "tcp://127.0.0.1:28732"
      }
    },
    "insight-api-bitzec": {
        "routePrefix": "api",
                 "db": {
                   "host": "127.0.0.1",
                   "port": "27017",
                   "database": "bitzec-api-livenet",
                   "user": "",
                   "password": ""
          },
          "disableRateLimiter": true
    },
    "insight-ui-bitzec": {
        "apiPrefix": "api",
        "routePrefix": ""
    }
  }
}
EOF

cd data
cat << EOF > bitzec.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:28732
zmqpubhashblock=tcp://127.0.0.1:28732
rpcport=8732
rpcallowip=127.0.0.1
rpcuser=bitzec
rpcpassword=mybzcpassword
uacomment=bitcore
mempoolexpiry=24
rpcworkqueue=1100
maxmempool=2000
dbcache=1000
maxtxfee=1.0
dbmaxfilesize=64
showmetrics=1
addnode=bzcseed.raptorpool.org
EOF

cd ..
cd node_modules
git clone  https://github.com/bitzec/insight-api-bitzec
git clone  https://github.com/bitzec/insight-ui-bitzec
cd insight-api-bitzec
npm install
cd ..
cd insight-ui-bitzec
npm install
cd ..
cd ..

echo "Explorer is installed"
echo "Then to start explorer navigate to mynode folder and type ../bitcore-node start. Explorer will be accessible on localhost:3001" 
