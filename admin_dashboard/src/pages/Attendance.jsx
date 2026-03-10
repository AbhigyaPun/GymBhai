import { useState, useEffect } from 'react'
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'
import API_BASE_URL from '../config.js'

const COLORS = ['bg-green-500','bg-blue-500','bg-purple-500','bg-orange-500','bg-pink-500','bg-teal-500','bg-indigo-500','bg-yellow-500']

export default function Attendance() {
  const [records, setRecords] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [lastRefresh, setLastRefresh] = useState(new Date())

  useEffect(() => {
    fetchAttendance()
    // Auto-refresh every 30 seconds
    const interval = setInterval(fetchAttendance, 30000)
    return () => clearInterval(interval)
  }, [])

  const fetchAttendance = async () => {
    try {
      const token = localStorage.getItem('admin_token')
      const res = await fetch(`${API_BASE_URL}/attendance/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      if (res.ok) {
        const data = await res.json()
        setRecords(data)
        setLastRefresh(new Date())
        setError(null)
      } else {
        setError('Failed to load attendance data')
      }
    } catch (e) {
      setError('Cannot connect to server')
    } finally {
      setLoading(false)
    }
  }

  // ── Computed stats from real data ──────────────────────
  const today = new Date().toDateString()

  const todayRecords = records.filter(r =>
    new Date(r.checked_in).toDateString() === today
  )

  const weeklyData = (() => {
    const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
    const counts = Array(7).fill(0)
    records.forEach(r => {
      const d = new Date(r.checked_in)
      if (Date.now() - d.getTime() < 7 * 24 * 60 * 60 * 1000) {
        counts[d.getDay()]++
      }
    })
    return days.map((day, i) => ({ day, count: counts[i] }))
  })()

  const hourlyData = (() => {
    const hours = ['6AM','7AM','8AM','9AM','10AM','11AM','12PM','1PM','2PM','3PM','4PM','5PM','6PM','7PM','8PM','9PM']
    const counts = Array(16).fill(0)
    todayRecords.forEach(r => {
      const h = new Date(r.checked_in).getHours()
      const idx = h - 6
      if (idx >= 0 && idx < 16) counts[idx]++
    })
    return hours.map((time, i) => ({ time, count: counts[i] }))
  })()

  const peakHour = (() => {
    if (hourlyData.every(h => h.count === 0)) return '—'
    const peak = hourlyData.reduce((a, b) => a.count > b.count ? a : b)
    return peak.count > 0 ? peak.time : '—'
  })()

  const formatTime = (iso) =>
    new Date(iso).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })

  const formatDate = (iso) => {
    const d = new Date(iso)
    const isToday = d.toDateString() === today
    if (isToday) return `Today, ${formatTime(iso)}`
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + ` · ${formatTime(iso)}`
  }

  const getInitials = (name) => {
    if (!name) return '?'
    const parts = name.split(' ')
    return parts.length >= 2
      ? `${parts[0][0]}${parts[1][0]}`.toUpperCase()
      : name[0].toUpperCase()
  }

  const getColor = (name) => COLORS[(name?.charCodeAt(0) ?? 0) % COLORS.length]

  const capitalize = (s) => s ? s[0].toUpperCase() + s.slice(1) : ''

  return (
    <div className="p-8">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Attendance Tracking</h1>
          <p className="text-gray-400 text-sm mt-1">Monitor member check-ins and attendance patterns</p>
        </div>
        <button onClick={fetchAttendance}
          className="flex items-center gap-2 text-sm text-gray-500 hover:text-green-600 border border-gray-200 px-4 py-2 rounded-xl hover:border-green-300 transition">
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg>
          Refresh
          <span className="text-xs text-gray-300">{lastRefresh.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}</span>
        </button>
      </div>

      {/* Error */}
      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-xl text-red-600 text-sm">{error}</div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: "Today's Check-ins", value: loading ? '—' : `${todayRecords.length}`, sub: 'Total today', color: 'text-green-500' },
          { label: 'Total All Time', value: loading ? '—' : `${records.length}`, sub: 'All check-ins', color: 'text-blue-500' },
          { label: 'Unique Members', value: loading ? '—' : `${new Set(records.map(r => r.member_id)).size}`, sub: 'Have checked in', color: 'text-purple-500' },
          { label: 'Peak Hour Today', value: loading ? '—' : peakHour, sub: 'Busiest time', color: 'text-orange-500' },
        ].map((s) => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">{s.label}</p>
            <p className={`text-2xl font-bold ${s.color}`}>{s.value}</p>
            <p className="text-xs text-gray-400 mt-1">{s.sub}</p>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Weekly Check-ins (Last 7 Days)</h3>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={weeklyData}>
              <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <Tooltip />
              <Bar dataKey="count" fill="#4f46e5" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Hourly Distribution (Today)</h3>
          <ResponsiveContainer width="100%" height={180}>
            <LineChart data={hourlyData}>
              <XAxis dataKey="time" axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: '#9ca3af' }} interval={1} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
              <Tooltip />
              <Line type="monotone" dataKey="count" stroke="#22c55e" strokeWidth={2} dot={{ fill: '#22c55e', r: 3 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Check-ins Table */}
      <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
          <h3 className="font-semibold text-gray-800">Recent Check-ins</h3>
          <span className="text-xs text-gray-400">{records.length} total records</span>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-16">
            <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin"></div>
          </div>
        ) : records.length === 0 ? (
          <div className="text-center py-16 text-gray-400">
            <svg viewBox="0 0 24 24" className="w-12 h-12 fill-gray-200 mx-auto mb-3"><path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.11 0-1.99.9-1.99 2L3 19c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11zM7 10h5v5H7z"/></svg>
            <p className="text-sm">No check-ins yet. Scan a member QR to get started.</p>
          </div>
        ) : (
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-50">
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Member</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Membership</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Check-in Time</th>
              </tr>
            </thead>
            <tbody>
              {records.map((r) => (
                <tr key={r.id} className="border-b border-gray-50 hover:bg-gray-50 transition">
                  <td className="px-6 py-3">
                    <div className="flex items-center gap-3">
                      <div className={`w-8 h-8 rounded-full ${getColor(r.member_name)} flex items-center justify-center text-white text-xs font-bold`}>
                        {getInitials(r.member_name)}
                      </div>
                      <span className="text-sm font-medium text-gray-800">{r.member_name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${
                      r.membership === 'premium' ? 'bg-yellow-100 text-yellow-700' :
                      r.membership === 'standard' ? 'bg-blue-100 text-blue-700' :
                      'bg-gray-100 text-gray-600'
                    }`}>
                      {capitalize(r.membership)}
                    </span>
                  </td>
                  <td className="px-6 py-3 text-sm text-gray-600">{formatDate(r.checked_in)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}