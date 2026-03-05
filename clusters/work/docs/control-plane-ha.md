# Control Plane HA

## Topoloji
- VIP: 10.25.25.13 (keepalived VRRP)
- k8s-cp1: 10.25.25.14 (MASTER, priority 101)
- k8s-cp2: 10.25.25.18 (BACKUP, priority 100)
- k8s-w1:  10.25.25.15
- k8s-w2:  10.25.25.16
- k8s-w3:  10.25.25.17

## Bileşenler
- keepalived: VRRP ile VIP yönetimi (virtual_router_id: 51)
- haproxy: API server load balancing (:6443 → cp1:6443, cp2:6443)

## Failover
cp1 down → VIP otomatik cp2'ye geçer (~2sn)
Tüm worker kubelet.conf: https://10.25.25.13:6443

## etcd
Stacked etcd — 2 member cluster
- https://10.25.25.14:2379 (cp1)
- https://10.25.25.18:2379 (cp2)

## Notlar
- API server SAN: 10.25.25.13, 10.25.25.14, 10.25.25.18, k8s-cp1, k8s-cp2
- controlPlaneEndpoint: 10.25.25.13:6443
