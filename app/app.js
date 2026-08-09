const express = require('express');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Collect default Node.js metrics (CPU, memory, event loop, etc.)
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// Custom metric: total HTTP requests
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
});
register.registerMetric(httpRequestCounter);

// Custom metric: request duration histogram
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.05, 0.1, 0.3, 0.5, 1, 2, 5],
});
register.registerMetric(httpRequestDuration);

app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const labels = { method: req.method, route: req.path, status: res.statusCode };
    httpRequestCounter.inc(labels);
    end(labels);
  });
  next();
});

app.get('/', (req, res) => {
  res.json({ message: 'Hello from the DevOps end-to-end CI/CD demo app!', version: '1.0.0' });
});

// Liveness/readiness probe used by Kubernetes
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Scraped by Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});

module.exports = app;