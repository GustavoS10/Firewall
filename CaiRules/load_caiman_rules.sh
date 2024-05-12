# Salvar as regras
iptables-save > /etc/iptables/rules.v4

# Iniciar o serviço
exec "$@"