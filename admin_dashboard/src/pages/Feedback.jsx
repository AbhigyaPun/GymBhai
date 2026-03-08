import { useState } from 'react'

const feedbacks = [
  { id: 1, name: 'Rajesh Sharma', initials: 'RS', type: 'Premium', category: 'General', rating: 5, date: '2024-01-15', status: 'Reviewed', message: 'The new equipment is excellent! However, some of the older dumbbells need replacement.', color: 'bg-green-500' },
  { id: 2, name: 'Sita Thapa', initials: 'ST', type: 'Standard', category: 'Staff', rating: 4, date: '2024-01-16', status: 'Reviewed', message: 'The trainers are very helpful and encouraging. Great experience!', color: 'bg-teal-500' },
  { id: 3, name: 'Bikash Gurung', initials: 'BG', type: 'Premium', category: 'Equipment', rating: 3, date: '2024-01-17', status: 'Pending', message: 'The gym floor could be cleaned more frequently during peak hours.', color: 'bg-blue-500' },
  { id: 4, name: 'Anjali Rai', initials: 'AR', type: 'Basic', category: 'Classes', rating: 5, date: '2024-01-18', status: 'Reviewed', message: 'Love the new workout programs! The variety is amazing.', color: 'bg-purple-500' },
  { id: 5, name: 'Pramod Karki', initials: 'PK', type: 'Standard', category: 'General', rating: 4, date: '2024-01-19', status: 'Pending', message: 'Nutritional supplements are well-maintained. Please restock them regularly.', color: 'bg-orange-500' },
  { id: 6, name: 'Maya Tamang', initials: 'MT', type: 'Premium', category: 'Cleanliness', rating: 4, date: '2024-01-20', status: 'Reviewed', message: 'Locker rooms are well maintained, thank you!', color: 'bg-pink-500' },
  { id: 7, name: 'Suresh Shrestha', initials: 'SS', type: 'Standard', category: 'Staff', rating: 5, date: '2024-01-21', status: 'Reviewed', message: 'Former Titan dev is amazing! Very motivating and professional.', color: 'bg-indigo-500' },
  { id: 8, name: 'Kopila Adhikari', initials: 'KA', type: 'Basic', category: 'General', rating: 3, date: '2024-01-22', status: 'Pending', message: 'Good gym overall. But there should be more yoga classes.', color: 'bg-yellow-500' },
]

const categories = ['All', 'General', 'Equipment', 'Cleanliness', 'Staff', 'Classes', 'Other']

const Stars = ({ rating }) => (
  <div className="flex gap-0.5">
    {[1,2,3,4,5].map(i => (
      <svg key={i} viewBox="0 0 24 24" className={`w-3.5 h-3.5 ${i <= rating ? 'fill-yellow-400' : 'fill-gray-200'}`}>
        <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
      </svg>
    ))}
  </div>
)

export default function Feedback() {
  const [categoryFilter, setCategoryFilter] = useState('All')
  const [statusFilter, setStatusFilter] = useState('All')

  const filtered = feedbacks.filter(f => {
    const matchCat = categoryFilter === 'All' || f.category === categoryFilter
    const matchStatus = statusFilter === 'All' || f.status === statusFilter
    return matchCat && matchStatus
  })

  const avgRating = (feedbacks.reduce((a, b) => a + b.rating, 0) / feedbacks.length).toFixed(1)

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Feedback Management</h1>
        <p className="text-gray-400 text-sm mt-1">Review and manage member feedback</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Total Feedback</p>
          <p className="text-3xl font-bold text-gray-800">8</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Avg. Rating</p>
          <div className="flex items-center gap-2">
            <p className="text-3xl font-bold text-yellow-500">{avgRating}</p>
            <Stars rating={Math.round(avgRating)} />
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">New Feedback</p>
          <p className="text-3xl font-bold text-blue-500">2</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Resolved</p>
          <p className="text-3xl font-bold text-green-500">5</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-4 mb-6 flex-wrap">
        <div>
          <p className="text-xs text-gray-400 mb-1">Filter by Category</p>
          <div className="flex gap-2 flex-wrap">
            {categories.map(c => (
              <button key={c} onClick={() => setCategoryFilter(c)}
                className={`px-3 py-1.5 rounded-xl text-xs font-medium transition ${categoryFilter === c ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
                {c}
              </button>
            ))}
          </div>
        </div>
        <div>
          <p className="text-xs text-gray-400 mb-1">Filter by Status</p>
          <div className="flex gap-2">
            {['All', 'Pending', 'Reviewed'].map(s => (
              <button key={s} onClick={() => setStatusFilter(s)}
                className={`px-3 py-1.5 rounded-xl text-xs font-medium transition ${statusFilter === s ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Feedback List */}
      <div className="space-y-4">
        {filtered.map((f) => (
          <div key={f.id} className="bg-white rounded-2xl border border-gray-100 p-5">
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-full ${f.color} flex items-center justify-center text-white text-sm font-bold`}>{f.initials}</div>
                <div>
                  <p className="font-semibold text-gray-800">{f.name}</p>
                  <div className="flex items-center gap-2 mt-0.5">
                    <span className="text-xs text-gray-400">{f.type}</span>
                    <span className="text-xs text-gray-300">•</span>
                    <span className="text-xs text-gray-400">{f.date}</span>
                    <span className="text-xs text-gray-300">•</span>
                    <span className="text-xs text-blue-500">{f.category}</span>
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <Stars rating={f.rating} />
                <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${f.status === 'Reviewed' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>
                  {f.status}
                </span>
              </div>
            </div>
            <p className="text-sm text-gray-600 mb-3">{f.message}</p>
            <div className="flex gap-2">
              {f.status === 'Pending' && (
                <button className="text-xs text-green-600 font-medium hover:text-green-700">Mark as Reviewed</button>
              )}
              <button className="text-xs text-gray-400 font-medium hover:text-gray-600">Resolved</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}