const si = require('systeminformation');
const { exec } = require('child_process');
const os = require('os');

// Function to get disk usage
async function getDiskUsage() {
    try {
        const disks = await si.fsSize();

        return disks.map(disk => ({
            filesystem: disk.fs,
            mount: disk.mount,
            sizeGB: (disk.size / 1024 / 1024 / 1024).toFixed(2),
            usedGB: (disk.used / 1024 / 1024 / 1024).toFixed(2),
            usagePercent: disk.use
        }));
    } catch (err) {
        return { error: err.message };
    }
}

// Function to get CPU usage
async function getCpuUsage() {
    try {
        const load = await si.currentLoad();

        return {
            cpuUsagePercent: load.currentLoad.toFixed(2),
            cores: load.cpus.map((cpu, index) => ({
                core: index,
                usage: cpu.load.toFixed(2)
            }))
        };
    } catch (err) {
        return { error: err.message };
    }
}

// Function to get memory usage
async function getMemoryUsage() {
    try {
        const mem = await si.mem();

        return {
            totalGB: (mem.total / 1024 / 1024 / 1024).toFixed(2),
            usedGB: (mem.used / 1024 / 1024 / 1024).toFixed(2),
            freeGB: (mem.free / 1024 / 1024 / 1024).toFixed(2),
            usagePercent: ((mem.used / mem.total) * 100).toFixed(2)
        };
    } catch (err) {
        return { error: err.message };
    }
}

// Function to extract logs
function getLogs(logFile = '/var/log/syslog', lines = 20) {
    return new Promise((resolve) => {
        exec(`tail -n ${lines} ${logFile}`, (error, stdout, stderr) => {
            if (error) {
                resolve({ error: error.message });
                return;
            }

            if (stderr) {
                resolve({ error: stderr });
                return;
            }

            resolve(stdout.split('\n').filter(Boolean));
        });
    });
}

// Main function
async function collectVmMetrics() {
    const cpu = await getCpuUsage();
    const memory = await getMemoryUsage();
    const disk = await getDiskUsage();
    const logs = await getLogs();

    const result = {
        hostname: os.hostname(),
        platform: os.platform(),
        timestamp: new Date().toISOString(),

        cpu,
        memory,
        disk,
        logs
    };

    console.log(JSON.stringify(result, null, 2));
}

// Run
collectVmMetrics();
