/* eslint-disable */
import { useState, useEffect } from 'react'
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'
import API_BASE_URL from '../config.js'

const PLAN_COLORS = {
  basic: '#f59e0b',
  standard: '#3b82f6',
  premium: '#22c55e',
}

const AVATAR_COLORS = ['bg-green-500', 'bg-teal-500', 'bg-blue-500', 'bg-purple-500', 'bg-orange-500', 'bg-pink-500']
const avatarColor = (name) => AVATAR_COLORS[(name?.charCodeAt(0) ?? 0) % AVATAR_COLORS.length]
const initials = (name) => {
  if (!name) return '?'
  const p = name.split(' ')
  return p.length >= 2 ? `${p[0][0]}${p[1][0]}`.toUpperCase() : name[0].toUpperCase()
}
const cap = (s) => s ? s[0].toUpperCase() + s.slice(1) : ''

const formatTime = (iso) => {
  if (!iso) return ''
  const d = new Date(iso)
  return d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
}

const timeAgo = (iso) => {
  if (!iso) return ''
  const diff = Math.floor((Date.now() - new Date(iso)) / 1000)
  if (diff < 60) return 'Just now'
  if (diff < 3600) return `${Math.floor(diff / 60)} min ago`
  if (diff < 86400) return `${Math.floor(diff / 3600)} hr ago`
  return `${Math.floor(diff / 86400)} days ago`
}

const StatCard = ({ title, value, subtitle, icon, iconBg, subtitleColor }) => (
  <div className="bg-white rounded-2xl border border-gray-100 p-5 flex items-start justify-between">
    <div>
      <p className="text-sm text-gray-500 mb-1">{title}</p>
      <p className="text-2xl font-bold text-gray-800">{value}</p>
      <p className={`text-xs mt-1 ${subtitleColor || 'text-green-500'}`}>{subtitle}</p>
    </div>
    <div className={`w-12 h-12 ${iconBg} rounded-xl flex items-center justify-center`}>{icon}</div>
  </div>
)

export default function Dashboard() {
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [lastRefresh, setLastRefresh] = useState(new Date())

  const token = localStorage.getItem('admin_token')
  const headers = { Authorization: `Bearer ${token}` }

  const fetchStats = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/dashboard/stats/`, { headers })
      if (res.ok) {
        setStats(await res.json())
        setLastRefresh(new Date())
        setError(null)
      } else {
        setError('Failed to load dashboard data')
      }
    } catch {
      setError('Cannot connect to server')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchStats()
    const interval = setInterval(fetchStats, 60000)
    return () => clearInterval(interval)
  }, [])

  if (loading) return (
    <div className="flex items-center justify-center h-screen">
      <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin" />
    </div>
  )

  if (error) return (
    <div className="p-8">
      <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
        <p className="text-red-600 mb-4">{error}</p>
        <button onClick={fetchStats} className="bg-green-500 text-white px-4 py-2 rounded-xl text-sm">
          Retry
        </button>
      </div>
    </div>
  )

  const membershipData = [
    { name: 'Basic',    value: stats?.membership_breakdown?.basic    || 0, color: PLAN_COLORS.basic },
    { name: 'Standard', value: stats?.membership_breakdown?.standard || 0, color: PLAN_COLORS.standard },
    { name: 'Premium',  value: stats?.membership_breakdown?.premium  || 0, color: PLAN_COLORS.premium },
  ]

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Dashboard Overview</h1>
          <p className="text-gray-400 text-sm mt-1">
            Welcome back! Here's what's happening with your gym today.
          </p>
        </div>
        <button
          onClick={fetchStats}
          className="flex items-center gap-2 text-sm text-gray-500 hover:text-green-600 border border-gray-200 px-4 py-2 rounded-xl hover:border-green-300 transition"
        >
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current">
            <path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z" />
          </svg>
          Refresh
          <span className="text-xs text-gray-300">
            {lastRefresh.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
          </span>
        </button>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <StatCard
          title="Total Members"
          value={stats?.total_members || 0}
          subtitle={`+${stats?.new_this_month || 0} this month`}
          iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z" /></svg>}
        />
        <StatCard
          title="Active Members"
          value={stats?.active_members || 0}
          subtitle="Currently active"
          iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M13.49 5.48c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm-3.6 13.9l1-4.4 2.1 2v6h2v-7.5l-2.1-2 .6-3c1.3 1.5 3.3 2.5 5.5 2.5v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1l-5.2 2.2v4.7h2v-3.4l1.8-.7-1.6 8.1-4.9-1-.4 2 7 1.4z" /></svg>}
        />
        <StatCard
          title="Monthly Revenue"
          value={`Rs ${(stats?.monthly_revenue || 0).toLocaleString()}`}
          subtitle="This month"
          iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z" /></svg>}
        />
        <StatCard
          title="Today's Check-ins"
          value={stats?.today_checkins || 0}
          subtitle={stats?.peak_hour ? `Peak: ${stats.peak_hour}` : 'No check-ins yet'}
          iconBg="bg-green-50"
          subtitleColor="text-blue-500"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z" /></svg>}
        />
      </div>

      {/* Charts Row 1 */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        {/* Weekly Attendance */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Weekly Attendance</h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={stats?.weekly_attendance || []}>
              <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <Tooltip />
              <Bar dataKey="count" fill="#4f46e5" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Membership Breakdown */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Membership Breakdown</h3>
          <div className="flex items-center gap-6">
            <ResponsiveContainer width={160} height={160}>
              <PieChart>
                <Pie data={membershipData} cx="50%" cy="50%" innerRadius={45} outerRadius={70} dataKey="value">
                  {membershipData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-3">
              {membershipData.map(m => (
                <div key={m.name} className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: m.color }} />
                  <span className="text-sm text-gray-600">{m.name}</span>
                  <span className="text-sm font-semibold text-gray-800 ml-auto">{m.value}</span>
                </div>
              ))}
              <div className="pt-1 border-t border-gray-100">
                <span className="text-xs text-gray-400">Total: {stats?.total_members || 0} members</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-2 gap-4">
        {/* Expiring Soon */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-800">⚠ Memberships Expiring Soon</h3>
            <span className="text-xs text-gray-400">Next 7 days</span>
          </div>
          {(stats?.expiring_soon || []).length === 0 ? (
            <div className="text-center py-8 text-gray-400">
              <p className="text-sm">No memberships expiring in the next 7 days</p>
            </div>
          ) : (
            <div className="space-y-3">
              {(stats?.expiring_soon || []).map(m => (
                <div key={m.id} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`w-8 h-8 rounded-full ${avatarColor(m.name)} flex items-center justify-center text-white text-xs font-bold`}>
                      {initials(m.name)}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-800">{m.name}</p>
                      <p className="text-xs text-gray-400">{cap(m.membership)}</p>
                    </div>
                  </div>
                  <span className="text-xs text-red-500 font-medium">Expires {m.expiry_date}</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recent Check-ins */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Recent Check-ins</h3>
          {(stats?.recent_checkins || []).length === 0 ? (
            <div className="text-center py-8 text-gray-400">
              <p className="text-sm">No check-ins yet today</p>
            </div>
          ) : (
            <div className="space-y-3">
              {(stats?.recent_checkins || []).map((a, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className={`w-8 h-8 rounded-full ${avatarColor(a.name)} flex items-center justify-center text-white text-xs font-bold flex-shrink-0`}>
                    {initials(a.name)}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">{a.name}</p>
                    <p className="text-xs text-gray-400">{cap(a.membership)} member</p>
                    <p className="text-xs text-gray-300">{timeAgo(a.checked_in)}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}