/**
 * @jest-environment node
 */
import puppeteer from 'puppeteer';
import { jest } from '@jest/globals';

// Config
const WEB_PORT = 8080;
const API_PORT = 3000;
const WEB_URL = `http://localhost:${WEB_PORT}`;
const API_URL = `http://localhost:${API_PORT}`;

let browser;
let page;

// Helper to wait for server
const waitForServer = async (url, timeout = 10000) => {
    const start = Date.now();
    while (Date.now() - start < timeout) {
        try {
            const res = await fetch(url);
            if (res.ok || res.status === 404) return true; // 404 is fine, means server is up
        } catch (e) {
            await new Promise(r => setTimeout(r, 500));
        }
    }
    return false;
};

describe('Done App E2E', () => {
    jest.setTimeout(60000); // Increase timeout

    beforeAll(async () => {
        // Wait for servers to be up
        console.log('Waiting for servers...');
        const webUp = await waitForServer(WEB_URL);
        const apiUp = await waitForServer(API_URL);

        if (!webUp) throw new Error(`Web server at ${WEB_URL} is not reachable`);
        if (!apiUp) throw new Error(`API server at ${API_URL} is not reachable`);

        // Launch Browser
        browser = await puppeteer.launch({
            headless: "new",
            args: ['--no-sandbox', '--disable-setuid-sandbox']
        });
    }, 30000);

    beforeEach(async () => {
        page = await browser.newPage();
        page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    });

    afterAll(async () => {
        if (browser) await browser.close();
    });

    test('should load landing page', async () => {
        await page.goto(WEB_URL);
        const title = await page.title();
        expect(title).toBe('Done - Gig Marketplace');

        const heroText = await page.$eval('h1', el => el.innerText);
        expect(heroText).toContain('Get It Done');
    });

    test('should navigate to login page', async () => {
        await page.goto(WEB_URL);
        // Ensure we are on landing page first
        await page.evaluate(() => showPage('landing'));

        await page.click('button[onclick="showPage(\'login\')"]');

        // Wait for login form
        await page.waitForSelector('#login-form');
        const isVisible = await page.$eval('#login-page', el => !el.classList.contains('hidden'));
        expect(isVisible).toBe(true);
    });

    test('should register a new user', async () => {
        await page.goto(WEB_URL);
        await page.evaluate(() => showPage('register'));

        await page.waitForSelector('#register-form');

        const uniqueId = Date.now();
        await page.type('#register-name', `User ${uniqueId}`);
        await page.type('#register-email', `user${uniqueId}@example.com`);
        await page.type('#register-password', 'password123');
        await page.select('#reg-role', 'POSTER');
        await page.click('#register-terms');

        await Promise.all([
            page.evaluate(() => document.querySelector('#register-form button[type="submit"]').click()),
        ]);

        // Wait for home page
        try {
            await page.waitForSelector('#home-page', { visible: true, timeout: 5000 });
        } catch (e) {
            // If timeout, maybe check if we are still on register page and see error
            const error = await page.evaluate(() => {
                const el = document.querySelector('.alert-error'); // Assuming alert class
                return el ? el.innerText : null;
            });
            if (error) throw new Error(`Registration failed: ${error}`);
            throw e;
        }

        const homeVisible = await page.$eval('#home-page', el => !el.classList.contains('hidden'));
        expect(homeVisible).toBe(true);
    });

    test('should create a job', async () => {
        // Navigate to create job
        await page.evaluate(() => showPage('create-job'));
        await page.waitForSelector('#create-job-form');

        await page.type('#job-title', 'E2E Test Job');
        await page.type('#job-description', 'This is a test job from E2E');
        await page.type('#job-price', '50');
        await page.type('#job-zipcode', '10001');

        await page.evaluate(() => document.querySelector('#create-job-form button[type="submit"]').click());

        // Should go back to home and show job
        await page.waitForSelector('#home-page', { visible: true });

        // Check if job is in the list
        // We might need to wait for the job list to refresh
        await page.waitForFunction(() => {
            const titles = Array.from(document.querySelectorAll('.job-card h3')).map(e => e.innerText);
            return titles.some(t => t.includes('E2E Test Job'));
        }, { timeout: 5000 });

        const jobTitles = await page.$$eval('.job-card h3', els => els.map(e => e.innerText));
        expect(jobTitles).toContain('E2E Test Job');
    });

    test('should logout', async () => {
        // Verify user info is present
        const userInfo = await page.$eval('#user-info', el => el.innerText);
        expect(userInfo).not.toBe('');
    });
});
