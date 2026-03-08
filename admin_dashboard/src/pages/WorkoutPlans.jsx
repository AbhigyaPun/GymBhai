import { useState } from 'react'

const plans = [
  { id: 1, name: 'Beginner Strength Training', goal: 'Muscle Gain', level: 'Beginner', duration: '45 min', exercises: 8, assigned: 34, color: 'bg-green-500' },
  { id: 2, name: 'Advanced Weight Loss Program', goal: 'Weight Loss', level: 'Advanced', duration: '60 min', exercises: 12, assigned: 28, color: 'bg-blue-500' },
  { id: 3, name: 'Intermediate Full Body', goal: 'General Fitness', level: 'Intermediate', duration: '50 min', exercises: 10, assigned: 45, color: 'bg-purple-500' },
  { id: 4, name: 'Cardio Kickboxing', goal: 'Weight Loss', level: 'Intermediate', duration: '45 min', exercises: 9, assigned: 22, color: 'bg-orange-500' },
]

const levelBadge = (level) => {
  const styles = { Beginner: 'bg-green-100 text-green-700', Intermediate: 'bg-yellow-100 text-yellow-700', Advanced: 'bg-red-100 text-red-700' }
  return <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${styles[level]}`}>{level}</span>
}

export default function WorkoutPlans() {
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ name: '', goal: 'bulk', level: 'Beginner', duration: '', description: '' })

  return (
    <div className="p-8">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Workout Plans</h1>
          <p className="text-gray-400 text-sm mt-1">Create and manage personalized workout programs</p>
        </div>
        <button onClick={() => setShowCreate(true)}
          className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition shadow">
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
          Create Plan
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Total Plans</p>
          <p className="text-3xl font-bold text-gray-800">4</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Avg. Exercises</p>
          <p className="text-3xl font-bold text-green-500">14</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Total Assigned</p>
          <p className="text-3xl font-bold text-blue-500">129</p>
        </div>
      </div>

      {/* Plans Grid */}
      <div className="grid grid-cols-2 gap-4">
        {plans.map((plan) => (
          <div key={plan.id} className="bg-white rounded-2xl border border-gray-100 p-6">
            <div className="flex items-start justify-between mb-3">
              <div className={`w-10 h-10 ${plan.color} rounded-xl flex items-center justify-center`}>
                <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white"><path d="M20.57 14.86L22 13.43 20.57 12 17 15.57 8.43 7 12 3.43 10.57 2 9.14 3.43 7.71 2 5.57 4.14 4.14 2.71 2.71 4.14l1.43 1.43L2 7.71l1.43 1.43L2 10.57 3.43 12 7 8.43 15.57 17 12 20.57 13.43 22l1.43-1.43L16.29 22l2.14-2.14 1.43 1.43 1.43-1.43-1.43-1.43L22 16.29l-1.43-1.43z"/></svg>
              </div>
              {levelBadge(plan.level)}
            </div>
            <h3 className="font-semibold text-gray-800 mb-1">{plan.name}</h3>
            <p className="text-xs text-gray-400 mb-4">Goal: {plan.goal}</p>
            <div className="grid grid-cols-3 gap-2 mb-4">
              <div className="text-center">
                <p className="text-xs text-gray-400">Duration</p>
                <p className="text-sm font-semibold text-gray-700">{plan.duration}</p>
              </div>
              <div className="text-center">
                <p className="text-xs text-gray-400">Exercises</p>
                <p className="text-sm font-semibold text-gray-700">{plan.exercises}</p>
              </div>
              <div className="text-center">
                <p className="text-xs text-gray-400">Assigned</p>
                <p className="text-sm font-semibold text-gray-700">{plan.assigned}</p>
              </div>
            </div>
            <div className="flex gap-2">
              <button className="flex-1 border border-gray-200 text-gray-600 py-2 rounded-xl text-xs font-medium hover:bg-gray-50 transition">Edit</button>
              <button className="flex-1 border border-red-100 text-red-500 py-2 rounded-xl text-xs font-medium hover:bg-red-50 transition">Delete</button>
            </div>
          </div>
        ))}
      </div>

      {/* Create Modal */}
      {showCreate && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 px-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg p-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-2">
              <div>
                <p className="text-xs text-gray-400">← Back to Workout Plans</p>
                <h2 className="text-xl font-bold text-gray-800 mt-1">Create Workout Plan</h2>
                <p className="text-sm text-gray-400">Design a personalized workout program for your athletes</p>
              </div>
              <button onClick={() => setShowCreate(false)} className="text-gray-400 hover:text-gray-600">
                <svg viewBox="0 0 24 24" className="w-5 h-5 fill-current"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
              </button>
            </div>
            <hr className="my-4" />
            <h3 className="font-semibold text-gray-700 mb-4">Basic Information</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Plan Name *</label>
                <input value={form.name} onChange={e => setForm({...form, name: e.target.value})}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="e.g. Beginner Strength Training" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Goal</label>
                  <select value={form.goal} onChange={e => setForm({...form, goal: e.target.value})}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                    <option value="bulk">Bulk</option>
                    <option value="cut">Cut</option>
                    <option value="maintain">Maintain</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Level</label>
                  <select value={form.level} onChange={e => setForm({...form, level: e.target.value})}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                    <option>Beginner</option>
                    <option>Intermediate</option>
                    <option>Advanced</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Duration (minutes) *</label>
                <input type="number" value={form.duration} onChange={e => setForm({...form, duration: e.target.value})}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="45" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})}
                  rows={3} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Brief description of this workout plan..." />
              </div>
            </div>
            <div className="flex gap-3 mt-6">
              <button onClick={() => setShowCreate(false)}
                className="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition">Cancel</button>
              <button className="flex-1 bg-green-500 hover:bg-green-600 text-white py-2.5 rounded-xl text-sm font-semibold transition">Create Plan</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}