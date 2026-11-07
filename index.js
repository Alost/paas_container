const path = require("path");

const SCRIPT = path.join(__dirname, "start.sh");
const args = fs.existsSync(SCRIPT) ? [SCRIPT] : ["-i"];
const argv = ["env", "bash", ...args, ...process.argv.slice(2)];

if (typeof process.execve === "function") {
  process.execve("/usr/bin/env", argv, process.env);
} else {
  const { spawnSync } = require("child_process");
  const res = spawnSync("/usr/bin/env", argv.slice(1), { stdio: "inherit" });
  if (res.error) throw res.error;
  if (res.signal) process.kill(process.pid, res.signal);
  else process.exit(res.status ?? 1);
}
