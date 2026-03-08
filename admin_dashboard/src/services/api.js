import API_BASE_URL from '../config'

// Get token from localStorage
const getToken = () => localStorage.getItem('admin_token')

// Base fetch with auth header
const authFetch = async (url, options = {}) => {
  const res = await fetch(`${API_BASE_URL}${url}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${getToken()}`,
      ...options.headers,
    },
  })

  // If token expired, logout
  if (res.status === 401) {
    localStorage.clear()
    window.location.href = '/login'
  }

  return res
}

// --- Members ---
export const getMembers = () => authFetch('/members/')

export const createMember = (data) => authFetch('/members/', {
  method: 'POST',
  body: JSON.stringify(data),
})

export const updateMember = (id, data) => authFetch(`/members/${id}/`, {
  method: 'PUT',
  body: JSON.stringify(data),
})

export const deleteMember = (id) => authFetch(`/members/${id}/`, {
  method: 'DELETE',
})