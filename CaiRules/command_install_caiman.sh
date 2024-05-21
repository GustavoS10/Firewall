apt-get update &&
apt-get install -y iproute2 iptables net-tools sudo ufw curl traceroute iputils-ping &&
ip route del default || true &&
ip route add default via 192.0.2.2 &&
chmod +rx /etc/ufw/before.rules &&
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
ufw enable &&
tail -f /dev/null &&