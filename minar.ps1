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

$wallet = "sv1qqpf3v275snmfp29eezf5r0q4dprqzu7axydv8k7lpp6n5fy6lu9hggpqwfmtxum92s9acvy66dpwt7fxvk28ccd6ahwzx0zpnt65v27fjy7qqqqykqcpw"
$worker = Read-Host "💻 Nome do worker (Enter = rig1)"
if ([string]::IsNullOrWhiteSpace($worker)) { $worker = "rig1" }

$xmrig = "C:\projeto pedido delivery\xmrig-veil-bin\xmrig.exe"

if (-not (Test-Path $xmrig)) {
    Write-Host "❌ Erro: xmrig.exe não encontrado!" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "🚀 INICIANDO MINERAÇÃO..." -ForegroundColor Green
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

Write-Host "`n⛔ Minerador encerrado"
pause
