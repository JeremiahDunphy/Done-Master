import { createJob } from '../js/features/jobs/jobs.service.js';
import { state } from '../js/shared/state.js';
import { apiCall } from '../js/shared/api.js';
import { jest } from '@jest/globals';



describe('jobs.service.js', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        state.currentUser = { id: 123 };
    });

    test('createJob sends isUrgent flag', async () => {
        const jobData = {
            title: 'Test Job',
            description: 'Test Description',
            price: 100,
            latitude: 0,
            longitude: 0,
            zipCode: '12345',
            isUrgent: true,
            photos: 'url1,url2'
        };

        await createJob(jobData);

        await createJob(jobData);

        expect(global.fetch).toHaveBeenCalledWith(expect.stringContaining('/jobs'), expect.objectContaining({
            method: 'POST',
            body: expect.any(FormData)
        }));

        // Verify FormData content
        const formData = global.fetch.mock.calls[0][1].body;
        expect(formData.get('isUrgent')).toBe('true'); // FormData values are strings
        expect(formData.get('title')).toBe('Test Job');
        expect(formData.get('clientId')).toBe('123'); // FormData values are strings
    });
});
