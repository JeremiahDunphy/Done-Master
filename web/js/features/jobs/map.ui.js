import { state } from '../../shared/state.js';
import { displayJobs } from './jobs.ui.js';

export function initMap() {
    if (!state.map) {
        state.map = L.map('map').setView([37.7749, -122.4194], 10);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(state.map);
    }
}

export function toggleMapView() {
    const mapContainer = document.getElementById('map-container');
    const toggleBtn = document.getElementById('map-toggle-btn');

    if (mapContainer.style.display === 'none') {
        mapContainer.style.display = 'block';
        toggleBtn.textContent = '📋 List View';

        if (!state.map) {
            initMap();
        }

        displayJobsOnMap(state.allJobs);
        setTimeout(() => state.map.invalidateSize(), 100);
    } else {
        mapContainer.style.display = 'none';
        toggleBtn.textContent = '🗺️ Map View';
    }
}

export function displayJobsOnMap(jobs) {
    state.mapMarkers.forEach(marker => marker.remove());
    state.mapMarkers = [];

    if (jobs.length === 0) return;

    jobs.forEach(job => {
        if (job.latitude && job.longitude) {
            const marker = L.marker([job.latitude, job.longitude])
                .addTo(state.map)
                .bindPopup(`
                    <strong>${job.title}</strong><br>
                    $${job.price.toFixed(2)}/day<br>
                    <small>${job.description.substring(0, 100)}...</small>
                `);
            state.mapMarkers.push(marker);
        }
    });

    if (state.mapMarkers.length > 0) {
        const group = L.featureGroup(state.mapMarkers);
        state.map.fitBounds(group.getBounds().pad(0.1));
    }
}

// Expose to window
window.toggleMapView = toggleMapView;
