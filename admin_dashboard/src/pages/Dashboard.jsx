import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'

const weeklyAttendance = [
  { day: 'Mon', count: 45 }, { day: 'Tue', count: 52 }, { day: 'Wed', count: 48 },
  { day: 'Thu', count: 61 }, { day: 'Fri', count: 55 }, { day: 'Sat', count: 68 }, { day: 'Sun', count: 42 },
]
const revenueTrend = [
  { month: 'Jan', revenue: 1320000 }, { month: 'Feb', revenue: 1380000 }, { month: 'Mar', revenue: 1420000 },
  { month: 'Apr', revenue: 1500000 }, { month: 'May', revenue: 1650000 }, { month: 'Jun', revenue: 1720000 },
]
const membershipData = [
  { name: 'Premium', value: 120, color: '#22c55e' },
  { name: 'Standard', value: 95, color: '#3b82f6' },
  { name: 'Basic', value: 54, color: '#f59e0b' },
]
const peakHours = [
  { hour: '6AM', count: 12 }, { hour: '8AM', count: 35 }, { hour: '10AM', count: 28 },
  { hour: '12PM', count: 22 }, { hour: '2PM', count: 18 }, { hour: '4PM', count: 42 },
  { hour: '6PM', count: 58 }, { hour: '8PM', count: 30 },
]
const expiringMembers = [
  { name: 'Deepak Shrestha', plan: 'Premium', expiry: '2025-03-28', color: 'bg-green-500' },
  { name: 'Sushila Rai', plan: 'Standard', expiry: '2025-03-31', color: 'bg-blue-500' },
  { name: 'Krishna Thapa', plan: 'Basic', expiry: '2025-04-02', color: 'bg-yellow-500' },
  { name: 'Gita Gurung', plan: 'Standard', expiry: '2025-04-05', color: 'bg-purple-500' },
]
const recentActivity = [
  { name: 'Rajesh Sharma', action: 'Completed workout session', time: '2 minutes ago', color: 'bg-green-500' },
  { name: 'Sita Thapa', action: 'Membership renewed - Standard', time: '15 minutes ago', color: 'bg-teal-500' },
  { name: 'Bikash Gurung', action: 'Checked in via QR code', time: '1 hour ago', color: 'bg-blue-500' },
  { name: 'Anjali Rai', action: 'Updated progress weight: 68kg', time: '2 hours ago', color: 'bg-purple-500' },
  { name: 'Pramod Karki', action: 'Membership expired', time: '3 hours ago', color: 'bg-orange-500' },
]

const StatCard = ({ title, value, subtitle, icon, iconBg }) => (
  <div className="bg-white rounded-2xl border border-gray-100 p-5 flex items-start justify-between">
    <div>
      <p className="text-sm text-gray-500 mb-1">{title}</p>
      <p className="text-2xl font-bold text-gray-800">{value}</p>
      <p className="text-xs text-green-500 mt-1">{subtitle}</p>
    </div>
    <div className={`w-12 h-12 ${iconBg} rounded-xl flex items-center justify-center`}>{icon}</div>
  </div>
)

export default function Dashboard() {
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Dashboard Overview</h1>
        <p className="text-gray-400 text-sm mt-1">Welcome back! Here's what's happening with your gym today.</p>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <StatCard title="Total Members" value="269" subtitle="+12% from last month" iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>} />
        <StatCard title="Active Today" value="58" subtitle="+8% from last month" iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M13.49 5.48c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm-3.6 13.9l1-4.4 2.1 2v6h2v-7.5l-2.1-2 .6-3c1.3 1.5 3.3 2.5 5.5 2.5v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1l-5.2 2.2v4.7h2v-3.4l1.8-.7-1.6 8.1-4.9-1-.4 2 7 1.4z"/></svg>} />
        <StatCard title="Monthly Revenue" value="Rs 17,20,000" subtitle="+15% from last month" iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z"/></svg>} />
        <StatCard title="Avg. Attendance" value="53" subtitle="+5% from last month" iconBg="bg-green-50"
          icon={<svg viewBox="0 0 24 24" className="w-6 h-6 fill-green-500"><path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z"/></svg>} />
      </div>

      {/* Charts Row 1 */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Weekly Attendance</h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={weeklyAttendance}>
              <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <Tooltip />
              <Bar dataKey="count" fill="#4f46e5" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Revenue Trend</h3>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={revenueTrend}>
              <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af' }} />
              <Tooltip formatter={(v) => `Rs ${v.toLocaleString()}`} />
              <Line type="monotone" dataKey="revenue" stroke="#22c55e" strokeWidth={2} dot={{ fill: '#22c55e', r: 4 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Charts Row 2 */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Membership Clubs</h3>
          <div className="flex items-center gap-6">
            <ResponsiveContainer width={160} height={160}>
              <PieChart>
                <Pie data={membershipData} cx="50%" cy="50%" innerRadius={45} outerRadius={70} dataKey="value">
                  {membershipData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
            <div className="space-y-2">
              {membershipData.map((m) => (
                <div key={m.name} className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: m.color }} />
                  <span className="text-sm text-gray-600">{m.name}</span>
                  <span className="text-sm font-semibold text-gray-800 ml-auto">{m.value}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Peak Hour Analysis</h3>
          <ResponsiveContainer width="100%" height={160}>
            <BarChart data={peakHours}>
              <XAxis dataKey="hour" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
              <Tooltip />
              <Bar dataKey="count" fill="#a78bfa" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-2 gap-4">
        {/* Expiring */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-800">⚠ Memberships Expiring Soon</h3>
            <span className="text-xs text-gray-400">Next 7 days</span>
          </div>
          <div className="space-y-3">
            {expiringMembers.map((m) => (
              <div key={m.name} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-full ${m.color} flex items-center justify-center text-white text-xs font-bold`}>
                    {m.name[0]}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">{m.name}</p>
                    <p className="text-xs text-gray-400">{m.plan}</p>
                  </div>
                </div>
                <span className="text-xs text-red-500 font-medium">Expires {m.expiry}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h3 className="font-semibold text-gray-800 mb-4">Recent Member Activity</h3>
          <div className="space-y-3">
            {recentActivity.map((a) => (
              <div key={a.name} className="flex items-start gap-3">
                <div className={`w-8 h-8 rounded-full ${a.color} flex items-center justify-center text-white text-xs font-bold flex-shrink-0`}>
                  {a.name[0]}
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-800">{a.name}</p>
                  <p className="text-xs text-gray-400">{a.action}</p>
                  <p className="text-xs text-gray-300">{a.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}