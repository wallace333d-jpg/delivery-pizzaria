Clear-Host
Write-Host ""
Write-Host "██████╗ ███████╗██╗██╗     ██████╗  ██████╗ ██╗  ██╗"
Write-Host "██╔══██╗██╔════╝██║██║     ██╔══██╗██╔═══██╗██║ ██╔╝"
Write-Host "██║  ██║█████╗  ██║██║     ██████╔╝██║   ██║█████╔╝ "
Write-Host "██║  ██║██╔══╝  ██║██║     ██╔══██╗██║   ██║██╔═██╗ "
Write-Host "██████╔╝███████╗██║███████╗██║  ██║╚██████╔╝██║  ██╗"
Write-Host "╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝"
Write-Host "═══════════════════════════════════════════════════════"
Write-Host "        Minerador Veil (VEIL) - RandomX"
Write-Host "        Pool: fastpool.xyz"
Write-Host "═══════════════════════════════════════════════════════"
Write-Host ""

$wallet = Read-Host "👛 Digite sua wallet Veil"
if ([string]::IsNullOrWhiteSpace($wallet)) {
    Write-Host "❌ Wallet obrigatória!" -ForegroundColor Red
    exit 1
}

$worker = Read-Host "💻 Nome do worker (Enter = rig1)"
if ([string]::IsNullOrWhiteSpace($worker)) { $worker = "rig1" }

$xmrig = "C:\projeto pedido delivery\xmrig-veil-bin\xmrig.exe"

if (-not (Test-Path $xmrig)) {
    Write-Host "❌ xmrig.exe não encontrado em $xmrig" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "🚀 Iniciando mineração..." -ForegroundColor Green
Write-Host "🌐 Pool: fastpool.xyz:10282"
Write-Host "👛 Wallet: $wallet"
Write-Host "💻 Worker: $worker"
Write-Host "⚙️  Algoritmo: rx/veil"
Write-Host ""
Write-Host "============================================"
Write-Host "  Pressione CTRL+C para encerrar"
Write-Host "============================================"
Write-Host ""

& $xmrig -o fastpool.xyz:10282 `
       -u $wallet `
       -p x `
       --algo rx/veil `
       --worker-name $worker `
       --tls=false `
       --print-time=5 `
       --donate-level=1

Write-Host ""
Write-Host "⛔ Minerador encerrado" -ForegroundColor Yellow
pause
