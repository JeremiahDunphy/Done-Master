const http = require('http');

const files = [
    '/js/main.js',
    '/js/shared/router.js',
    '/js/shared/api.js',
    '/js/shared/state.js',
    '/js/shared/utils.js',
    '/js/shared/theme.js',
    '/js/shared/config.js',
    '/js/features/auth/auth.ui.js',
    '/js/features/auth/auth.service.js',
    '/js/features/jobs/jobs.ui.js',
    '/js/features/jobs/jobs.service.js',
    '/js/features/jobs/map.ui.js',
    '/js/features/chat/chat.ui.js',
    '/js/features/chat/chat.service.js',
    '/js/features/profile/profile.ui.js',
    '/js/libs/socket.io.js'
];

const PORT = 8080;
const BASE_URL = `http://localhost:${PORT}`;

async function checkFile(path) {
    return new Promise((resolve) => {
        http.get(`${BASE_URL}${path}`, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log(`${res.statusCode} ${path} (${data.length} bytes)`);
                if (res.statusCode !== 200 || data.length === 0) {
                    console.error(`❌ FAILED: ${path}`);
                }
                resolve();
            });
        }).on('error', (err) => {
            console.error(`❌ ERROR: ${path} - ${err.message}`);
            resolve();
        });
    });
}

(async () => {
    console.log(`Checking resources on ${BASE_URL}...`);
    for (const file of files) {
        await checkFile(file);
    }
})();
