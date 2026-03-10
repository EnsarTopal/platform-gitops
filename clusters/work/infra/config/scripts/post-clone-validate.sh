#!/bin/bash
# Proxmox'ta VM klonlandıktan sonra YENİ VM'de çalıştır
# Kullanım: sudo bash /opt/scripts/post-clone-validate.sh <yeni-ip> <hostname>

set -euo pipefail
NEW_IP="${1:?Kullanım: $0 <yeni-ip> <hostname>}"
NEW_HOSTNAME="${2:?Kullanım: $0 <yeni-ip> <hostname>}"

echo "=== [1/5] Mevcut IP adresleri ==="
ip addr show ens18 | grep inet
echo "Beklenen TEK IP: $NEW_IP"
ACTUAL_IPS=$(ip addr show ens18 | grep "inet " | awk '{print $2}' | wc -l)
if [ "$ACTUAL_IPS" -gt 1 ]; then
    echo "⚠️  UYARI: $ACTUAL_IPS IP adresi var! Cloud-init duplikasyonu olabilir."
fi

echo ""
echo "=== [2/5] Netplan kontrolü ==="
grep -r "addresses" /etc/netplan/ | grep -v "^#"

echo ""
echo "=== [3/5] Cloud-init devre dışı mı? ==="
if [ -f /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg ]; then
    echo "✅ Cloud-init network config disabled"
else
    echo "⚠️  Cloud-init AKTIF — devre dışı bırakılıyor..."
    echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
fi

echo ""
echo "=== [4/5] Hostname kontrolü ==="
current_hostname=$(hostname)
if [ "$current_hostname" != "$NEW_HOSTNAME" ]; then
    echo "⚠️  Hostname: $current_hostname → $NEW_HOSTNAME güncelleniyor"
    hostnamectl set-hostname "$NEW_HOSTNAME"
    sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
    echo "✅ Hostname güncellendi"
else
    echo "✅ Hostname doğru: $current_hostname"
fi

echo ""
echo "=== [5/5] /etc/hosts kontrolü ==="
grep "127.0.1.1" /etc/hosts

echo ""
echo "=============================="
echo "         ÖZET"
echo "=============================="
echo "IP       : $(ip addr show ens18 | grep 'inet ' | awk '{print $2}' | tr '\n' ' ')"
echo "Hostname : $(hostname)"
echo "Cloud-init: $(cat /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg 2>/dev/null || echo 'NOT DISABLED ⚠️')"
echo ""
if ip addr show ens18 | grep -q "$NEW_IP"; then
    echo "✅ IP doğrulandı"
else
    echo "❌ IP eşleşmiyor! Netplan'ı kontrol et: /etc/netplan/"
fi
