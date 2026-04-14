import { useState, useEffect } from 'react'
import API_BASE_URL from '../config.js'

export default function Settings() {
  const [form, setForm]     = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving]   = useState(false)
  const [saved, setSaved]     = useState(false)
  const [error, setError]     = useState(null)
  const [sending, setSending] = useState(false)
  const [reminderResult, setReminderResult] = useState(null)

  const token   = localStorage.getItem('admin_token')
  const headers = { 'Content-Type': 'application/json',
    Authorization: `Bearer ${token}` }

  useEffect(() => { fetchSettings() }, [])

  const fetchSettings = async () => {
    try {
      const res = await fetch(
        `${API_BASE_URL}/meals/settings/`, { headers })
      if (res.ok) {
        const data = await res.json()
        setForm(data)
      }
    } catch { setError('Cannot connect to server') }
    finally { setLoading(false) }
  }

  const handleSave = async () => {
    setSaving(true); setError(null)
    try {
      const res = await fetch(`${API_BASE_URL}/meals/settings/`, {
        method: 'PUT', headers, body: JSON.stringify(form)
      })
      if (res.ok) {
        setSaved(true)
        setTimeout(() => setSaved(false), 3000)
      } else {
        setError('Failed to save settings')
      }
    } catch { setError('Cannot connect to server') }
    finally { setSaving(false) }
  }

  const handleSendReminders = async () => {
    setSending(true)
    setReminderResult(null)
    try {
      const res = await fetch(`${API_BASE_URL}/admin/send-reminders/`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      })
      const data = await res.json()
      if (res.ok) {
        setReminderResult({ success: true, ...data })
      } else {
        setReminderResult({ success: false, message: 'Failed to send reminders' })
      }
    } catch {
      setReminderResult({ success: false, message: 'Cannot connect to server' })
    } finally {
      setSending(false)
    }
  }

  if (loading) return (
    <div className="flex items-center justify-center h-64">
      <div className="w-8 h-8 border-4 border-green-500
        border-t-transparent rounded-full animate-spin" />
    </div>
  )

  return (
    <div className="p-8 max-w-3xl">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Settings</h1>
        <p className="text-gray-400 text-sm mt-1">
          Manage your gym configuration and membership prices
        </p>
      </div>

      {/* Gym Info */}
      <Section title="Gym Information">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Gym Name">
            <input value={form?.gym_name || ''}
              onChange={e => setForm({ ...form, gym_name: e.target.value })}
              className={inputClass} />
          </Field>
          <Field label="Currency">
            <select value={form?.currency || 'Rs'}
              onChange={e => setForm({ ...form, currency: e.target.value })}
              className={inputClass}>
              <option value="Rs">Rs (Nepali Rupee)</option>
              <option value="USD">USD</option>
              <option value="INR">INR</option>
            </select>
          </Field>
        </div>
      </Section>

      {/* Membership Prices */}
      <Section title="Membership Prices">
        <p className="text-xs text-gray-400 mb-4">
          These prices are used when recording payments.
          Changing them won't affect past payments.
        </p>
        <div className="space-y-4">
          {[
            { label: 'Basic',    priceKey: 'basic_price',
              durKey: 'basic_duration', color: 'bg-yellow-500' },
            { label: 'Standard', priceKey: 'standard_price',
              durKey: 'standard_duration', color: 'bg-blue-500' },
            { label: 'Premium',  priceKey: 'premium_price',
              durKey: 'premium_duration', color: 'bg-green-500' },
          ].map(({ label, priceKey, durKey, color }) => (
            <div key={label}
              className="flex items-center gap-4 bg-gray-50
                rounded-xl p-4">
              <div className={`w-10 h-10 ${color} rounded-xl
                flex items-center justify-center text-white
                text-xs font-bold flex-shrink-0`}>
                {label[0]}
              </div>
              <div className="flex-1">
                <p className="text-sm font-semibold text-gray-700 mb-1">
                  {label}
                </p>
                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-gray-500">
                      {form?.currency || 'Rs'}
                    </span>
                    <input type="number"
                      value={form?.[priceKey] || ''}
                      onChange={e => setForm({
                        ...form,
                        [priceKey]: parseInt(e.target.value) || 0
                      })}
                      className="w-28 border border-gray-200 rounded-xl
                        px-3 py-2 text-sm focus:outline-none
                        focus:ring-2 focus:ring-green-400" />
                  </div>
                  <span className="text-sm text-gray-400">per</span>
                  <select value={form?.[durKey] || 1}
                    onChange={e => setForm({
                      ...form,
                      [durKey]: parseInt(e.target.value)
                    })}
                    className="border border-gray-200 rounded-xl
                      px-3 py-2 text-sm focus:outline-none
                      focus:ring-2 focus:ring-green-400">
                    <option value={1}>1 month</option>
                    <option value={3}>3 months</option>
                    <option value={6}>6 months</option>
                    <option value={12}>12 months</option>
                  </select>
                </div>
              </div>
            </div>
          ))}
        </div>
      </Section>

      {/* Email Reminders */}
      <Section title="Membership Expiry Reminders">
        <p className="text-sm text-gray-400 mb-4">
          Send email reminders to all active members whose membership expires within 7 days.
        </p>
        {reminderResult && (
          <div className={`mb-4 p-4 rounded-xl text-sm ${
            reminderResult.success
              ? 'bg-green-50 border border-green-200 text-green-700'
              : 'bg-red-50 border border-red-200 text-red-700'
          }`}>
            {reminderResult.success
              ? reminderResult.total_expiring === 0
                ? '✓ No members expiring within 7 days. No emails sent.'
                : `✓ Sent ${reminderResult.sent} reminder${reminderResult.sent !== 1 ? 's' : ''} successfully.${reminderResult.failed > 0 ? ` ${reminderResult.failed} failed.` : ''}`
              : `❌ ${reminderResult.message}`
            }
          </div>
        )}
        <button
          onClick={handleSendReminders}
          disabled={sending}
          className="flex items-center gap-2 bg-blue-500 hover:bg-blue-600
            disabled:opacity-50 text-white px-5 py-2.5 rounded-xl
            text-sm font-semibold transition">
          {sending
            ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> Sending...</>
            : <>📧 Send Expiry Reminders</>
          }
        </button>
      </Section>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200
          rounded-xl text-red-600 text-sm">{error}</div>
      )}

      {/* Save */}
      <div className="flex items-center gap-4 mt-6">
        <button onClick={handleSave} disabled={saving}
          className="bg-green-500 hover:bg-green-600 disabled:opacity-70
            text-white px-8 py-2.5 rounded-xl text-sm font-semibold
            transition">
          {saving ? 'Saving...' : 'Save Changes'}
        </button>
        {saved && (
          <span className="text-green-500 text-sm font-medium">
            ✓ Changes saved successfully!
          </span>
        )}
      </div>
    </div>
  )
}

const inputClass = `w-full border border-gray-200 rounded-xl px-4
  py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400`

function Section({ title, children }) {
  return (
    <div className="bg-white rounded-2xl border border-gray-100
      p-6 mb-4">
      <h3 className="font-semibold text-gray-800 mb-4">
        ○ {title}
      </h3>
      {children}
    </div>
  )
}

function Field({ label, children }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">
        {label}
      </label>
      {children}
    </div>
  )
}