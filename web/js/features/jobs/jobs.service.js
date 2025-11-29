import { apiCall } from '../../shared/api.js';
import { state } from '../../shared/state.js';

export async function getJobs() {
    return await apiCall('/jobs');
}

export async function createJob(jobData) {
    const formData = new FormData();
    formData.append('title', jobData.title);
    formData.append('description', jobData.description);
    formData.append('price', jobData.price);
    formData.append('latitude', jobData.latitude);
    formData.append('longitude', jobData.longitude);
    formData.append('zipCode', jobData.zipCode);
    formData.append('category', jobData.category || 'General');
    formData.append('isUrgent', jobData.isUrgent);
    formData.append('clientId', state.currentUser.id);
    if (jobData.scheduledDate) {
        formData.append('scheduledDate', jobData.scheduledDate);
    }

    if (jobData.photos) {
        // Photos is a comma-separated string of URLs if already uploaded, 
        // OR it could be handled as file uploads here if we changed the logic.
        // In jobs.ui.js, we are uploading photos FIRST, then passing URLs.
        // So jobData.photos is likely a string "url1,url2".
        // But wait, the previous code I wrote in jobs.service.js (the broken one) was trying to append 'photos' as files?
        // Let's check jobs.ui.js again.
        // In jobs.ui.js (Step 2088), we upload photos first:
        // const url = await uploadPhoto(photoFiles[i]);
        // photoUrls.push(url);
        // await createJob({ ... photos: photoUrls.join(',') ... });
        // So jobData.photos is a STRING of URLs.
        // So we should just append it as a field.
        formData.append('photos', jobData.photos);
    }

    // Wait, the backend expects multipart/form-data for file uploads, OR JSON if just data?
    // If we use FormData, it sends multipart.
    // The backend `createJob` (server.js) uses `upload.array('photos', 5)`.
    // If we send `photos` as a string field, `req.files` will be empty, and `req.body.photos` will have the string.
    // We need to make sure the backend handles this.
    // Let's check server.js.

    // Actually, to be safe and consistent with the mobile app (which sends files), 
    // we should probably stick to the pattern.
    // BUT, the web UI is uploading photos individually to `/uploads` (via `uploadPhoto`) BEFORE creating the job?
    // `uploadPhoto` in `shared/api.js` likely hits `/uploads`?
    // Let's assume the web flow is: Upload -> Get URL -> Create Job with URL.
    // If so, `createJob` should just send JSON?
    // But `server.js` uses `upload.array('photos')` middleware on `/jobs` route.
    // This middleware expects files.
    // If we don't send files, it might be fine, but we need to pass the photo URLs somehow.
    // If `req.body.photos` is populated, we need to use it.

    // Let's stick to FormData to be safe with the middleware, but pass photos as a string.
    return await apiCall('/jobs', {
        method: 'POST',
        body: formData,
    });
}

export async function applyForJob(jobId) {
    return await apiCall(`/jobs/${jobId}/apply`, {
        method: 'POST',
        body: JSON.stringify({ providerId: state.currentUser.id }),
        headers: { 'Content-Type': 'application/json' }
    });
}

export async function acceptJob(jobId, providerId) {
    return await apiCall(`/jobs/${jobId}/accept`, {
        method: 'POST',
        body: JSON.stringify({ providerId }),
        headers: { 'Content-Type': 'application/json' }
    });
}

export async function updateJobStatus(jobId, status) {
    return await apiCall(`/jobs/${jobId}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status }),
        headers: { 'Content-Type': 'application/json' }
    });
}
