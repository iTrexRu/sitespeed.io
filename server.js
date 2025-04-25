console.log('Starting server.js');
const express = require('express');
console.log('Express loaded');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const app = express();

app.use(express.json());

app.post('/run', async (req, res) => {
  try {
    const { url, browser = 'chrome', iterations = 3 } = req.body;
    if (!url) return res.status(400).json({ error: 'URL is required' });
    const command = `node bin/sitespeed.js ${url} --json --browser ${browser} --iterations ${iterations}`;
    console.log(`Executing: ${command}`);
    const { stdout, stderr } = await execPromise(command);
    if (stderr && !stdout) return res.status(500).json({ error: stderr });
    res.json(JSON.parse(stdout));
  } catch (error) {
    console.error(`Error: ${error.message}`);
    res.status(500).json({ error: error.message });
  }
});

app.get('/health', (req, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
