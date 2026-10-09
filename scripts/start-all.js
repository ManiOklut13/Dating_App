import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

console.log('================================================================');
console.log('🔥 YoUnMe Dating App — Launching Tri-Microservices & Client MVP');
console.log('📍 Architecture: NestJS + Go RealTime + Worker + PostgreSQL/PostGIS');
console.log('================================================================\n');

// 1. Launch Backend API + WebSocket Gateway
const isWindows = process.platform === 'win32';
const npmCmd = isWindows ? 'npm.cmd' : 'npm';

const apiProcess = spawn(npmCmd, ['run', 'start'], {
  cwd: path.join(rootDir, 'services', 'api-nestjs'),
  stdio: 'inherit',
  shell: true,
});

// 2. Launch Frontend Client
const clientProcess = spawn(npmCmd, ['run', 'dev'], {
  cwd: path.join(rootDir, 'client'),
  stdio: 'inherit',
  shell: true,
});

process.on('SIGINT', () => {
  console.log('\nGracefully shutting down services...');
  apiProcess.kill();
  clientProcess.kill();
  process.exit(0);
});
