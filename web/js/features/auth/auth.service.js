import { apiCall } from '../../shared/api.js';
import { saveUser } from '../../shared/state.js';

export async function register(email, password, name, role) {
    const user = await apiCall('/auth/register', {
        method: 'POST',
        body: JSON.stringify({ email, password, name, role }),
    });
    saveUser(user);
    return user;
}

export async function login(email, password) {
    const user = await apiCall('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
    });
    saveUser(user);
    return user;
}
