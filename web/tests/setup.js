import { jest } from '@jest/globals';

// Mock localStorage
const localStorageMock = (function () {
    let store = {};
    return {
        getItem: function (key) {
            return store[key] || null;
        },
        setItem: function (key, value) {
            store[key] = value.toString();
        },
        clear: function () {
            store = {};
        },
        removeItem: function (key) {
            delete store[key];
        }
    };
})();

if (typeof window !== 'undefined') {
    Object.defineProperty(window, 'localStorage', { value: localStorageMock });
}

// Mock fetch
global.fetch = jest.fn(() =>
    Promise.resolve({
        ok: true,
        json: () => Promise.resolve({}),
    })
);

// Mock FormData
global.FormData = class {
    constructor() {
        this.data = {};
    }
    append(key, value) {
        this.data[key] = String(value);
    }
    get(key) {
        return this.data[key];
    }
};
