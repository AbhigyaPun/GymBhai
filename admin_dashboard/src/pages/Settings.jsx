import { useState } from 'react'

export default function Settings() {
  const [form, setForm] = useState({
    gymName: 'Gym Bhai Fitness Centre',
    email: 'contact@gymbhai.com',
    phone: '+977 1-4345-990',
    address: 'Thamel, Kathmandu, Nepal',
    monFri: '5:00 AM - 10:00 PM',
    saturday: '6:00 AM - 10:00 PM',
    sunday: '7:00 AM - 8:00 PM',
    basicPrice: '2800',
    basicDuration: '1 month',
    standardPrice: '4800',
    standardDuration: '1 month',
    premiumPrice: '8500',
    premiumDuration: '1 month',
    emailNotifications: true,
    membershipExpiry: true,
    paymentReminders: false,
  })
  const [saved, setSaved] = useState(false)

  const handleSave = () => {
    setSaved(true)
    setTimeout(() => setSaved(false), 3000)
  }

  const toggle = (key) => setForm({ ...form, [key]: !form[key] })

  return (
    <div className="p-8 max-w-3xl">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Settings</h1>
        <p className="text-gray-400 text-sm mt-1">Manage your gym's configuration and preferences</p>
      </div>

      {/* Gym Info */}
      <Section title="Gym Information">
        <div className="grid grid-cols-2 gap-4">
          <Field label="Gym Name">
            <input value={form.gymName} onChange={e => setForm({...form, gymName: e.target.value})} className={inputClass} />
          </Field>
          <Field label="Email">
            <input value={form.email} onChange={e => setForm({...form, email: e.target.value})} className={inputClass} />
          </Field>
          <Field label="Phone">
            <input value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} className={inputClass} />
          </Field>
          <Field label="Address">
            <input value={form.address} onChange={e => setForm({...form, address: e.target.value})} className={inputClass} />
          </Field>
        </div>
      </Section>

      {/* Operating Hours */}
      <Section title="Operating Hours">
        <div className="space-y-3">
          {[
            { label: 'Monday - Friday', key: 'monFri' },
            { label: 'Saturday', key: 'saturday' },
            { label: 'Sunday', key: 'sunday' },
          ].map(({ label, key }) => (
            <div key={key} className="flex items-center gap-4">
              <span className="text-sm text-gray-600 w-36">{label}</span>
              <input value={form[key]} onChange={e => setForm({...form, [key]: e.target.value})}
                className="flex-1 border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-400" />
            </div>
          ))}
        </div>
      </Section>

      {/* Membership Plans */}
      <Section title="Membership Plans">
        <div className="space-y-3">
          {[
            { label: 'Basic', priceKey: 'basicPrice', durKey: 'basicDuration' },
            { label: 'Standard', priceKey: 'standardPrice', durKey: 'standardDuration' },
            { label: 'Premium', priceKey: 'premiumPrice', durKey: 'premiumDuration' },
          ].map(({ label, priceKey, durKey }) => (
            <div key={label} className="flex items-center gap-4">
              <span className="text-sm font-medium text-gray-700 w-24">{label}</span>
              <div className="flex items-center gap-2 flex-1">
                <span className="text-sm text-gray-500">Rs</span>
                <input value={form[priceKey]} onChange={e => setForm({...form, [priceKey]: e.target.value})}
                  className="w-28 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-400" />
              </div>
              <select value={form[durKey]} onChange={e => setForm({...form, [durKey]: e.target.value})}
                className="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                <option>1 month</option>
                <option>3 months</option>
                <option>6 months</option>
                <option>1 year</option>
              </select>
            </div>
          ))}
        </div>
      </Section>

      {/* Notifications */}
      <Section title="Notifications">
        <div className="space-y-4">
          {[
            { key: 'emailNotifications', label: 'Email Notifications', desc: 'Send email notifications for important updates' },
            { key: 'membershipExpiry', label: 'Membership Expiry Alerts', desc: 'Get notified when memberships are about to expire' },
            { key: 'paymentReminders', label: 'Payment Reminders', desc: 'Send payment reminders to members' },
          ].map(({ key, label, desc }) => (
            <div key={key} className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-800">{label}</p>
                <p className="text-xs text-gray-400">{desc}</p>
              </div>
              <button onClick={() => toggle(key)}
                className={`w-12 h-6 rounded-full transition-colors relative ${form[key] ? 'bg-green-500' : 'bg-gray-200'}`}>
                <div className={`w-5 h-5 bg-white rounded-full absolute top-0.5 transition-transform shadow ${form[key] ? 'translate-x-6' : 'translate-x-0.5'}`} />
              </button>
            </div>
          ))}
        </div>
      </Section>

      {/* Security */}
      <Section title="Security">
        <div className="space-y-3">
          <button className="text-sm text-green-600 hover:text-green-700 font-medium">Change Admin Password</button>
          <br />
          <button className="text-sm text-green-600 hover:text-green-700 font-medium">Two-Factor Authentication</button>
          <br />
          <button className="text-sm text-green-600 hover:text-green-700 font-medium">Access Logs</button>
        </div>
      </Section>

      {/* Save */}
      <div className="flex items-center gap-4 mt-6">
        <button onClick={handleSave}
          className="bg-green-500 hover:bg-green-600 text-white px-8 py-2.5 rounded-xl text-sm font-semibold transition">
          Save Changes
        </button>
        {saved && <span className="text-green-500 text-sm font-medium">✓ Changes saved successfully!</span>}
      </div>
    </div>
  )
}

const inputClass = "w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"

function Section({ title, children }) {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-4">
      <h3 className="font-semibold text-gray-800 mb-4">○ {title}</h3>
      {children}
    </div>
  )
}

function Field({ label, children }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
      {children}
    </div>
  )
}