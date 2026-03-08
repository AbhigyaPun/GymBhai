import { useState } from 'react'

const plans = [
  { id: 1, name: 'Vegetarian Muscle Gain', type: 'Vegetarian', calories: 3800, protein: 180, carbs: 420, fat: 95, assigned: 28, color: 'bg-green-500' },
  { id: 2, name: 'Non-Veg Weight Loss', type: 'Non-Vegetarian', calories: 1800, protein: 160, carbs: 120, fat: 55, assigned: 35, color: 'bg-blue-500' },
  { id: 3, name: 'Veg Maintenance Plan', type: 'Vegetarian', calories: 2200, protein: 110, carbs: 260, fat: 65, assigned: 22, color: 'bg-teal-500' },
  { id: 4, name: 'High Protein Bulk', type: 'Non-Vegetarian', calories: 4200, protein: 220, carbs: 480, fat: 110, assigned: 18, color: 'bg-orange-500' },
]

export default function MealPlans() {
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ name: '', type: 'Vegetarian', calories: '', goal: 'bulk', description: '' })
  const [meals, setMeals] = useState([])
  const [mealForm, setMealForm] = useState({ name: '', calories: '', protein: '', carbs: '', fat: '' })

  const addMeal = () => {
    if (!mealForm.name) return
    setMeals([...meals, { ...mealForm, id: Date.now() }])
    setMealForm({ name: '', calories: '', protein: '', carbs: '', fat: '' })
  }

  return (
    <div className="p-8">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Meal Plans</h1>
          <p className="text-gray-400 text-sm mt-1">Design and manage personalized nutrition programs</p>
        </div>
        <button onClick={() => setShowCreate(true)}
          className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition shadow">
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
          Create Plan
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Total Plans</p>
          <p className="text-3xl font-bold text-gray-800">4</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Avg. Calories/Day</p>
          <p className="text-3xl font-bold text-green-500">2500</p>
        </div>
      </div>

      {/* Plans Grid */}
      <div className="grid grid-cols-2 gap-4">
        {plans.map((plan) => (
          <div key={plan.id} className="bg-white rounded-2xl border border-gray-100 p-6">
            <div className="flex items-start justify-between mb-3">
              <div className={`w-10 h-10 ${plan.color} rounded-xl flex items-center justify-center`}>
                <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white"><path d="M18.06 22.99h1.66c.84 0 1.53-.64 1.63-1.46L23 5.05h-5V1h-1.97v4.05h-4.97l.3 2.34c1.71.47 3.31 1.32 4.27 2.26 1.44 1.42 2.43 2.89 2.43 5.29v8.05zM1 21.99V21h15.03v.99c0 .55-.45 1-1.01 1H2.01c-.56 0-1.01-.45-1.01-1zm15.03-7c0-8.44-15.03-8.44-15.03 0h15.03zM1.02 17h15v2h-15z"/></svg>
              </div>
              <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${plan.type === 'Vegetarian' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>
                {plan.type}
              </span>
            </div>
            <h3 className="font-semibold text-gray-800 mb-1">{plan.name}</h3>
            <p className="text-xs text-gray-400 mb-4">{plan.calories} cal/day · {plan.assigned} members</p>
            <div className="grid grid-cols-3 gap-2 mb-4">
              <div className="text-center bg-green-50 rounded-lg py-2">
                <p className="text-xs text-gray-400">Protein</p>
                <p className="text-sm font-semibold text-green-600">{plan.protein}g</p>
              </div>
              <div className="text-center bg-blue-50 rounded-lg py-2">
                <p className="text-xs text-gray-400">Carbs</p>
                <p className="text-sm font-semibold text-blue-600">{plan.carbs}g</p>
              </div>
              <div className="text-center bg-yellow-50 rounded-lg py-2">
                <p className="text-xs text-gray-400">Fat</p>
                <p className="text-sm font-semibold text-yellow-600">{plan.fat}g</p>
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
                <p className="text-xs text-gray-400">← Back to Meal Plans</p>
                <h2 className="text-xl font-bold text-gray-800 mt-1">Create Meal Plan</h2>
                <p className="text-sm text-gray-400">Design a personalized nutrition program for your members</p>
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
                  placeholder="e.g. Vegetarian Weight Loss Plan" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Diet Type</label>
                  <select value={form.type} onChange={e => setForm({...form, type: e.target.value})}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                    <option>Vegetarian</option>
                    <option>Non-Vegetarian</option>
                    <option>Vegan</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Goal</label>
                  <select value={form.goal} onChange={e => setForm({...form, goal: e.target.value})}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                    <option value="bulk">Bulk</option>
                    <option value="cut">Cut</option>
                    <option value="maintain">Maintain</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Daily Calories/Day *</label>
                <input type="number" value={form.calories} onChange={e => setForm({...form, calories: e.target.value})}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="2000" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})}
                  rows={2} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Brief description of this meal plan..." />
              </div>

              {/* Meals Section */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <h3 className="font-semibold text-gray-700">Meals</h3>
                  <button onClick={addMeal} className="flex items-center gap-1 text-green-500 text-sm font-medium hover:text-green-600">
                    <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                    Add Meal
                  </button>
                </div>
                {meals.length === 0 ? (
                  <p className="text-sm text-gray-400 text-center py-4 border border-dashed border-gray-200 rounded-xl">
                    No meals added yet. Click "Add Meal" to get started.
                  </p>
                ) : (
                  <div className="space-y-2">
                    {meals.map((m) => (
                      <div key={m.id} className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-xl">
                        <span className="text-sm font-medium text-gray-700">{m.name}</span>
                        <span className="text-xs text-gray-400">{m.calories} cal</span>
                      </div>
                    ))}
                  </div>
                )}
                <div className="grid grid-cols-2 gap-2 mt-2">
                  <input value={mealForm.name} onChange={e => setMealForm({...mealForm, name: e.target.value})}
                    className="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    placeholder="Meal name" />
                  <input type="number" value={mealForm.calories} onChange={e => setMealForm({...mealForm, calories: e.target.value})}
                    className="border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    placeholder="Calories" />
                </div>
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