curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz && \
rm go1.24.3.linux-amd64.tar.gz && \
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && \
source ~/.bashrc
/usr/local/go/bin/go version

git clone https://github.com/0glabs/0g-storage-node.git
cd 0g-storage-node
PRIVATE=$(cat og_private.txt)
git checkout v1.0.0 && git submodule update --init
cargo build --release
rm -rf $HOME/0g-storage-node/run/config.toml
cd run
wget -O config.toml https://raw.githubusercontent.com/muckduchok/OG/main/config.toml
chmod +x config.toml
sed -i "s|^miner_key[[:space:]]*=.*|miner_key = \"${PRIVATE}\"|" config.toml

sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml

Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
