apt-get update
apt-get install -y iproute2 net-tools sudo ufw
ip route del default
ip route add default via 192.0.2.2
ufw default deny incoming
ufw default allow outgoing
chmod +rx /etc/ufw/before.rules
ufw enable
tail -f /dev/null