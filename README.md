# Minerador Veil (VEIL) — RandomX

Minerador para Veil usando algoritmo RandomX-Veil no pool **FastPool.xyz**.

## ✅ Como minerar (já está pronto!)

Abra o **PowerShell** como administrador e execute:

```powershell
C:\projeto pedido delivery\miner.ps1
```

Digite sua **wallet Veil** e o **nome do worker**. Pronto, já começa a minerar!

## 🔧 Comando manual

```cmd
C:\projeto pedido delivery\xmrig-veil-bin\xmrig.exe ^
  -o fastpool.xyz:10282 ^
  -u SUA_WALLET_AQUI ^
  -p x ^
  --algo rx/veil ^
  --worker-name rig1
```

## 🌐 Pool FastPool

| Item | Valor |
|------|-------|
| URL | fastpool.xyz |
| Porta (mid-end) | 10282 |
| Porta (low-end) | 10281 |
| Algoritmo | rx/veil |
| Senha | x |

## 📊 Acompanhar estatísticas

https://fastpool.xyz/veil-rx/
