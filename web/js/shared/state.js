export const state = {
    currentUser: null,
    allJobs: [],
    map: null,
    mapMarkers: [],
    socket: null
};

export function loadUser() {
    const userStr = localStorage.getItem('user');
    if (userStr) {
        state.currentUser = JSON.parse(userStr);
        return true;
    }
    return false;
}

export function saveUser(user) {
    state.currentUser = user;
    localStorage.setItem('user', JSON.stringify(user));
}

export function clearUser() {
    state.currentUser = null;
    localStorage.removeItem('user');
}
