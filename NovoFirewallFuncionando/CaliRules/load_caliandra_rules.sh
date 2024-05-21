#!/bin/bash

# Criar o diretório /etc/iptables se não existir
mkdir -p /etc/iptables

# Salvar as regras
if iptables-save > /etc/iptables/rules.v4; then
  echo "Regras do iptables salvas com sucesso em /etc/iptables/rules.v4"
else
  echo "Erro ao salvar as regras do iptables" >&2
  exit 1
fi

# Iniciar o serviço
exec "$@"
