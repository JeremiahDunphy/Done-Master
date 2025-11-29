import { createReview, getUserReviews } from './reviews.service.js';
import { showMessage } from '../../shared/utils.js';
import { state } from '../../shared/state.js';

export async function openReviewModal(jobId, revieweeId) {
    // Create modal HTML
    const modal = document.createElement('div');
    modal.id = 'review-modal';
    modal.style.cssText = `
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center;
        z-index: 2000; animation: fadeIn 0.2s;
    `;

    modal.innerHTML = `
        <div class="card" style="width: 90%; max-width: 500px; position: relative;">
            <button onclick="document.getElementById('review-modal').remove()" style="position: absolute; top: 1rem; right: 1rem; background: none; border: none; color: white; font-size: 1.5rem; cursor: pointer;">&times;</button>
            <h2 class="mb-md">Rate your experience</h2>
            <form id="review-form">
                <div class="form-group">
                    <label class="form-label">Rating</label>
                    <div style="display: flex; gap: 0.5rem; font-size: 2rem; cursor: pointer;" id="star-rating">
                        <span data-value="1">☆</span>
                        <span data-value="2">☆</span>
                        <span data-value="3">☆</span>
                        <span data-value="4">☆</span>
                        <span data-value="5">☆</span>
                    </div>
                    <input type="hidden" id="rating-value" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Comment</label>
                    <textarea id="review-comment" class="form-textarea" required placeholder="How was working with this user?"></textarea>
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%;">Submit Review</button>
            </form>
        </div>
    `;

    document.body.appendChild(modal);

    // Star Rating Logic
    let currentRating = 0;
    const stars = modal.querySelectorAll('#star-rating span');
    stars.forEach(star => {
        star.onclick = () => {
            currentRating = parseInt(star.dataset.value);
            document.getElementById('rating-value').value = currentRating;
            stars.forEach(s => {
                s.textContent = parseInt(s.dataset.value) <= currentRating ? '★' : '☆';
                s.style.color = parseInt(s.dataset.value) <= currentRating ? 'var(--secondary)' : 'var(--text-muted)';
            });
        };
    });

    // Form Submission
    document.getElementById('review-form').onsubmit = async (e) => {
        e.preventDefault();
        const comment = document.getElementById('review-comment').value;

        if (!currentRating) {
            showMessage('Please select a rating');
            return;
        }

        try {
            await createReview({
                jobId,
                reviewerId: state.currentUser.id,
                revieweeId,
                rating: currentRating,
                comment
            });

            showMessage('Review submitted!', 'success');
            modal.remove();
        } catch (error) {
            showMessage('Failed to submit review');
        }
    };
}

// Expose to window
window.openReviewModal = openReviewModal;
