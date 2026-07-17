const { spawn, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const https = require('https');

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

console.log(`
██╗   ██╗███████╗██╗██╗     ██████╗ ██╗   ██╗██╗  ██╗
██║   ██║██╔════╝██║██║     ██╔══██╗╚██╗ ██╔╝██║  ██║
██║   ██║█████╗  ██║██║     ██████╔╝ ╚████╔╝ ███████║
╚██╗ ██╔╝██╔══╝  ██║██║     ██╔══██╗  ╚██╔╝  ██╔══██║
 ╚████╔╝ ███████╗██║███████╗██║  ██║   ██║   ██║  ██║
  ╚═══╝  ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
═══════════════════════════════════════════════════════
         Minerador Veil (VEIL) — RandomX
         Pool: FastPool.xyz
═══════════════════════════════════════════════════════\n`);

function perguntar() {
  rl.question('👛 Endereço da wallet Veil: ', (wallet) => {
    if (!wallet.trim()) { console.log('❌ Wallet obrigatória!\n'); perguntar(); return; }
    rl.question('💻 Nome do worker [rig1]: ', (worker) => {
      rl.close();
      const cfg = {
        wallet: wallet.trim(),
        worker: worker.trim() || 'rig1',
        host: 'fastpool.xyz',
        port: '10282',
        pass: 'x'
      };
      salvarConfig(cfg);
      verificarXmrig(cfg);
    });
  });
}

function salvarConfig(cfg) {
  fs.writeFileSync('config.json', JSON.stringify(cfg, null, 2));
  console.log('✅ Configuração salva em config.json\n');
}

function verificarXmrig(cfg) {
  const xmrigPath = path.join(__dirname, 'xmrig-veil', 'xmrig.exe');
  if (fs.existsSync(xmrigPath)) {
    console.log('✅ xmrig-veil encontrado!\n');
    iniciarMineracao(cfg, path.join(__dirname, 'xmrig-veil'));
    return;
  }
  console.log('⚠️  xmrig-veil não encontrado.\n');
  console.log('══════════════════════════════════════════');
  console.log('  PASSO A PASSO PARA INSTALAR');
  console.log('══════════════════════════════════════════\n');
  console.log('1. Baixe o Visual Studio 2022 Community:');
  console.log('   https://visualstudio.microsoft.com/vs/community/\n');
  console.log('   Durante instalação, selecione:');
  console.log('   • "Desenvolvimento para desktop com C++"\n');
  console.log('2. Baixe o Git for Windows:');
  console.log('   https://git-scm.com/download/win\n');
  console.log('3. Abra "Command Prompt for VS 2022" (x64)');
  console.log('   no menu Iniciar e execute:\n');
  console.log('   cd C:\\projeto pedido delivery');
  console.log('   git clone https://github.com/ohcee/xmrig-veil.git');
  console.log('   cd xmrig-veil');
  console.log('   mkdir build && cd build');
  console.log('   cmake .. -G "Visual Studio 17 2022" -A x64');
  console.log('   cmake --build . --config Release\n');
  console.log('4. Após compilar, execute este script novamente.\n');
  console.log('══════════════════════════════════════════\n');
  console.log('📄 Configuração salva em config.json');
  console.log('   Para usar com xmrig manualmente:\n');
  console.log('   xmrig.exe -o fastpool.xyz:10282 \\');
  console.log('           -u ' + cfg.wallet + ' \\');
  console.log('           -p x \\');
  console.log('           --tls=false \\');
  console.log('           --algo=rx/veil \\');
  console.log('           --worker-name=' + cfg.worker + '\n');
}

function iniciarMineracao(cfg, dir) {
  const cmd = `xmrig.exe`;
  const args = [
    '-o', `${cfg.host}:${cfg.port}`,
    '-u', cfg.wallet,
    '-p', cfg.pass,
    '--algo', 'rx/veil',
    '--worker-name', cfg.worker,
    '--tls=false',
    '--print-time=5',
    '--donate-level=1'
  ];

  console.log('🚀 Iniciando mineração...\n');
  console.log(`🌐 Pool: ${cfg.host}:${cfg.port}`);
  console.log(`👛 Wallet: ${cfg.wallet}`);
  console.log(`💻 Worker: ${cfg.worker}\n`);

  const miner = spawn(cmd, args, {
    cwd: dir,
    stdio: 'inherit',
    shell: true
  });

  miner.on('close', (code) => {
    console.log(`\n⛔ Minerador encerrado (código: ${code})`);
    process.exit(code);
  });

  process.on('SIGINT', () => {
    console.log('\n🛑 Encerrando minerador...');
    miner.kill('SIGINT');
  });
}

perguntar();
