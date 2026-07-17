# 🐦 Encantador de Pássaros

Reproduz áudios e vídeos agendados para atrair pássaros.

## ✅ Como usar

1. Coloque seus arquivos (MP3, WAV, MP4, AVI...) na pasta `audios/`
2. Dê dois cliques em **`passaros.bat`** (ou execute `passaros.ps1` no PowerShell)
3. Use o menu para adicionar horários e ativar o sistema

## 📁 Estrutura

```
C:\projeto pedido delivery\
├── passaros.ps1      → Script principal (menu interativo)
├── passaros.bat      → Atalho para executar
├── audios\           → Coloque seus arquivos aqui
│   └── .gitkeep
├── data\             → Configuração salva automaticamente
│   └── config.json
└── README.md
```

## ⏰ Como configurar horários

Pelo menu:
- **2** → Adicionar horário (início, fim, arquivo, dias)
- **0** → Iniciar monitoramento (fica verificando a cada 30s)
- **4** → Liga/Desliga o sistema

O arquivo toca em loop contínuo do início até o fim do horário.
