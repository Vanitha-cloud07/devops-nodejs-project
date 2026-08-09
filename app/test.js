// Minimal smoke test used by the Jenkins "Test" stage.
// Boots the app, hits /health, exits 0 on success and 1 on failure.
const http = require('http');
const app = require('./app.js');

const server = app.listen(0, () => {
  const { port } = server.address();
  http.get(`http://127.0.0.1:${port}/health`, (res) => {
    if (res.statusCode === 200) {
      console.log('Smoke test passed: /health returned 200');
      server.close(() => process.exit(0));
    } else {
      console.error(`Smoke test failed: /health returned ${res.statusCode}`);
      server.close(() => process.exit(1));
    }
  }).on('error', (err) => {
    console.error('Smoke test failed:', err.message);
    process.exit(1);
  });
});