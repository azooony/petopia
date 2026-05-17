const { execSync } = require('child_process');
const PORT = 3000;

try {
  const out = execSync('netstat -ano', { encoding: 'utf8' });
  const pids = new Set();

  for (const line of out.split('\n')) {
    if (line.includes(`:${PORT} `) && line.includes('LISTENING')) {
      const pid = line.trim().split(/\s+/).pop();
      if (pid && pid !== '0') pids.add(pid);
    }
  }

  for (const pid of pids) {
    try {
      execSync(`taskkill /PID ${pid} /F`, { stdio: 'ignore' });
      console.log(`[predev] Killed PID ${pid} (was holding port ${PORT})`);
    } catch {}
  }
} catch {}
