### Caliandra - 2.2 e 1.2 ###
1) iptables -P FORWARD ACCEPT - define a política padrão para aceitar todo o tráfego que está sendo encaminhado. Isso significa que, a menos que haja uma regra específica que bloqueie um determinado tipo de tráfego encaminhado, todo o tráfego encaminhado será permitido.

### CAIMAN - 2.3 e 3.2 ###
1) iptables -P INPUT ACCEPT - define a política padrão para aceitar todo o tráfego de entrada. Isso significa que, a menos que haja uma regra específica que bloqueie um determinado tipo de tráfego de entrada, todo o tráfego de entrada será permitido.
2) ip route add 192.168.1.0/24 via 192.168.2.2 dev eth0 - Adicionar a rota da rede .1.0/24

### PC Externo - 1.3 ###
Por algum motivo o docker-compose.yml não executa os dois comandos direito para esse contêiner
1) ip route del default
2) ip route add default via 192.168.1.2

### PC Interno - Teste ###
curl http://www.example.com
curl https://www.example.com

### PC Automação ###
Iniciar o SSH
