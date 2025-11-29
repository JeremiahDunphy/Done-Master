import { apiCall } from '../../shared/api.js';

// Initialize Stripe with Publishable Key (Replace with your own)
export const stripe = Stripe('pk_test_TYooMQauvdEDq54NiTphI7jx');

export async function createPaymentIntent(jobId, amount) {
    return await apiCall('/create-payment-intent', {
        method: 'POST',
        body: JSON.stringify({ jobId, amount })
    });
}
