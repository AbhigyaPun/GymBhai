import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'

const revenueData = [
  { month: 'Jan', revenue: 1320000, expenses: 450000 }, { month: 'Feb', revenue: 1380000, expenses: 460000 },
  { month: 'Mar', revenue: 1420000, expenses: 470000 }, { month: 'Apr', revenue: 1500000, expenses: 480000 },
  { month: 'May', revenue: 1650000, expenses: 490000 }, { month: 'Jun', revenue: 1720000, expenses: 500000 },
]
const membershipRevenue = [
  { name: 'Premium', value: 860000, color: '#22c55e' },
  { name: 'Standard', value: 570000, color: '#3b82f6' },
  { name: 'Basic', value: 290000, color: '#f59e0b' },
]
const membershipStats = [
  { plan: 'Basic', count: 54, color: '#f59e0b' },
  { plan: 'Standard', count: 95, color: '#3b82f6' },
  { plan: 'Premium', count: 120, color: '#22c55e' },
]
const upcoming = [
  { name: 'Rajesh Sharma', plan: 'Premium', amount: 'Rs 8,000', due: '2025-04-01', color: 'bg-green-500' },
  { name: 'Sita Thapa', plan: 'Standard', amount: 'Rs 5,000', due: '2025-04-02', color: 'bg-teal-500' },
  { name: 'Bikash Gurung', plan: 'Premium', amount: 'Rs 8,000', due: '2025-04-03', color: 'bg-blue-500' },
  { name: 'Anjali Rai', plan: 'Basic', amount: 'Rs 2,900', due: '2025-04-05', color: 'bg-purple-500' },
  { name: 'Pramod Karki', plan: 'Standard', amount: 'Rs 5,000', due: '2025-04-06', color: 'bg-orange-500' },
]
const expiring = [
  { name: 'Maya Tamang', expiry: '2025-04-02', status: 'Expiring', color: 'bg-pink-500' },
  { name: 'Suresh Shrestha', expiry: '2025-03-30', status: 'Expired', color: 'bg-indigo-500' },
  { name: 'Kopila Adhikari', expiry: '2025-04-05', status: 'Expiring', color: 'bg-yellow-500' },
  { name: 'Roshan Poudel', expiry: '2025-03-28', status: 'Expired', color: 'bg-red-500' },
]

export default function Financial() {
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Financial Reports</h1>
        <p className="text-gray-400 text-sm mt-1">Track revenue, expenses, and membership statistics</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Monthly Revenue', value: 'Rs 17,20,000', sub: '+15% last month', color: 'text-green-500' },
          { label: 'Monthly Expenses', value: 'Rs 2,70,000', sub: '+2% last month', color: 'text-red-500' },
          { label: 'Net Profit', value: '234', sub: '+18% last month', color: 'text-blue-500' },
          { label: 'Expiring Soon', value: '23', sub: 'Next 30 days', color: 'text-orange-500' },
        ].map((s) => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">{s.label}</p>
            <p className={`text-xl font-bold ${s.color}`}>{s.value}</p>
            <p className="text-xs text-green-500 mt-1">{s.sub}</p>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Revenue vs Expenses</h3>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={revenueData}>
              <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
              <Tooltip formatter={(v) => `Rs ${v.toLocaleString()}`} />
              <Line type="monotone" dataKey="revenue" stroke="#22c55e" strokeWidth={2} dot={{ r: 3 }} name="Revenue" />
              <Line type="monotone" dataKey="expenses" stroke="#ef4444" strokeWidth={2} dot={{ r: 3 }} name="Expenses" />
            </LineChart>
          </ResponsiveContainer>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Revenue by Membership Type</h3>
          <div className="flex items-center gap-6">
            <ResponsiveContainer width={160} height={160}>
              <PieChart>
                <Pie data={membershipRevenue} cx="50%" cy="50%" outerRadius={70} dataKey="value">
                  {membershipRevenue.map((e, i) => <Cell key={i} fill={e.color} />)}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-3">
              {membershipRevenue.map((m) => (
                <div key={m.name} className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: m.color }} />
                  <span className="text-sm text-gray-600">{m.name}</span>
                  <span className="text-sm font-semibold text-gray-800 ml-2">Rs {m.value.toLocaleString()}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Membership Statistics Bar */}
      <div className="bg-white rounded-2xl border border-gray-100 p-5 mb-6">
        <h3 className="font-semibold text-gray-800 mb-4">Membership Statistics</h3>
        <ResponsiveContainer width="100%" height={150}>
          <BarChart data={membershipStats}>
            <XAxis dataKey="plan" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
            <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
            <Tooltip />
            <Bar dataKey="count" radius={[6, 6, 0, 0]}>
              {membershipStats.map((e, i) => <Cell key={i} fill={e.color} />)}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Bottom Tables */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Upcoming Renewals</h3>
          <div className="space-y-3">
            {upcoming.map((u) => (
              <div key={u.name} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-full ${u.color} flex items-center justify-center text-white text-xs font-bold`}>{u.name[0]}</div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">{u.name}</p>
                    <p className="text-xs text-gray-400">{u.plan}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm font-semibold text-gray-800">{u.amount}</p>
                  <p className="text-xs text-gray-400">{u.due}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Memberships Expiring Soon</h3>
          <div className="space-y-3">
            {expiring.map((e) => (
              <div key={e.name} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-full ${e.color} flex items-center justify-center text-white text-xs font-bold`}>{e.name[0]}</div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">{e.name}</p>
                    <p className="text-xs text-gray-400">{e.expiry}</p>
                  </div>
                </div>
                <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${e.status === 'Expired' ? 'bg-red-100 text-red-600' : 'bg-yellow-100 text-yellow-600'}`}>{e.status}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}