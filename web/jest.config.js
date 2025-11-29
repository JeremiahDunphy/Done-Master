export default {
    testEnvironment: 'jsdom',
    transform: {},
    setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
    collectCoverage: true,
    collectCoverageFrom: ['js/**/*.js'],
    coverageReporters: ['text', 'lcov']
};
