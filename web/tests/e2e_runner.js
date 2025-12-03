import puppeteer from 'puppeteer';

// Config
const WEB_PORT = 8080;
const API_PORT = 3000;
const WEB_URL = `http://localhost:${WEB_PORT}`;
const API_URL = `http://localhost:${API_PORT}`;

// Simple Test Runner
async function runTest(name, fn) {
    console.log(`\n🧪 Running: ${name}`);
    try {
        await fn();
        console.log(`✅ Passed: ${name}`);
        return true;
    } catch (e) {
        console.error(`❌ Failed: ${name}`);
        console.error(e);
        return false;
    }
}

async function expect(actual) {
    return {
        toBe: (expected) => {
            if (actual !== expected) throw new Error(`Expected ${expected} but got ${actual}`);
        },
        toContain: (expected) => {
            if (!actual.includes(expected)) throw new Error(`Expected '${actual}' to contain '${expected}'`);
        },
        not: {
            toBe: (expected) => {
                if (actual === expected) throw new Error(`Expected ${actual} not to be ${expected}`);
            }
        }
    };
}

// Main
(async () => {
    console.log('🚀 Starting E2E Tests...');

    // Wait for servers (simple check)
    try {
        await fetch(WEB_URL);
        await fetch(API_URL);
    } catch (e) {
        console.error('⚠️  Servers might not be ready. Proceeding anyway...');
    }

    const browser = await puppeteer.launch({
        headless: "new",
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();

    // Log browser console and errors
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    page.on('pageerror', err => console.log('PAGE ERROR:', err.toString()));
    page.on('requestfailed', request => console.log(`PAGE REQUEST FAILED: ${request.url()} ${request.failure().errorText}`));

    let passed = 0;
    let failed = 0;

    try {
        // Test 1: Landing Page
        const t1 = await runTest('should load landing page', async () => {
            await page.goto(WEB_URL);
            const title = await page.title();
            (await expect(title)).toBe('Done - Gig Marketplace');

            const heroText = await page.$eval('h1', el => el.innerText);
            (await expect(heroText)).toContain('Get It Done');
        });
        if (t1) passed++; else failed++;

        // Test 2: Navigation to Login
        const t2 = await runTest('should navigate to login page', async () => {
            await page.goto(WEB_URL);
            await page.waitForFunction(() => window.showPage); // Wait for app to load
            await page.evaluate(() => window.showPage('landing'));
            await page.click('button[onclick="showPage(\'login\')"]');
            await page.waitForSelector('#login-form');
            const isVisible = await page.$eval('#login-page', el => !el.classList.contains('hidden'));
            (await expect(isVisible)).toBe(true);
        });
        if (t2) passed++; else failed++;

        // Test 3: Registration
        const t3 = await runTest('should register a new user', async () => {
            await page.goto(WEB_URL);
            await page.waitForFunction(() => window.showPage);
            await page.evaluate(() => window.showPage('register'));
            await page.waitForSelector('#register-form');

            const uniqueId = Date.now();
            await page.type('#register-name', `User ${uniqueId}`);
            await page.type('#register-email', `user${uniqueId}@example.com`);
            await page.type('#register-password', 'password123');
            await page.select('#register-role', 'CLIENT');
            await page.click('#register-terms');

            await Promise.all([
                page.evaluate(() => document.querySelector('#register-form button[type="submit"]').click()),
            ]);

            // Wait for home page
            try {
                await page.waitForSelector('#home-page', { visible: true, timeout: 5000 });
            } catch (e) {
                const error = await page.evaluate(() => {
                    const el = document.querySelector('.alert-error');
                    return el ? el.innerText : null;
                });
                if (error) throw new Error(`Registration failed: ${error}`);
                throw e;
            }

            const homeVisible = await page.$eval('#home-page', el => !el.classList.contains('hidden'));
            (await expect(homeVisible)).toBe(true);
        });
        if (t3) passed++; else failed++;

        // Test 4: Create Job
        const t4 = await runTest('should create a job', async () => {
            await page.waitForFunction(() => window.showPage);
            await page.evaluate(() => window.showPage('create-job'));
            await page.waitForSelector('#create-job-form');

            await page.type('#job-title', 'E2E Test Job');
            await page.type('#job-description', 'This is a test job from E2E');
            await page.type('#job-price', '50');
            await page.type('#job-zipcode', '10001');

            await page.evaluate(() => document.querySelector('#create-job-form button[type="submit"]').click());

            await page.waitForSelector('#home-page', { visible: true });

            await page.waitForFunction(() => {
                const titles = Array.from(document.querySelectorAll('.job-card h3')).map(e => e.innerText);
                return titles.some(t => t.includes('E2E Test Job'));
            }, { timeout: 5000 });

            const jobTitles = await page.$$eval('.job-card h3', els => els.map(e => e.innerText));
            (await expect(jobTitles)).toContain('E2E Test Job');
        });
        if (t4) passed++; else failed++;

        // Test 5: Logout (Check user info)
        const t5 = await runTest('should show user info', async () => {
            const userInfo = await page.$eval('#user-info', el => el.innerText);
            (await expect(userInfo)).not.toBe('');
        });
        if (t5) passed++; else failed++;

    } catch (e) {
        console.error('Critical Error:', e);
    } finally {
        await browser.close();
        console.log(`\n🏁 Summary: ${passed} Passed, ${failed} Failed`);
        if (failed > 0) process.exit(1);
    }
})();
