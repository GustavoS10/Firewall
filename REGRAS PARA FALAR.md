version: '3.8'

services:
  caliandra:
    image: ubuntu:latest
    container_name: caliandra_2.2_1.2
    privileged: true
    stdin_open: true
    tty: true
    dns:
      - 8.8.8.8
      - 4.4.4.4
    environment:
      - DEBIAN_FRONTEND=noninteractive
      - UFW_DEFAULT_INSTANCE=skip
    command: >
      /bin/bash -c "
      apt-get update && apt-get install -y iptables iproute2 traceroute ufw &&
      echo 1 > /proc/sys/net/ipv4/ip_forward &&
      iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
      iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT &&
      iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT &&
      iptables -A FORWARD -p tcp -d 192.168.2.6 -m multiport --dports 80,443 -j ACCEPT &&
      iptables -A FORWARD -p udp -d 192.168.2.4 --dport 53 -j ACCEPT &&
      iptables -A FORWARD -p tcp -d 192.168.2.0/24 -m multiport --dports 465,587,995,143,993 -j ACCEPT &&
      iptables -A FORWARD -p tcp -s 192.168.2.8 -d 192.168.2.7 --dport 5432 -j ACCEPT &&
      iptables -A FORWARD -d 192.168.2.7 -j DROP &&
      iptables -A FORWARD -s 192.168.3.0/24 -d 192.168.2.8 -j ACCEPT && 
      iptables -A FORWARD -d 192.168.2.8 -j DROP &&
      iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.2.0/24 -j ACCEPT &&
      iptables -A FORWARD -d 192.168.2.0/24 -j DROP &&
      iptables -P FORWARD ACCEPT &&
      tail -f /dev/null"
    networks:
      dmz_net:
        ipv4_address: 192.168.2.2
      external_net:
        ipv4_address: 192.168.1.2

  caiman:
    image: ubuntu:latest
    container_name: caiman_2.3_3.2
    depends_on:
      - caliandra
    privileged: true
    stdin_open: true
    tty: true
    environment:
      - DEBIAN_FRONTEND=noninteractive
      - UFW_DEFAULT_INSTANCE=skip
    command: >
      /bin/bash -c "
      apt-get update && apt-get install -y iptables iproute2 traceroute &&
      ip route del default || true &&
      ip route add default via 192.168.2.2 &&
      echo 1 > /proc/sys/net/ipv4/ip_forward &&
      iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
      iptables -A FORWARD -p tcp -s 192.168.3.0/24 -m multiport --dports 80,443 -j ACCEPT &&
      iptables -A FORWARD -p tcp -s 192.168.3.0/24 -m multiport --dports 465,587,995,143,993 -j ACCEPT &&
      iptables -A FORWARD -d 192.168.2.7 -j DROP &&
      iptables -A FORWARD -p tcp -d 192.168.3.0/24 -m multiport --dports 80,443 -j DROP &&
      iptables -A FORWARD -p udp -d 192.168.3.0/24 -m multiport --dports 80,443 -j DROP &&
      iptables -A FORWARD -s 192.168.3.0/24 -d 192.168.2.8 -j ACCEPT &&
      iptables -A FORWARD -d 192.168.2.8 -j DROP &&
      iptables -A FORWARD -s 192.168.3.0/24 -d 192.168.2.0/24 -j ACCEPT &&
      iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.3.0/24 -j ACCEPT &&
      iptables -A FORWARD -d 192.168.3.0/24 -j DROP &&
      iptables -P FORWARD ACCEPT &&
      tail -f /dev/null"
    networks:
      dmz_net:
        ipv4_address: 192.168.2.3
      internal_net:
        ipv4_address: 192.168.3.2

  pc_interno:
    image: ubuntu:latest
    container_name: pc_interno_3.3
    depends_on:
      - caliandra
      - caiman
    volumes:
      - ./servico.sh:/usr/local/bin/servico.sh
      - ./cliente.sh:/usr/local/bin/cliente.sh
    privileged: true
    networks:
      internal_net:
        ipv4_address: 192.168.3.3
    command: >
      /bin/bash -c "
      apt update &&
      apt install -y iproute2 traceroute openssh-server telnet netcat-openbsd &&
      mkdir /var/run/sshd &&
      echo 'root:password' | chpasswd &&
      sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config &&
      sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config &&
      service ssh start &&
      ip route del default && 
      ip route add default via 192.168.3.2 &&
      chmod +x /usr/local/bin/servico.sh &&
      chmod +x /usr/local/bin/cliente.sh &&
      tail -f /dev/null"

  pc_externo:
    build:
      context: .
      dockerfile: Dockerfile.externo
    container_name: pc_externo_1.3
    depends_on:
      - caliandra
      - caiman
    privileged: true
    command: > 
      /bin/bash -c " 
      ip route del default || true && 
      ip route add default via 192.168.1.2 && 
      tail -f /dev/null"
    networks:
      external_net:
        ipv4_address: 192.168.1.3

  pc_automacao:
    build:
      context: .
      dockerfile: Dockerfile.automacao
    container_name: pc_automacao_3.4
    privileged: true
    volumes:
      - ./ansible:/etc/ansible
    command: >
      /bin/bash -c "
      ip route del default || true &&
      ip route add default via 192.168.3.2 &&
      tail -f /dev/null"
    networks:
      internal_net:
        ipv4_address: 192.168.3.4
      dmz_net:
        ipv4_address: 192.168.2.10

  dns:
    build:
      context: .
      dockerfile: Dockerfile.servidor
    container_name: dns_server_2.4
    privileged: true
    networks:
      dmz_net:
        ipv4_address: 192.168.2.4

  ad:
    build:
      context: .
      dockerfile: Dockerfile.servidor
    container_name: ad_server_2.5
    privileged: true
    networks:
      dmz_net:
        ipv4_address: 192.168.2.5

  web:
    build:
      context: .
      dockerfile: Dockerfile.servidor
    container_name: web_server_2.6
    privileged: true
    networks:
      dmz_net:
        ipv4_address: 192.168.2.6

  bd:
    build:
      context: .
      dockerfile: Dockerfile.servidor
    container_name: bd_server_2.7
    privileged: true
    networks:
      dmz_net:
        ipv4_address: 192.168.2.7

  app:
    build:
      context: .
      dockerfile: Dockerfile.servidor
    container_name: app_server_2.8
    privileged: true
    networks:
      dmz_net:
        ipv4_address: 192.168.2.8

  arquivos:
    build:
      context: .
      dockerfile: Dockerfile.servidor
    container_name: arquivos_server_2.9
    privileged: true
    networks:
      dmz_net:
        ipv4_address: 192.168.2.9

networks:
  external_net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.1.0/24
  dmz_net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.2.0/24
  internal_net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.3.0/24
