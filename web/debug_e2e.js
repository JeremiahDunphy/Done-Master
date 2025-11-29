import puppeteer from 'puppeteer';

const WEB_PORT = 8080;
const API_PORT = 3000;
const WEB_URL = `http://localhost:${WEB_PORT}`;
const API_URL = `http://localhost:${API_PORT}`;

(async () => {
    console.log('--- Debugging E2E Environment ---');

    // 1. Check Web Server
    try {
        console.log(`Checking Web Server at ${WEB_URL}...`);
        const res = await fetch(WEB_URL);
        console.log(`Web Server Status: ${res.status}`);
    } catch (e) {
        console.error(`Web Server Error: ${e.message}`);
    }

    // 2. Check API Server
    try {
        console.log(`Checking API Server at ${API_URL}...`);
        const res = await fetch(API_URL); // Root might be 404 but that's ok
        console.log(`API Server Status: ${res.status}`);
    } catch (e) {
        console.error(`API Server Error: ${e.message}`);
    }

    // 3. Check Puppeteer
    try {
        console.log('Launching Puppeteer...');
        const browser = await puppeteer.launch({
            headless: "new",
            args: ['--no-sandbox', '--disable-setuid-sandbox']
        });
        const page = await browser.newPage();
        console.log('Puppeteer launched. Navigating to Web URL...');
        await page.goto(WEB_URL);
        const title = await page.title();
        console.log(`Page Title: ${title}`);
        await browser.close();
        console.log('Puppeteer closed.');
    } catch (e) {
        console.error(`Puppeteer Error: ${e.message}`);
    }
})();
