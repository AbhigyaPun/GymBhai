/* eslint-disable */
import { useState, useEffect } from 'react'
import { LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'
import API_BASE_URL from '../config.js'

const PLAN_COLORS = { basic: '#f59e0b', standard: '#3b82f6', premium: '#22c55e' }
const METHODS = ['cash', 'transfer', 'esewa', 'khalti', 'other']
const DURATIONS = [1, 3, 6, 12]
const cap = (s) => s ? s[0].toUpperCase() + s.slice(1) : ''
const AVATAR_COLORS = ['bg-green-500', 'bg-blue-500', 'bg-purple-500', 'bg-orange-500', 'bg-pink-500', 'bg-teal-500']
const avatarColor = (name) => AVATAR_COLORS[(name?.charCodeAt(0) ?? 0) % AVATAR_COLORS.length]
const initials = (name) => {
  if (!name) return '?'
  const p = name.split(' ')
  return p.length >= 2 ? `${p[0][0]}${p[1][0]}`.toUpperCase() : name[0].toUpperCase()
}

export default function Financial() {
  const [stats, setStats] = useState(null)
  const [payments, setPayments] = useState([])
  const [members, setMembers] = useState([])
  const [settings, setSettings] = useState(null)
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState('')
  const [activeTab, setActiveTab] = useState('overview')
  const [form, setForm] = useState({
    member_id: '', plan: 'basic', amount: '',
    duration_months: 1, payment_method: 'cash', notes: ''
  })

  const token = localStorage.getItem('admin_token')
  const headers = { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }

  useEffect(() => { fetchAll() }, [])

  const fetchAll = async () => {
    try {
      const [statsRes, paymentsRes, membersRes, settingsRes] = await Promise.all([
        fetch(`${API_BASE_URL}/meals/payments/stats/`, { headers }),
        fetch(`${API_BASE_URL}/meals/payments/`, { headers }),
        fetch(`${API_BASE_URL}/members/`, { headers }),
        fetch(`${API_BASE_URL}/meals/settings/`, { headers }),
      ])
      if (statsRes.ok) setStats(await statsRes.json())
      if (paymentsRes.ok) setPayments(await paymentsRes.json())
      if (membersRes.ok) setMembers(await membersRes.json())
      if (settingsRes.ok) setSettings(await settingsRes.json())
    } catch (e) { console.error(e) }
    finally { setLoading(false) }
  }

  const getPlanPrice = (plan) => {
    if (!settings) return 0
    if (plan === 'basic') return settings.basic_price
    if (plan === 'standard') return settings.standard_price
    return settings.premium_price
  }

  const handlePlanChange = (plan) => {
    const price = getPlanPrice(plan) * form.duration_months
    setForm({ ...form, plan, amount: price || '' })
  }

  const handleDurationChange = (dur) => {
    const price = getPlanPrice(form.plan) * parseInt(dur)
    setForm({ ...form, duration_months: parseInt(dur), amount: price || '' })
  }

  const handleRecord = async () => {
    if (!form.member_id) { setFormError('Select a member'); return }
    if (!form.amount) { setFormError('Enter amount'); return }
    setSaving(true); setFormError('')
    try {
      const res = await fetch(`${API_BASE_URL}/meals/payments/`, {
        method: 'POST', headers,
        body: JSON.stringify({
          ...form,
          member_id: parseInt(form.member_id),
          amount: parseInt(form.amount),
        })
      })
      const data = await res.json()
      if (res.ok) {
        setShowModal(false)
        setForm({ member_id: '', plan: 'basic', amount: '', duration_months: 1, payment_method: 'cash', notes: '' })
        fetchAll()
      } else {
        setFormError(Object.values(data).flat().join(' '))
      }
    } catch { setFormError('Cannot connect to server') }
    finally { setSaving(false) }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this payment record?')) return
    await fetch(`${API_BASE_URL}/meals/payments/${id}/`, { method: 'DELETE', headers })
    setPayments(payments.filter(p => p.id !== id))
    fetchAll()
  }

  const currency = settings?.currency || 'Rs'

  const pieData = [
    { name: 'Basic', value: stats?.revenue_by_plan?.basic || 0, color: PLAN_COLORS.basic },
    { name: 'Standard', value: stats?.revenue_by_plan?.standard || 0, color: PLAN_COLORS.standard },
    { name: 'Premium', value: stats?.revenue_by_plan?.premium || 0, color: PLAN_COLORS.premium },
  ]

  const growth = stats && stats.last_month_revenue > 0
    ? (((stats.monthly_revenue - stats.last_month_revenue) / stats.last_month_revenue) * 100).toFixed(1)
    : null

  if (loading) return (
    <div className="flex items-center justify-center h-screen">
      <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin" />
    </div>
  )

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Financial Reports</h1>
          <p className="text-gray-400 text-sm mt-1">Track revenue, payments and membership statistics</p>
        </div>
        <button
          onClick={() => { setShowModal(true); setFormError('') }}
          className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition shadow"
        >
          + Record Payment
        </button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        {['overview', 'payments'].map(t => (
          <button key={t} onClick={() => setActiveTab(t)}
            className={`px-5 py-2.5 rounded-xl text-sm font-medium transition ${activeTab === t ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
            {cap(t)}
          </button>
        ))}
      </div>

      {/* Overview Tab */}
      {activeTab === 'overview' && (
        <>
          {/* Stats Cards */}
          <div className="grid grid-cols-4 gap-4 mb-6">
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <p className="text-sm text-gray-500 mb-1">Monthly Revenue</p>
              <p className="text-xl font-bold text-green-500">{currency} {(stats?.monthly_revenue || 0).toLocaleString()}</p>
              <p className="text-xs text-gray-400 mt-1">{growth ? `${growth > 0 ? '+' : ''}${growth}% vs last month` : 'No data last month'}</p>
            </div>
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <p className="text-sm text-gray-500 mb-1">Basic Revenue</p>
              <p className="text-xl font-bold text-yellow-500">{currency} {(stats?.revenue_by_plan?.basic || 0).toLocaleString()}</p>
              <p className="text-xs text-gray-400 mt-1">This month</p>
            </div>
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <p className="text-sm text-gray-500 mb-1">Standard Revenue</p>
              <p className="text-xl font-bold text-blue-500">{currency} {(stats?.revenue_by_plan?.standard || 0).toLocaleString()}</p>
              <p className="text-xs text-gray-400 mt-1">This month</p>
            </div>
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <p className="text-sm text-gray-500 mb-1">Premium Revenue</p>
              <p className="text-xl font-bold text-green-500">{currency} {(stats?.revenue_by_plan?.premium || 0).toLocaleString()}</p>
              <p className="text-xs text-gray-400 mt-1">This month</p>
            </div>
          </div>

          {/* Charts */}
          <div className="grid grid-cols-2 gap-4 mb-6">
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <h3 className="font-semibold text-gray-800 mb-4">Revenue Trend (6 Months)</h3>
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={stats?.monthly_trend || []}>
                  <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
                  <Tooltip formatter={(v) => `${currency} ${v.toLocaleString()}`} />
                  <Line type="monotone" dataKey="revenue" stroke="#22c55e" strokeWidth={2} dot={{ fill: '#22c55e', r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>

            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <h3 className="font-semibold text-gray-800 mb-4">Revenue by Plan</h3>
              <div className="flex items-center gap-6">
                <ResponsiveContainer width={160} height={160}>
                  <PieChart>
                    <Pie data={pieData} cx="50%" cy="50%" innerRadius={45} outerRadius={70} dataKey="value">
                      {pieData.map((e, i) => <Cell key={i} fill={e.color} />)}
                    </Pie>
                  </PieChart>
                </ResponsiveContainer>
                <div className="space-y-3">
                  {pieData.map(m => (
                    <div key={m.name} className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full" style={{ backgroundColor: m.color }} />
                      <span className="text-sm text-gray-600">{m.name}</span>
                      <span className="text-sm font-semibold text-gray-800 ml-2">{currency} {m.value.toLocaleString()}</span>
                    </div>
                  ))}
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
                <span className="text-xs text-gray-400">Next 30 days</span>
              </div>
              {(stats?.expiring_soon || []).length === 0 ? (
                <p className="text-sm text-gray-400 text-center py-4">No memberships expiring soon</p>
              ) : (
                <div className="space-y-3">
                  {(stats?.expiring_soon || []).map(m => (
                    <div key={m.id} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`w-8 h-8 rounded-full ${avatarColor(`${m.first_name} ${m.last_name}`)} flex items-center justify-center text-white text-xs font-bold`}>
                          {initials(`${m.first_name} ${m.last_name}`)}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-800">{m.first_name} {m.last_name}</p>
                          <p className="text-xs text-gray-400">{cap(m.membership)}</p>
                        </div>
                      </div>
                      <span className="text-xs text-red-500 font-medium">{m.expiry_date}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Recent Payments */}
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <h3 className="font-semibold text-gray-800 mb-4">Recent Payments</h3>
              {(stats?.recent_payments || []).length === 0 ? (
                <p className="text-sm text-gray-400 text-center py-4">No payments recorded yet</p>
              ) : (
                <div className="space-y-3">
                  {(stats?.recent_payments || []).map(p => (
                    <div key={p.id} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`w-8 h-8 rounded-full ${avatarColor(p.member_name)} flex items-center justify-center text-white text-xs font-bold`}>
                          {initials(p.member_name)}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-800">{p.member_name}</p>
                          <p className="text-xs text-gray-400">{cap(p.plan)} · {p.duration_months} month</p>
                        </div>
                      </div>
                      <span className="text-sm font-semibold text-green-600">{currency} {p.amount.toLocaleString()}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </>
      )}

      {/* Payments Tab */}
      {activeTab === 'payments' && (
        <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 className="font-semibold text-gray-800">All Payments</h3>
            <span className="text-xs text-gray-400">{payments.length} records</span>
          </div>
          {payments.length === 0 ? (
            <div className="text-center py-16 text-gray-400">
              <p className="text-sm">No payments recorded yet. Click "Record Payment" to add one.</p>
            </div>
          ) : (
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-50">
                  {['Member', 'Plan', 'Duration', 'Amount', 'Method', 'Date', ''].map(h => (
                    <th key={h} className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {payments.map(p => (
                  <tr key={p.id} className="border-b border-gray-50 hover:bg-gray-50 transition">
                    <td className="px-6 py-3">
                      <div className="flex items-center gap-3">
                        <div className={`w-8 h-8 rounded-full ${avatarColor(p.member_name)} flex items-center justify-center text-white text-xs font-bold`}>
                          {initials(p.member_name)}
                        </div>
                        <span className="text-sm font-medium text-gray-800">{p.member_name}</span>
                      </div>
                    </td>
                    <td className="px-6 py-3">
                      <span className="px-2.5 py-1 rounded-full text-xs font-semibold"
                        style={{ backgroundColor: PLAN_COLORS[p.plan] + '20', color: PLAN_COLORS[p.plan] }}>
                        {cap(p.plan)}
                      </span>
                    </td>
                    <td className="px-6 py-3 text-sm text-gray-600">{p.duration_months} month</td>
                    <td className="px-6 py-3 text-sm font-semibold text-green-600">{currency} {p.amount.toLocaleString()}</td>
                    <td className="px-6 py-3 text-sm text-gray-600">{cap(p.payment_method)}</td>
                    <td className="px-6 py-3 text-sm text-gray-400">
                      {new Date(p.paid_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </td>
                    <td className="px-6 py-3">
                      <button onClick={() => handleDelete(p.id)}
                        className="text-xs text-red-400 hover:text-red-600 border border-red-100 px-2.5 py-1 rounded-lg transition">
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}

      {/* Record Payment Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center px-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-bold text-gray-800">Record Payment</h2>
              <button onClick={() => setShowModal(false)} className="text-gray-400 hover:text-gray-600 text-xl">✕</button>
            </div>

            <div className="space-y-4">
              {/* Member */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Member *</label>
                <select
                  value={form.member_id}
                  onChange={e => setForm({ ...form, member_id: e.target.value })}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                >
                  <option value="">Select member...</option>
                  {members.map(m => (
                    <option key={m.id} value={m.id}>
                      {m.first_name} {m.last_name} — {cap(m.membership)}
                    </option>
                  ))}
                </select>
              </div>

              {/* Plan */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Plan *</label>
                <div className="flex gap-2">
                  {['basic', 'standard', 'premium'].map(p => (
                    <button
                      key={p}
                      onClick={() => handlePlanChange(p)}
                      className="flex-1 py-2.5 rounded-xl text-sm font-medium transition border"
                      style={form.plan === p
                        ? { backgroundColor: PLAN_COLORS[p], color: 'white', borderColor: 'transparent' }
                        : { backgroundColor: 'white', color: '#4b5563', borderColor: '#e5e7eb' }}
                    >
                      <div>{cap(p)}</div>
                      {settings && (
                        <div className="text-xs opacity-80">
                          {currency} {getPlanPrice(p).toLocaleString()}
                        </div>
                      )}
                    </button>
                  ))}
                </div>
              </div>

              {/* Duration */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Duration</label>
                <div className="flex gap-2">
                  {DURATIONS.map(d => (
                    <button
                      key={d}
                      onClick={() => handleDurationChange(d)}
                      className={`flex-1 py-2 rounded-xl text-sm font-medium transition border ${form.duration_months === d ? 'bg-green-500 text-white border-transparent' : 'text-gray-600 border-gray-200 hover:border-gray-300'}`}
                    >
                      {d}m
                    </button>
                  ))}
                </div>
              </div>

              {/* Amount */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Amount ({currency}) *</label>
                <input
                  type="number"
                  value={form.amount}
                  onChange={e => setForm({ ...form, amount: e.target.value })}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Auto-filled from plan price"
                />
                {settings && form.plan && (
                  <p className="text-xs text-green-600 mt-1">
                    Standard price: {currency} {(getPlanPrice(form.plan) * form.duration_months).toLocaleString()}
                  </p>
                )}
              </div>

              {/* Payment Method */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Payment Method</label>
                <select
                  value={form.payment_method}
                  onChange={e => setForm({ ...form, payment_method: e.target.value })}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                >
                  {METHODS.map(m => <option key={m} value={m}>{cap(m)}</option>)}
                </select>
              </div>

              {/* Notes */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Notes</label>
                <input
                  value={form.notes}
                  onChange={e => setForm({ ...form, notes: e.target.value })}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Optional"
                />
              </div>

              {formError && <p className="text-red-500 text-sm">{formError}</p>}
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setShowModal(false)}
                className="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition"
              >
                Cancel
              </button>
              <button
                onClick={handleRecord}
                disabled={saving}
                className="flex-1 bg-green-500 hover:bg-green-600 text-white py-2.5 rounded-xl text-sm font-semibold transition disabled:opacity-70"
              >
                {saving ? 'Saving...' : 'Record Payment'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}