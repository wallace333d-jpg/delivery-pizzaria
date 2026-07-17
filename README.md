# Minerador Veil (VEIL) — RandomX

Minerador para Veil usando algoritmo RandomX-Veil, conectando ao pool **FastPool.xyz**.

## ⚡ Requisitos

- **Windows 10/11** com Visual Studio 2022
- **Node.js** v18+ (opcional, só para o setup)
- **Git** para Windows

## 📦 Instalação Passo a Passo

### 1. Instalar Visual Studio 2022

Baixe em: https://visualstudio.microsoft.com/vs/community/

Durante a instalação, selecione o workload:
- **"Desenvolvimento para desktop com C++"**

### 2. Instalar Git

Baixe em: https://git-scm.com/download/win

### 3. Instalar CMake

Baixe em: https://cmake.org/download/ (CMake x64 Installer)

### 4. Clonar e compilar xmrig-veil

Abra **"Command Prompt for VS 2022 (x64)"** do menu Iniciar e execute:

```cmd
cd C:\projeto pedido delivery
git clone https://github.com/ohcee/xmrig-veil.git
cd xmrig-veil
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

### 5. Minerar

```cmd
cd C:\projeto pedido delivery
node miner.js
```

Digite sua wallet Veil e o nome do worker.

## 🔧 Comando manual (sem Node.js)

```cmd
xmrig-veil\build\Release\xmrig.exe ^
  -o fastpool.xyz:10282 ^
  -u SUA_WALLET_AQUI ^
  -p x ^
  --algo rx/veil ^
  --worker-name rig1 ^
  --tls=false
```

## 🌐 Pool FastPool

| Item | Valor |
|------|-------|
| URL | fastpool.xyz |
| Porta (mid-end) | 10282 |
| Porta (low-end) | 10281 |
| Algoritmo | rx/veil |
| Senha | x |

## 📊 Estatísticas

Acompanhe seus workers em:
https://fastpool.xyz/veil-rx/
