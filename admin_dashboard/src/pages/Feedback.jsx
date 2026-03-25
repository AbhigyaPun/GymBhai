import { useState, useEffect } from 'react'
import API_BASE_URL from '../config.js'

const CATEGORIES = ['All', 'General', 'Equipment', 'Cleanliness', 'Staff', 'Classes', 'Other']
const STATUSES   = ['All', 'Pending', 'Reviewed', 'Resolved']

const statusColor = (s) => {
  const map = {
    pending:  'bg-yellow-100 text-yellow-700',
    reviewed: 'bg-green-100 text-green-700',
    resolved: 'bg-blue-100 text-blue-700',
  }
  return map[s] || 'bg-gray-100 text-gray-600'
}
const membershipColor = (m) => {
  const map = {
    premium:  'bg-yellow-100 text-yellow-700',
    standard: 'bg-blue-100 text-blue-700',
    basic:    'bg-gray-100 text-gray-600',
  }
  return map[m] || 'bg-gray-100 text-gray-600'
}
const COLORS = ['bg-green-500','bg-blue-500','bg-purple-500',
  'bg-orange-500','bg-pink-500','bg-teal-500']
const avatarColor = (name) =>
  COLORS[(name?.charCodeAt(0) ?? 0) % COLORS.length]
const cap  = (s) => s ? s[0].toUpperCase() + s.slice(1) : ''
const initials = (name) => {
  if (!name) return '?'
  const parts = name.split(' ')
  return parts.length >= 2
    ? `${parts[0][0]}${parts[1][0]}`.toUpperCase()
    : name[0].toUpperCase()
}

const Stars = ({ rating }) => (
  <div className="flex gap-0.5">
    {[1,2,3,4,5].map(i => (
      <svg key={i} viewBox="0 0 24 24"
        className={`w-3.5 h-3.5 ${i <= rating ? 'fill-yellow-400' : 'fill-gray-200'}`}>
        <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2
          9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
      </svg>
    ))}
  </div>
)

export default function Feedback() {
  const [feedbacks, setFeedbacks]       = useState([])
  const [loading, setLoading]           = useState(true)
  const [error, setError]               = useState(null)
  const [categoryFilter, setCategoryFilter] = useState('All')
  const [statusFilter, setStatusFilter]     = useState('All')

  const token   = localStorage.getItem('admin_token')
  const headers = { 'Content-Type': 'application/json',
    Authorization: `Bearer ${token}` }

  useEffect(() => { fetchFeedbacks() }, [])

  const fetchFeedbacks = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/feedback/`, { headers })
      if (res.ok) setFeedbacks(await res.json())
      else setError('Failed to load feedback')
    } catch { setError('Cannot connect to server') }
    finally { setLoading(false) }
  }

  const updateStatus = async (id, newStatus) => {
    const res  = await fetch(`${API_BASE_URL}/admin/feedback/${id}/`, {
      method: 'PATCH', headers,
      body: JSON.stringify({ status: newStatus })
    })
    const data = await res.json()
    if (res.ok)
      setFeedbacks(feedbacks.map(f => f.id === id ? data : f))
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this feedback?')) return
    await fetch(`${API_BASE_URL}/admin/feedback/${id}/`,
      { method: 'DELETE', headers })
    setFeedbacks(feedbacks.filter(f => f.id !== id))
  }

  const filtered = feedbacks.filter(f => {
    const matchCat = categoryFilter === 'All' ||
      f.category.toLowerCase() === categoryFilter.toLowerCase()
    const matchSt  = statusFilter === 'All' ||
      f.status.toLowerCase() === statusFilter.toLowerCase()
    return matchCat && matchSt
  })

  const avgRating = feedbacks.length
    ? (feedbacks.reduce((a, b) => a + b.rating, 0) / feedbacks.length).toFixed(1)
    : '0.0'

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Feedback Management</h1>
        <p className="text-gray-400 text-sm mt-1">Review and manage member feedback</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Feedback', value: feedbacks.length, color: 'text-gray-800' },
          { label: 'Avg Rating', value: avgRating, color: 'text-yellow-500' },
          { label: 'Pending', value: feedbacks.filter(f => f.status === 'pending').length, color: 'text-yellow-500' },
          { label: 'Resolved', value: feedbacks.filter(f => f.status === 'resolved').length, color: 'text-green-500' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">{s.label}</p>
            <p className={`text-3xl font-bold ${s.color}`}>{s.value}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex items-center gap-6 mb-6 flex-wrap">
        <div>
          <p className="text-xs text-gray-400 mb-1">Category</p>
          <div className="flex gap-2 flex-wrap">
            {CATEGORIES.map(c => (
              <button key={c} onClick={() => setCategoryFilter(c)}
                className={`px-3 py-1.5 rounded-xl text-xs font-medium transition
                  ${categoryFilter === c
                    ? 'bg-green-500 text-white'
                    : 'bg-white border border-gray-200 text-gray-600'}`}>
                {c}
              </button>
            ))}
          </div>
        </div>
        <div>
          <p className="text-xs text-gray-400 mb-1">Status</p>
          <div className="flex gap-2">
            {STATUSES.map(s => (
              <button key={s} onClick={() => setStatusFilter(s)}
                className={`px-3 py-1.5 rounded-xl text-xs font-medium transition
                  ${statusFilter === s
                    ? 'bg-green-500 text-white'
                    : 'bg-white border border-gray-200 text-gray-600'}`}>
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-xl
          text-red-600 text-sm">{error}</div>
      )}

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-4 border-green-500
            border-t-transparent rounded-full animate-spin" />
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-100
          p-16 text-center text-gray-400">
          <p className="text-lg font-medium mb-2">No feedback yet</p>
          <p className="text-sm">Member feedback will appear here</p>
        </div>
      ) : (
        <div className="space-y-4">
          {filtered.map(f => (
            <div key={f.id}
              className="bg-white rounded-2xl border border-gray-100 p-5">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-full ${avatarColor(f.member_name)}
                    flex items-center justify-center text-white text-sm font-bold`}>
                    {initials(f.member_name)}
                  </div>
                  <div>
                    <p className="font-semibold text-gray-800">{f.member_name}</p>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className={`text-xs font-semibold px-2 py-0.5
                        rounded-full ${membershipColor(f.membership)}`}>
                        {cap(f.membership)}
                      </span>
                      <span className="text-xs text-gray-400">
                        {new Date(f.created_at).toLocaleDateString('en-US',
                          { month: 'short', day: 'numeric', year: 'numeric' })}
                      </span>
                      <span className="text-xs text-blue-500">{cap(f.category)}</span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <Stars rating={f.rating} />
                  <span className={`text-xs font-semibold px-2.5 py-1
                    rounded-full ${statusColor(f.status)}`}>
                    {cap(f.status)}
                  </span>
                </div>
              </div>

              <p className="text-sm text-gray-600 mb-3">{f.message}</p>

              <div className="flex gap-2">
                {f.status === 'pending' && (
                  <button onClick={() => updateStatus(f.id, 'reviewed')}
                    className="text-xs text-green-600 font-medium
                      hover:text-green-700 border border-green-200
                      px-3 py-1.5 rounded-lg transition">
                    Mark Reviewed
                  </button>
                )}
                {f.status === 'reviewed' && (
                  <button onClick={() => updateStatus(f.id, 'resolved')}
                    className="text-xs text-blue-600 font-medium
                      hover:text-blue-700 border border-blue-200
                      px-3 py-1.5 rounded-lg transition">
                    Mark Resolved
                  </button>
                )}
                {f.status === 'resolved' && (
                  <button onClick={() => updateStatus(f.id, 'pending')}
                    className="text-xs text-yellow-600 font-medium
                      hover:text-yellow-700 border border-yellow-200
                      px-3 py-1.5 rounded-lg transition">
                    Reopen
                  </button>
                )}
                <button onClick={() => handleDelete(f.id)}
                  className="text-xs text-red-400 font-medium
                    hover:text-red-600 border border-red-100
                    px-3 py-1.5 rounded-lg transition">
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}