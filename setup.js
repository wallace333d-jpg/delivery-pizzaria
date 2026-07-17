const fs = require('fs');
const path = require('path');
const https = require('https');
const { spawn } = require('child_process');

console.log(`
══════════════════════════════════════════
  SETUP — Minerador Veil (RX/Veil)
  FastPool.xyz
══════════════════════════════════════════\n`);

console.log('Este script prepara o ambiente de mineração.\n');

function checkTools() {
  console.log('🔍 Verificando ferramentas...\n');

  try {
    const gitVer = require('child_process').execSync('git --version', { encoding: 'utf8' }).trim();
    console.log(`✅ Git: ${gitVer}`);
  } catch {
    console.log('❌ Git não encontrado. Baixe em: https://git-scm.com/download/win');
  }

  try {
    const cmakeVer = require('child_process').execSync('cmake --version', { encoding: 'utf8' }).split('\n')[0];
    console.log(`✅ CMake: ${cmakeVer}`);
  } catch {
    console.log('❌ CMake não encontrado. Baixe em: https://cmake.org/download/');
  }

  try {
    const clVer = require('child_process').execSync('cl --version 2>nul', { encoding: 'utf8' }).split('\n')[0];
    console.log(`✅ MSVC: ${clVer}`);
  } catch {
    console.log('❌ MSVC (cl.exe) não encontrado.');
    console.log('   Instale Visual Studio 2022 Community com:');
    console.log('   • "Desenvolvimento para desktop com C++"');
    console.log('   • Abra "Command Prompt for VS 2022" e execute este script lá.\n');
  }

  console.log('');
}

function cloneAndBuild() {
  const dir = path.join(__dirname, 'xmrig-veil');
  if (fs.existsSync(dir)) {
    console.log('📁 xmrig-veil já existe. Pulando clone.\n');
    buildXmrig(dir);
    return;
  }

  console.log('📥 Clonando xmrig-veil (ohcee/xmrig-veil)...\n');
  const git = spawn('git', ['clone', 'https://github.com/ohcee/xmrig-veil.git'], {
    stdio: 'inherit',
    shell: true,
    cwd: __dirname
  });

  git.on('close', (code) => {
    if (code !== 0) {
      console.log('\n❌ Erro ao clonar repositório.');
      process.exit(code);
    }
    buildXmrig(dir);
  });
}

function buildXmrig(dir) {
  const buildDir = path.join(dir, 'build');
  if (!fs.existsSync(buildDir)) fs.mkdirSync(buildDir, { recursive: true });

  console.log('\n🔧 Configurando CMake...\n');
  const cmake = spawn('cmake', [
    '..', '-G', 'Visual Studio 17 2022', '-A', 'x64'
  ], {
    stdio: 'inherit',
    shell: true,
    cwd: buildDir
  });

  cmake.on('close', (code) => {
    if (code !== 0) {
      console.log('\n❌ Erro na configuração CMake.');
      return;
    }

    console.log('\n🔨 Compilando xmrig-veil (Release)...\n');
    const build = spawn('cmake', ['--build', '.', '--config', 'Release'], {
      stdio: 'inherit',
      shell: true,
      cwd: buildDir
    });

    build.on('close', (code) => {
      if (code !== 0) {
        console.log('\n❌ Erro na compilação.');
        return;
      }
      console.log('\n✅ xmrig-veil compilado com sucesso!');
      console.log(`📁 Binário em: ${path.join(buildDir, 'Release', 'xmrig.exe')}\n`);
      console.log('Agora execute: node miner.js\n');
    });
  });
}

checkTools();

const rl = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Deseja clonar e compilar xmrig-veil agora? (s/N): ', (resp) => {
  rl.close();
  if (resp.toLowerCase() === 's') {
    cloneAndBuild();
  } else {
    console.log('\nOK. Para compilar manualmente:');
    console.log('1. git clone https://github.com/ohcee/xmrig-veil.git');
    console.log('2. cd xmrig-veil && mkdir build && cd build');
    console.log('3. cmake .. -G "Visual Studio 17 2022" -A x64');
    console.log('4. cmake --build . --config Release\n');
    console.log('Depois execute: node miner.js\n');
  }
});
