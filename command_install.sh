apt-get update 
apt-get install -y iproute2 net-tools sudo 
ip route del default
ip route add default via 192.0.3.2 
echo 'Hello from Work' 
tail -f /dev/null