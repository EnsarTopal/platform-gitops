# proxy-cgr (cgr.dev) Kullanım Rehberi

## Durum: ✅ Tamamen çalışıyor

## Kullanım: Digest ile pull (tag yerine)

### Digest alma
```bash
curl -sk -I \
  -H "Authorization: Bearer $(curl -sk 'https://cgr.dev/token?scope=repository:chainguard/<IMAGE>:pull&service=cgr.dev' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("token",""))')" \
  -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  "https://cgr.dev/v2/chainguard/<IMAGE>/manifests/latest" | grep docker-content-digest
```

### Kubernetes'te kullanım
```yaml
image: harbor.lab.local/proxy-cgr/chainguard/busybox@sha256:<DIGEST>
```

### Test edildi (2026-03-10)
- harbor.lab.local/proxy-cgr/chainguard/busybox@sha256:369de07b03e7a837632f161f04d9e4fab42fd4ab07981802e7ca59af0b607842
- Kyverno uyumlu ✅ (digest tag politikasını bypass eder)
- Harbor credential: chainctl pull token ile güncellendi
