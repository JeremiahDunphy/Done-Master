import { getJobs, createJob, applyForJob, updateJobStatus } from './jobs.service.js';
import { getSavedJobIds, toggleSavedJob } from '../saved-jobs/saved-jobs.service.js';
import { geocodeZipCode, uploadPhoto } from '../../shared/api.js';
import { showMessage, calculateDistance } from '../../shared/utils.js';
import { state } from '../../shared/state.js';
import { showPage } from '../../shared/router.js';
import { API_BASE_URL } from '../../shared/config.js';
import { displayJobsOnMap } from './map.ui.js';
import { startChatWith } from '../chat/chat.ui.js';

let savedJobIds = new Set();

export async function loadJobs() {
    const jobsGrid = document.getElementById('jobs-grid');
    jobsGrid.innerHTML = '<div class="spinner" style="margin: 2rem auto;"></div>';

    try {
        const [jobs, savedIds] = await Promise.all([
            getJobs(),
            getSavedJobIds()
        ]);

        state.allJobs = jobs;
        savedJobIds = new Set(savedIds);

        if (jobs.length === 0) {
            jobsGrid.innerHTML = '<p class="text-center text-muted">No jobs available yet.</p>';
            return;
        }

        displayJobs(jobs);
    } catch (error) {
        jobsGrid.innerHTML = '<p class="text-center text-muted">Failed to load jobs.</p>';
    }
}

export function displayJobs(jobs) {
    const jobsGrid = document.getElementById('jobs-grid');

    if (jobs.length === 0) {
        jobsGrid.innerHTML = '<p class="text-center text-muted">No jobs found matching your search.</p>';
        return;
    }

    jobsGrid.innerHTML = jobs.map(job => {
        const isSaved = savedJobIds.has(job.id);
        const photoUrls = job.photos ? job.photos.split(',').filter(p => p) : [];
        const photoGallery = photoUrls.length > 0 ? `
            <div style="display: flex; gap: 0.5rem; margin-top: 0.5rem; flex-wrap: wrap;">
                ${photoUrls.map(url => `
                    <img src="${API_BASE_URL}${url}" alt="Job photo" 
                         style="width: 80px; height: 80px; object-fit: cover; border-radius: 0.5rem;">
                `).join('')}
            </div>
        ` : '';

        return `
            <div class="card job-card fade-in-up" style="position: relative;">
                ${state.currentUser ? `
                <button onclick="window.toggleSave(${job.id})" style="position: absolute; top: 1rem; right: 1rem; background: none; border: none; font-size: 1.5rem; cursor: pointer; color: ${isSaved ? '#ef4444' : 'var(--text-muted)'}; transition: transform 0.2s;">
                    ${isSaved ? '❤️' : '🤍'}
                </button>` : ''}
                <div class="job-header">
                    <div style="padding-right: 2rem;">
                        <h3>${job.title}</h3>
                        <p class="text-muted mb-sm">${job.description}</p>
                        ${job.scheduledDate ? `<p style="color: var(--primary); font-weight: 500; margin-bottom: 0.5rem;">📅 ${new Date(job.scheduledDate).toLocaleDateString()}</p>` : ''}
                        ${photoGallery}
                    </div>
                    <div class="text-right">
                        <div class="price-tag">$${job.price}/day</div>
                        ${job.isUrgent ? '<span class="badge" style="background: #ff4d4d; margin-right: 0.5rem;">⚡ Urgent</span>' : ''}
                        <span class="badge ${getBadgeClass(job.status)}">${job.status}</span>
                    </div>
                </div>
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; gap: 0.5rem;">
                        ${getJobButtons(job)}
                        ${addMessageButton(job)}
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

function getBadgeClass(status) {
    switch (status) {
        case 'OPEN': return 'badge-success'; // Greenish
        case 'IN_PROGRESS': return 'badge-warning'; // Yellow/Orange
        case 'COMPLETED': return 'badge-info'; // Blue
        case 'PAID': return 'badge-primary'; // Brand color
        default: return '';
    }
}

function getJobButtons(job) {
    if (!state.currentUser) return '';

    const isClient = state.currentUser.role === 'CLIENT' && job.clientId === state.currentUser.id;
    const isProvider = state.currentUser.role === 'PROVIDER';
    const isMyJob = job.providerId === state.currentUser.id;

    if (isClient) {
        if (job.status === 'OPEN') {
            // Show applicants? For now, just a placeholder or "View Applicants"
            // Since we don't have a separate applicants view yet, we'll assume we can accept the first one for demo
            // But wait, we need to know WHO applied.
            // For MVP, let's say if I'm the client, I can see a list of applicants in the details?
            // Or simpler: If I'm chatting with someone, I can "Hire" them.
            return `<span class="text-muted">Waiting for applicants...</span>`;
        }
        if (job.status === 'IN_PROGRESS') {
            return `<span class="text-muted">In Progress</span>`;
        }
        if (job.status === 'COMPLETED') {
            return `<button class="btn btn-success" onclick="window.updateStatus(${job.id}, 'PAID')">Mark Paid</button>`;
        }
        if (job.status === 'COMPLETED' && isClient) {
            return `
                <button class="btn btn-primary btn-sm" onclick="window.openPaymentModal({id: ${job.id}, title: '${job.title.replace(/'/g, "\\'")}', price: ${job.price}})">
                    Pay Now ($${job.price})
                </button>
            `;
        }
        if (job.status === 'PAID' && isClient) {
            return `
                <button class="btn btn-outline btn-sm" onclick="window.openReviewModal(${job.id}, ${job.providerId})">Leave Review</button>
            `;
        }
    }

    if (isProvider) {
        if (job.status === 'OPEN') {
            return `<button class="btn btn-primary" onclick="window.handleApply(${job.id})">Apply</button>`;
        }
        if (job.status === 'IN_PROGRESS' && isMyJob) {
            return `<button class="btn btn-info" onclick="window.updateStatus(${job.id}, 'COMPLETED')">Mark Complete</button>`;
        }
        if (job.status === 'PAID' && isMyJob) {
            return `<button class="btn btn-outline" onclick="window.openReviewModal(${job.id}, ${job.clientId})">Leave Review</button>`;
        }
    }

    return '';
}

function addMessageButton(job) {
    if (state.currentUser && job.clientId === state.currentUser.id) return '';
    // We need to pass the client object safely. Since we are in template literal, we can't pass object directly easily.
    // Instead, we'll attach the handler to window or use a data attribute.
    // For simplicity in this refactor, let's use a global handler wrapper.
    return `<button onclick='window.startChatWith(${JSON.stringify(job.client)})' class="btn btn-outline" style="width: 100%; margin-top: 1rem;">💬 Message Provider</button>`;
}

export function initJobs() {
    // Expose handlers to window for inline onclicks
    window.handleApply = async (jobId) => {
        try {
            await applyForJob(jobId);
            showMessage('Application submitted!', 'success');
            loadJobs();
        } catch (error) {
            showMessage('Failed to apply for job.');
        }
    };

    window.updateStatus = async (jobId, status) => {
        try {
            await updateJobStatus(jobId, status);
            showMessage(`Job marked as ${status}`, 'success');
            loadJobs();
        } catch (error) {
            showMessage('Failed to update status');
        }
    };

    window.toggleSave = async (jobId) => {
        try {
            const result = await toggleSavedJob(jobId);
            if (result.saved) {
                savedJobIds.add(jobId);
                showMessage('Job saved to favorites', 'success');
            } else {
                savedJobIds.delete(jobId);
                showMessage('Job removed from favorites');
            }
            // Re-render to update icon state without full reload if possible, but loadJobs is safer for now
            // Or just update the button directly for better UX?
            // Let's just re-render the list for simplicity in this step
            displayJobs(state.allJobs);
        } catch (error) {
            showMessage('Failed to toggle saved job');
        }
    };

    window.startChatWith = startChatWith;

    // Create Job Form
    const photoInput = document.getElementById('job-photos');
    const photoPreview = document.getElementById('photo-preview');

    photoInput.addEventListener('change', (e) => {
        const files = Array.from(e.target.files);
        photoPreview.innerHTML = '';

        files.slice(0, 5).forEach((file, index) => {
            const reader = new FileReader();
            reader.onload = (event) => {
                const img = document.createElement('img');
                img.src = event.target.result;
                img.style.cssText = 'width: 100px; height: 100px; object-fit: cover; border-radius: 0.5rem; border: 2px solid rgba(255,255,255,0.1);';
                photoPreview.appendChild(img);
            };
            reader.readAsDataURL(file);
        });
    });

    document.getElementById('create-job-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const title = document.getElementById('job-title').value;
        const description = document.getElementById('job-description').value;
        const price = document.getElementById('job-price').value;
        const zipCode = document.getElementById('job-zip').value;
        const category = document.getElementById('job-category').value;
        const scheduledDate = document.getElementById('job-date').value;

        // Upload photos first
        const photoFiles = document.getElementById('job-photos').files;
        let photoUrls = [];
        if (photoFiles.length > 0) {
            try {
                // Upload each photo sequentially
                for (let i = 0; i < photoFiles.length; i++) {
                    const url = await uploadPhoto(photoFiles[i]);
                    if (url) photoUrls.push(url);
                }
            } catch (e) {
                console.error('Photo upload failed', e);
                showMessage('Failed to upload photos', 'error');
                return;
            }
        }

        try {
            await createJob({
                title,
                description,
                price,
                clientId: state.currentUser.id,
                zipCode,
                category,
                category,
                photos: photoUrls.join(','),
                scheduledDate,
                isUrgent: document.getElementById('job-urgent').checked
            });
            showMessage('Job created successfully!', 'success');
            document.getElementById('create-job-form').reset();
            document.getElementById('photo-preview').innerHTML = ''; // Clear previews
            showPage('home');
            loadJobs();
        } catch (error) {
            console.error(error);
            if (error.message === 'Invalid zip code') {
                showMessage('Invalid zip code. Please enter a valid US zip code.');
            } else {
                showMessage('Failed to create job. ' + error.message);
            }
        }
    });

    // Search Logic
    window.searchJobs = async () => {
        const zipCode = document.getElementById('search-zipcode').value.trim();
        const maxDistance = parseFloat(document.getElementById('search-distance').value);

        if (!zipCode) {
            displayJobs(state.allJobs);
            return;
        }

        try {
            const searchCoords = await geocodeZipCode(zipCode);
            const filteredJobs = state.allJobs.filter(job => {
                if (!job.latitude || !job.longitude) return false;
                const distance = calculateDistance(
                    searchCoords.latitude,
                    searchCoords.longitude,
                    job.latitude,
                    job.longitude
                );
                return distance <= maxDistance;
            });

            displayJobs(filteredJobs);
            showMessage(`Found ${filteredJobs.length} jobs within ${maxDistance} miles`, 'success');

            if (state.map && document.getElementById('map-container').style.display !== 'none') {
                displayJobsOnMap(filteredJobs);
            }
        } catch (error) {
            showMessage('Invalid zip code');
        }
    };

    // Category Filter
    window.filterByCategory = (category) => {
        document.querySelectorAll('.category-chip').forEach(btn => {
            if (btn.textContent === category) {
                btn.classList.add('active');
                btn.style.backgroundColor = 'var(--primary)';
                btn.style.color = 'white';
            } else {
                btn.classList.remove('active');
                btn.style.backgroundColor = 'transparent';
                btn.style.color = 'var(--text-primary)';
            }
        });

        if (category === 'All') {
            displayJobs(state.allJobs);
        } else if (category === 'Saved') {
            const saved = state.allJobs.filter(job => savedJobIds.has(job.id));
            displayJobs(saved);
        } else {
            const filtered = state.allJobs.filter(job => job.category === category);
            displayJobs(filtered);
        }
    };
}
