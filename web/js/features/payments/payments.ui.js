import { stripe, createPaymentIntent } from './payments.service.js';
import { updateJobStatus } from '../jobs/jobs.service.js';
import { loadJobs } from '../jobs/jobs.ui.js';

export async function openPaymentModal(job) {
    // Create Modal Elements
    const modalOverlay = document.createElement('div');
    modalOverlay.className = 'modal-overlay';
    modalOverlay.style.display = 'flex';

    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-header">
            <h2>Pay for Job: ${job.title}</h2>
            <button class="close-btn">&times;</button>
        </div>
        <div class="modal-body">
            <p class="mb-md">Total Amount: <strong>$${job.price}</strong></p>
            <div id="payment-element">
                <!-- Stripe Payment Element will be inserted here -->
            </div>
            <div id="payment-message" class="text-danger mt-sm" style="display: none;"></div>
            <button id="submit-payment-btn" class="btn btn-primary btn-block mt-md">Pay Now</button>
        </div>
    `;

    modalOverlay.appendChild(modal);
    document.body.appendChild(modalOverlay);

    // Close Logic
    const closeBtn = modal.querySelector('.close-btn');
    closeBtn.onclick = () => {
        document.body.removeChild(modalOverlay);
    };

    // Initialize Stripe Elements
    try {
        const { clientSecret } = await createPaymentIntent(job.id, job.price);
        const elements = stripe.elements({ clientSecret });
        const paymentElement = elements.create('payment');
        paymentElement.mount('#payment-element');

        const submitBtn = document.getElementById('submit-payment-btn');
        const messageDiv = document.getElementById('payment-message');

        submitBtn.onclick = async () => {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Processing...';
            messageDiv.style.display = 'none';

            const { error } = await stripe.confirmPayment({
                elements,
                confirmParams: {
                    return_url: window.location.href, // In a real SPA, handle this without reload if possible
                },
                redirect: 'if_required'
            });

            if (error) {
                messageDiv.textContent = error.message;
                messageDiv.style.display = 'block';
                submitBtn.disabled = false;
                submitBtn.textContent = 'Pay Now';
            } else {
                // Payment Successful
                await updateJobStatus(job.id, 'PAID');
                document.body.removeChild(modalOverlay);
                alert('Payment Successful!');
                loadJobs();
            }
        };

    } catch (e) {
        console.error('Failed to init payment', e);
        alert('Failed to initialize payment. Please try again.');
        document.body.removeChild(modalOverlay);
    }
}

// Expose to window for button clicks
window.openPaymentModal = openPaymentModal;
