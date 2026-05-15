const express = require('express');

const router = express.Router();

const {
    getCpuUsage,
    getMemoryUsage,
    getDiskUsage,
    getLogs,
    collectMetrics
} = require('../services/metricsService');

// ---------------- HEALTH ----------------
router.get('/', (req, res) => {
    res.json({
        status: 'success',
        message: 'VM Monitoring API Running'
    });
});

// ---------------- FULL METRICS ----------------
router.get('/metrics', async (req, res) => {

    try {

        const metrics = await collectMetrics();

        res.json({
            status: 'success',
            data: metrics
        });

    } catch (err) {

        res.status(500).json({
            status: 'error',
            message: err.message
        });
    }
});

// ---------------- CPU ----------------
router.get('/cpu', async (req, res) => {

    try {

        const cpu = await getCpuUsage();

        res.json(cpu);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

// ---------------- MEMORY ----------------
router.get('/memory', async (req, res) => {

    try {

        const memory = await getMemoryUsage();

        res.json(memory);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

// ---------------- DISK ----------------
router.get('/disk', async (req, res) => {

    try {

        const disk = await getDiskUsage();

        res.json(disk);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

// ---------------- LOGS ----------------
router.get('/logs', async (req, res) => {

    try {

        const lines = req.query.lines || 20;

        const logs = await getLogs('/var/log/syslog', lines);

        res.json({
            logs
        });

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

module.exports = router;
