import { BarChart, Bar, LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'

const weeklyData = [
  { day: 'Mon', count: 45 }, { day: 'Tue', count: 52 }, { day: 'Wed', count: 38 },
  { day: 'Thu', count: 61 }, { day: 'Fri', count: 55 }, { day: 'Sat', count: 68 }, { day: 'Sun', count: 30 },
]
const hourlyData = [
  { time: '6AM', count: 5 }, { time: '8AM', count: 22 }, { time: '10AM', count: 18 },
  { time: '12PM', count: 12 }, { time: '2PM', count: 8 }, { time: '4PM', count: 28 },
  { time: '6PM', count: 42 }, { time: '8PM', count: 20 }, { time: '10PM', count: 6 },
]
const recentCheckins = [
  { name: 'Rajesh Sharma', initials: 'RS', time: '10:42 AM', duration: '1h 20m', status: 'Active', color: 'bg-green-500' },
  { name: 'Sita Thapa', initials: 'ST', time: '10:17 AM', duration: '1h 45m', status: 'Active', color: 'bg-teal-500' },
  { name: 'Bikash Gurung', initials: 'BG', time: '10:15 AM', duration: '1h 47m', status: 'Checked Out', color: 'bg-blue-500' },
  { name: 'Anjali Rai', initials: 'AR', time: '09:53 AM', duration: '2h 09m', status: 'Checked Out', color: 'bg-purple-500' },
  { name: 'Pramod Karki', initials: 'PK', time: '09:38 AM', duration: '2h 24m', status: 'Denied', color: 'bg-orange-500' },
  { name: 'Maya Tamang', initials: 'MT', time: '09:22 AM', duration: '2h 40m', status: 'Checked Out', color: 'bg-pink-500' },
  { name: 'Suresh Shrestha', initials: 'SS', time: '09:15 AM', duration: '2h 47m', status: 'Checked Out', color: 'bg-indigo-500' },
  { name: 'Kopila Adhikari', initials: 'KA', time: '08:58 AM', duration: '3h 04m', status: 'Checked Out', color: 'bg-yellow-500' },
]

const statusBadge = (status) => {
  const styles = { Active: 'bg-green-100 text-green-700', 'Checked Out': 'bg-gray-100 text-gray-600', Denied: 'bg-red-100 text-red-600' }
  return <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${styles[status]}`}>{status}</span>
}

export default function Attendance() {
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Attendance Tracking</h1>
        <p className="text-gray-400 text-sm mt-1">Monitor member check-ins and attendance patterns</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Currently In Gym', value: '24', sub: '+4 from last hour', color: 'text-green-500' },
          { label: "Today's Check-ins", value: '58', sub: '+8% from yesterday', color: 'text-blue-500' },
          { label: 'Avg. Duration', value: '82 min', sub: '+5 min from last week', color: 'text-purple-500' },
          { label: 'Peak Hour', value: '6 PM', sub: '42 members at peak', color: 'text-orange-500' },
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
          <h3 className="font-semibold text-gray-800 mb-4">Weekly Check-ins</h3>
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
              <XAxis dataKey="time" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#9ca3af' }} />
              <Tooltip />
              <Line type="monotone" dataKey="count" stroke="#22c55e" strokeWidth={2} dot={{ fill: '#22c55e', r: 3 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Check-ins Table */}
      <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100">
          <h3 className="font-semibold text-gray-800">Recent Check-ins</h3>
        </div>
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-50">
              <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Member</th>
              <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Check-in Time</th>
              <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Duration</th>
              <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {recentCheckins.map((c) => (
              <tr key={c.name} className="border-b border-gray-50 hover:bg-gray-50 transition">
                <td className="px-6 py-3">
                  <div className="flex items-center gap-3">
                    <div className={`w-8 h-8 rounded-full ${c.color} flex items-center justify-center text-white text-xs font-bold`}>{c.initials}</div>
                    <span className="text-sm font-medium text-gray-800">{c.name}</span>
                  </div>
                </td>
                <td className="px-6 py-3 text-sm text-gray-600">{c.time}</td>
                <td className="px-6 py-3 text-sm text-gray-600">{c.duration}</td>
                <td className="px-6 py-3">{statusBadge(c.status)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}