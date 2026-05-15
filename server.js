const express = require('express');
const cors = require('cors');
const metricsRoutes = require('./routes/metricsRoutes');

const app = express();

const PORT = 3000;

app.use(cors({
    origin: "*"
}));

app.use(express.json());

// Base API Route
app.use('/api', metricsRoutes);

// Start Server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
