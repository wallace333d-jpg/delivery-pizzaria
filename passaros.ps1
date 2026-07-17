#requires -version 5.1

$script:CONFIG_PATH = Join-Path $PSScriptRoot "data\config.json"
$script:AUDIOS_DIR = Join-Path $PSScriptRoot "audios"
$script:config = @{ horarios = @(); ativo = $false }
$script:tocando = $null
$script:processo = $null

if (!(Test-Path $AUDIOS_DIR)) { New-Item -ItemType Directory -Path $AUDIOS_DIR -Force | Out-Null }
if (!(Test-Path (Split-Path $CONFIG_PATH -Parent))) { New-Item -ItemType Directory -Path (Split-Path $CONFIG_PATH -Parent) -Force | Out-Null }

function CarregarConfig {
  if (Test-Path $CONFIG_PATH) {
    try { $script:config = Get-Content $CONFIG_PATH -Raw | ConvertFrom-Json; if (!$script:config.horarios) { $script:config.horarios = @() } }
    catch { $script:config = @{ horarios = @(); ativo = $false } }
  }
}

function SalvarConfig {
  $script:config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_PATH -Force
}

function ListarArquivos {
  if (!(Test-Path $AUDIOS_DIR)) { return @() }
  return Get-ChildItem $AUDIOS_DIR -File | Where-Object { $_.Extension -match '\.(mp3|wav|ogg|m4a|flac|mp4|avi|mkv|mov|wmv|flv|webm)$' } | ForEach-Object { $_.Name }
}

function MostrarMenu {
  Clear-Host
  $arquivos = ListarArquivos
  Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
  Write-Host "      🐦 ENCANTADOR DE PÁSSAROS" -ForegroundColor Green
  Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "📁 Arquivos disponíveis ($($arquivos.Count)):" -ForegroundColor Yellow
  if ($arquivos.Count -eq 0) {
    Write-Host "   Nenhum. Coloque arquivos na pasta 'audios'." -ForegroundColor DarkGray
  } else {
    $arquivos | ForEach-Object { Write-Host "   [$(($arquivos.IndexOf($_)+1))] $_" }
  }
  Write-Host ""
  
  if ($script:config.ativo) {
    Write-Host "✅ SISTEMA: ATIVO" -ForegroundColor Green
  } else {
    Write-Host "⏸️  SISTEMA: PAUSADO" -ForegroundColor Red
  }
  
  if ($script:tocando) {
    Write-Host "🔊 Tocando agora: $($script:tocando)" -ForegroundColor Cyan
  }
  
  Write-Host ""
  Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
  Write-Host "  1 - Listar horários" -ForegroundColor White
  Write-Host "  2 - Adicionar horário" -ForegroundColor White
  Write-Host "  3 - Remover horário" -ForegroundColor White
  Write-Host "  4 - Ligar / Desligar sistema" -ForegroundColor White
  Write-Host "  5 - Testar arquivo" -ForegroundColor White
  Write-Host "  6 - Parar reprodução agora" -ForegroundColor White
  Write-Host "  0 - Iniciar monitoramento (modo agendado)" -ForegroundColor Green
  Write-Host "  S - Sair" -ForegroundColor Red
  Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
}

function ListarHorarios {
  Clear-Host
  Write-Host "⏰ HORÁRIOS CONFIGURADOS" -ForegroundColor Yellow
  Write-Host ""
  if ($script:config.horarios.Count -eq 0) {
    Write-Host "Nenhum horário configurado." -ForegroundColor DarkGray
  } else {
    $i = 1
    foreach ($h in $script:config.horarios) {
      $dias = @('Dom','Seg','Ter','Qua','Qui','Sex','Sab')
      $diasSel = if ($h.dias) { ($dias | Where-Object { [array]$h.dias -contains $dias.IndexOf($_) }).ForEach({ $dias[$_] }) -join ' ' } else { 'todos' }
      Write-Host "[$i] $($h.inicio) → $($h.fim) | $($h.arquivo) | Dias: $diasSel" -ForegroundColor White
      $i++
    }
  }
  Write-Host ""
  pause
}

function AdicionarHorario {
  Clear-Host
  Write-Host "➕ NOVO HORÁRIO" -ForegroundColor Yellow
  Write-Host ""
  $inicio = Read-Host "Horário de início (HH:MM)"
  if (!$inicio) { return }
  $fim = Read-Host "Horário de fim (HH:MM)"
  if (!$fim) { return }
  
  $arquivos = ListarArquivos
  if ($arquivos.Count -eq 0) {
    Write-Host "❌ Nenhum arquivo disponível. Coloque arquivos na pasta 'audios'." -ForegroundColor Red
    pause; return
  }
  Write-Host ""
  Write-Host "Arquivos disponíveis:" -ForegroundColor Yellow
  $i = 1; $arquivos | ForEach-Object { Write-Host "  [$i] $_"; $i++ }
  $sel = Read-Host "Escolha o número do arquivo"
  $idxArquivo = [int]$sel - 1
  if ($idxArquivo -lt 0 -or $idxArquivo -ge $arquivos.Count) { Write-Host "Inválido"; pause; return }
  
  Write-Host ""
  Write-Host "Dias da semana (ex: 0-6 ou deixe vazio para todos):" -ForegroundColor Yellow
  Write-Host "  0=Dom 1=Seg 2=Ter 3=Qua 4=Qui 5=Sex 6=Sab"
  $diasInput = Read-Host "Dias (ex: 1,2,3,4,5 para dias úteis)"
  $dias = if ($diasInput.Trim() -eq '') { @(0,1,2,3,4,5,6) } else { $diasInput -split ',' | ForEach-Object { [int]$_.Trim() } }
  
  $script:config.horarios += @{
    inicio = $inicio
    fim = $fim
    arquivo = $arquivos[$idxArquivo]
    ativo = $true
    dias = $dias
  }
  SalvarConfig
  Write-Host "✅ Horário adicionado!" -ForegroundColor Green
  pause
}

function RemoverHorario {
  Clear-Host
  if ($script:config.horarios.Count -eq 0) { Write-Host "Nenhum horário."; pause; return }
  Write-Host "🗑️  REMOVER HORÁRIO" -ForegroundColor Yellow
  Write-Host ""
  $i = 1; foreach ($h in $script:config.horarios) { Write-Host "  [$i] $($h.inicio) → $($h.fim) | $($h.arquivo)"; $i++ }
  $sel = Read-Host "Número para remover (Enter para cancelar)"
  if (!$sel) { return }
  $idx = [int]$sel - 1
  if ($idx -ge 0 -and $idx -lt $script:config.horarios.Count) {
    $script:config.horarios = $script:config.horarios | Where-Object { $script:config.horarios.IndexOf($_) -ne $idx }
    SalvarConfig
    Write-Host "✅ Removido!" -ForegroundColor Green
  }
  pause
}

function ToggleSistema {
  $script:config.ativo = !$script:config.ativo
  if (!$script:config.ativo) { PararReproducao }
  SalvarConfig
  Write-Host $("Sistema " + $(if ($script:config.ativo) { "ativado" } else { "desativado" })) -ForegroundColor Green
  Start-Sleep 1
}

function TestarArquivo {
  Clear-Host
  $arquivos = ListarArquivos
  if ($arquivos.Count -eq 0) { Write-Host "Nenhum arquivo." -ForegroundColor Red; pause; return }
  Write-Host "▶️  TESTAR ARQUIVO" -ForegroundColor Yellow
  Write-Host ""
  $i = 1; $arquivos | ForEach-Object { Write-Host "  [$i] $_"; $i++ }
  $sel = Read-Host "Número do arquivo (Enter para cancelar)"
  if (!$sel) { return }
  $idx = [int]$sel - 1
  if ($idx -ge 0 -and $idx -lt $arquivos.Count) {
    PararReproducao
    $caminho = Join-Path $AUDIOS_DIR $arquivos[$idx]
    Write-Host "▶️ Tocando $($arquivos[$idx]) por 10 segundos..." -ForegroundColor Cyan
    $ext = [System.IO.Path]::GetExtension($arquivos[$idx]).ToLower()
    if ($ext -eq '.wav') {
      $player = New-Object System.Media.SoundPlayer($caminho)
      $player.PlayLoop()
      Start-Sleep 10
      $player.Stop()
    } else {
      $wm = New-Object -ComObject WMPlayer.OCX
      $wm.URL = $caminho
      $wm.controls.play()
      Start-Sleep 10
      $wm.controls.stop()
      [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wm) | Out-Null
    }
    Write-Host "⏹️  Teste encerrado" -ForegroundColor Yellow
  }
  pause
}

function PararReproducao {
  if ($script:processo -and !$script:processo.HasExited) {
    try { $script:processo.Kill() } catch {}
  }
  try { Get-Process | Where-Object { $_.ProcessName -eq 'wmplayer' } | Stop-Process -Force } catch {}
  try { [System.Media.SoundPlayer]::new().Stop() } catch {}
  $script:tocando = $null
}

function TocarArquivoLoop($arquivo) {
  PararReproducao
  $caminho = Join-Path $AUDIOS_DIR $arquivo
  if (!(Test-Path $caminho)) { return }
  $ext = [System.IO.Path]::GetExtension($arquivo).ToLower()
  
  if ($ext -eq '.wav') {
    $script:processo = Start-Process -WindowStyle Hidden -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -Command `$player = New-Object System.Media.SoundPlayer('$caminho'); `$player.PlayLoop(); Start-Sleep 99999" -PassThru
  } else {
    $script:processo = Start-Process -WindowStyle Hidden -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -Command `$wm = New-Object -ComObject WMPlayer.OCX; `$wm.URL = '$caminho'; `$wm.settings.setMode('loop', `$true); `$wm.controls.play(); Start-Sleep 99999" -PassThru
  }
  $script:tocando = $arquivo
}

function VerificarAgenda {
  while ($true) {
    $agora = Get-Date
    $horaMin = $agora.ToString("HH:mm")
    $diaSemana = [int]$agora.DayOfWeek
    
    $deveTocar = $null
    if ($script:config.ativo) {
      foreach ($h in $script:config.horarios) {
        if (!$h.ativo) { continue }
        $dias = if ($h.dias) { $h.dias } else { @(0,1,2,3,4,5,6) }
        if ($diaSemana -notin $dias) { continue }
        if ($horaMin -ge $h.inicio -and $horaMin -lt $h.fim) {
          $deveTocar = $h.arquivo
          break
        }
      }
    }
    
    if ($deveTocar -and $deveTocar -ne $script:tocando) {
      Write-Host "$(Get-Date -Format 'HH:mm:ss') 🔊 Iniciando: $deveTocar" -ForegroundColor Cyan
      TocarArquivoLoop $deveTocar
    } elseif (!$deveTocar -and $script:tocando) {
      Write-Host "$(Get-Date -Format 'HH:mm:ss') ⏹️  Parando: $($script:tocando)" -ForegroundColor Yellow
      PararReproducao
    }
    
    Start-Sleep 30
  }
}

Clear-Host
CarregarConfig

Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "      🐦 ENCANTADOR DE PÁSSAROS" -ForegroundColor Green
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Coloque seus arquivos de áudio/vídeo em:" -ForegroundColor Yellow
Write-Host "   $AUDIOS_DIR" -ForegroundColor White
Write-Host ""

if ((ListarArquivos).Count -eq 0) {
  Write-Host "⚠️  NENHUM ARQUIVO ENCONTRADO!" -ForegroundColor Red
  Write-Host "   Coloque arquivos .mp3, .wav, .mp4, .avi etc. na pasta 'audios'." -ForegroundColor DarkGray
  Write-Host ""
}

while ($true) {
  MostrarMenu
  $opcao = Read-Host "`nOpção"
  
  switch ($opcao) {
    '1' { ListarHorarios }
    '2' { AdicionarHorario }
    '3' { RemoverHorario }
    '4' { ToggleSistema }
    '5' { TestarArquivo }
    '6' { PararReproducao; Write-Host "⏹️  Parado"; Start-Sleep 1 }
    '0' { 
      Clear-Host
      Write-Host "🚀 INICIANDO MONITORAMENTO..." -ForegroundColor Green
      Write-Host "Pressione CTRL+C para voltar ao menu." -ForegroundColor Cyan
      Write-Host ""
      if ($script:config.ativo -and $script:config.horarios.Count -gt 0) {
        Write-Host "$($script:config.horarios.Count) horário(s) configurado(s)" -ForegroundColor Yellow
      } else {
        Write-Host "⚠️  Sistema inativo ou sem horários. Ative pelo menu (opção 4)." -ForegroundColor Red
      }
      Write-Host "──────────────────────────────────────" -ForegroundColor DarkGray
      try { VerificarAgenda } catch { }
      break
    }
    's' { 
      PararReproducao
      Write-Host "Saindo..." -ForegroundColor Yellow
      exit 
    }
    'S' { 
      PararReproducao
      Write-Host "Saindo..." -ForegroundColor Yellow
      exit 
    }
  }
}
