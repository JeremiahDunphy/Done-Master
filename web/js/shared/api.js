import { API_BASE_URL } from './config.js';

export async function apiCall(endpoint, options = {}) {
    try {
        const headers = {
            ...options.headers,
        };

        if (!(options.body instanceof FormData)) {
            headers['Content-Type'] = 'application/json';
        }

        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers,
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

export async function uploadPhoto(file) {
    const formData = new FormData();
    formData.append('photo', file);

    const response = await fetch(`${API_BASE_URL}/upload`, {
        method: 'POST',
        body: formData,
    });

    if (!response.ok) {
        throw new Error('Photo upload failed');
    }

    const data = await response.json();
    return data.photoUrl;
}

export async function geocodeZipCode(zipCode) {
    const response = await fetch(
        `https://nominatim.openstreetmap.org/search?postalcode=${zipCode}&country=US&format=json&limit=1`,
        {
            headers: {
                'User-Agent': 'Done-App/1.0'
            }
        }
    );

    if (!response.ok) {
        throw new Error('Geocoding failed');
    }

    const data = await response.json();
    if (data.length === 0) {
        throw new Error('Invalid zip code');
    }

    return {
        latitude: parseFloat(data[0].lat),
        longitude: parseFloat(data[0].lon)
    };
}
