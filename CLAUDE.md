# GitOps Platform - Claude Code Agent Guide

Bu dosya Claude Code'un `EnsarTopal/platform-gitops` reposunda otonom çalışması için talimatları içerir.

## Proje Özeti

Local Kubernetes cluster üzerinde ArgoCD tabanlı GitOps platformu. Tüm yönetim terminalden `kubectl` ve `argocd` CLI ile yapılır.

## Araçlar & Erişim

| Araç | Kullanım |
|------|----------|
| `kubectl` | Cluster kaynak yönetimi |
| `argocd` | ArgoCD app yönetimi |
| `helm` | Chart yönetimi |
| `git` | Repo işlemleri |

## Temel Komutlar

### Cluster Durumu Kontrolü
```bash
# Node sağlığı
kubectl get nodes -o wide

# Tüm namespace'ler
kubectl get namespaces

# ArgoCD pod durumu
kubectl get pods -n argocd

# Tüm ArgoCD uygulamaları
argocd app list

# Detaylı uygulama durumu
argocd app get <APP_NAME>
```

### Senkronizasyon
```bash
# Manuel sync
argocd app sync <APP_NAME>

# Sync ve bekle
argocd app sync <APP_NAME> --timeout 120

# Tüm app'leri sync et
argocd app list -o name | xargs -I{} argocd app sync {}
```

### Sorun Tespiti
```bash
# Hatalı pod'lar
kubectl get pods -A | grep -v Running | grep -v Completed

# Pod logları
kubectl logs <POD_NAME> -n <NAMESPACE> --tail=50

# ArgoCD uygulama olayları
argocd app get <APP_NAME> --show-operation

# Sync hatası detayı
kubectl describe application <APP_NAME> -n argocd
```

### Harbor Registry
```bash
# Image pull secret kontrolü
kubectl get secrets -A | grep harbor

# Registry erişim testi
curl -u admin:<PASSWORD> https://harbor.local/api/v2.0/projects
```

## Görev Örnekleri

Kullanıcı şunları isteyebilir — direkt yap, onay bekleme:

- **"cluster'ı kontrol et"** → `kubectl get nodes` + `argocd app list` + hatalı pod raporu
- **"sync et"** → belirtilen ya da tüm OutOfSync app'leri sync et
- **"logları getir"** → ilgili pod loglarını getir ve analiz et
- **"uygulama durumu"** → `argocd app get` ile detaylı rapor
- **"yeni app ekle"** → ArgoCD Application manifest yaz ve apply et
- **"image güncelle"** → values.yaml'daki image tag'ini güncelle, commit, push

## Rapor Formatı

Cluster kontrolü sonrası şu formatta rapor ver:

```
## Cluster Durum Raporu

### Nodes (X/X Ready)
- node-1: Ready ✅
- node-2: Ready ✅

### ArgoCD Uygulamaları
| App | Sync | Health | Repo |
|-----|------|--------|------|
| app-name | Synced ✅ | Healthy ✅ | ... |

### Dikkat Gerektiren Durumlar
- ⚠️  app-x: OutOfSync - son commit: abc123
- ❌  pod-y: CrashLoopBackOff - namespace: prod

### Önerilen Aksiyonlar
1. ...
```

## Kurallar

1. **Her zaman önce mevcut durumu kontrol et**, sonra aksiyon al
2. **Destructive işlemler** (delete, force sync) için kullanıcıdan onay al
3. **Hata durumunda** logları getir ve root cause analiz et
4. **Git commit** yapmadan önce diff göster
5. **Production namespace** için ekstra dikkatli ol (mevcut değil ama ileride olabilir)

## Proje Yapısı

```
platform-gitops/
├── apps/               # ArgoCD Application manifestleri
├── charts/             # Helm chartları
├── scripts/            # Shell scriptler
├── ai_gitops.py        # AI destekli GitOps CLI (Gemini)
└── CLAUDE.md           # Bu dosya
```

## Sık Karşılaşılan Sorunlar

### OutOfSync ama sync etmiyor
```bash
argocd app sync <APP> --force
argocd app sync <APP> --replace
```

### ImagePullBackOff
```bash
# Secret kontrol
kubectl get secret -n <NS> | grep harbor
# Manuel pull test
kubectl run test --image=<IMAGE> --restart=Never -n <NS>
```

### ArgoCD UI'a erişim (gerekirse)
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Tarayıcı: https://localhost:8080
```

### Admin şifre al
```bash
argocd admin initial-password -n argocd
```
