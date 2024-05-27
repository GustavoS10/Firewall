echo 1 > /proc/sys/net/ipv4/ip_forward &&
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT &&
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT &&
ufw default allow outgoing &&
ufw allow in on eth0 from 192.168.2.2 to any port 80,443 proto tcp &&
ufw allow in on eth0 from 192.168.2.2 to any port 53 proto udp &&
ufw allow in on eth0 from 192.168.2.2 to any port 465,587,995,143,993 proto tcp &&
ufw allow in on eth0 from 192.168.2.3 &&
ufw deny in on eth0 &&
ufw allow in on eth0 from 192.168.2.3 to any port 80,443 proto tcp &&
ufw allow in on eth0 from 192.168.2.3 to any port 53 proto udp &&
ufw allow out on eth0 to any port 53 proto udp &&
ufw allow in on eth0 from 192.168.2.3 to any port 465,587,995,143,993 proto tcp &&
ufw deny in on eth0 to any port 5432 proto tcp &&
ufw allow in on eth0 from 192.168.3.3 &&
ufw logging on &&
ufw enable &&