import { useState, useEffect } from 'react'
import API_BASE_URL from '../config.js'

const GOALS      = ['bulk', 'cut', 'maintain']
const DIET_TYPES = ['vegetarian', 'non_vegetarian', 'vegan']
const MEAL_NAMES = ['breakfast', 'lunch', 'snacks', 'dinner', 'pre_workout', 'post_workout']

const goalColor = (g) => {
  const map = { bulk: 'bg-blue-100 text-blue-700',
    cut: 'bg-orange-100 text-orange-700',
    maintain: 'bg-green-100 text-green-700' }
  return map[g] || 'bg-gray-100 text-gray-600'
}
const dietColor = (d) => {
  const map = { vegetarian: 'bg-green-100 text-green-700',
    non_vegetarian: 'bg-red-100 text-red-700',
    vegan: 'bg-teal-100 text-teal-700' }
  return map[d] || 'bg-gray-100 text-gray-600'
}
const cap  = (s) => s ? s[0].toUpperCase() + s.slice(1) : ''
const nice = (s) => s ? s.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase()) : ''

const emptyFood = () => ({
  name: '', quantity: '100g', calories: 0, 
  protein: 0, carbs: 0, fat: 0, notes: ''
})
const emptyMeal = (name, order) => ({
  name, order, notes: '', food_items: [emptyFood()]
})
const emptyForm = () => ({
  name: '', description: '', goal: 'bulk',
  diet_type: 'non_vegetarian', total_calories: 0,
  meals: [
    emptyMeal('breakfast', 1),
    emptyMeal('lunch', 2),
    emptyMeal('snacks', 3),
    emptyMeal('dinner', 4),
  ]
})

export default function MealPlans() {
  const [plans, setPlans]         = useState([])
  const [loading, setLoading]     = useState(true)
  const [error, setError]         = useState(null)
  const [showModal, setShowModal] = useState(false)
  const [editPlan, setEditPlan]   = useState(null)
  const [form, setForm]           = useState(emptyForm())
  const [saving, setSaving]       = useState(false)
  const [formError, setFormError] = useState('')
  const [expandedId, setExpandedId] = useState(null)
  const [expandedMeal, setExpandedMeal] = useState(null)

  const token   = localStorage.getItem('admin_token')
  const headers = { 'Content-Type': 'application/json',
    Authorization: `Bearer ${token}` }

  useEffect(() => { fetchPlans() }, [])

  const fetchPlans = async () => {
    try {
      const res = await fetch(
        `${API_BASE_URL}/meals/admin/meal-plans/`, { headers })
      if (res.ok) setPlans(await res.json())
      else setError('Failed to load meal plans')
    } catch { setError('Cannot connect to server') }
    finally { setLoading(false) }
  }

  const openCreate = () => {
    setEditPlan(null); setForm(emptyForm())
    setFormError(''); setShowModal(true)
  }

  const openEdit = (plan) => {
    setEditPlan(plan)
    setForm({
      name: plan.name, description: plan.description,
      goal: plan.goal, diet_type: plan.diet_type,
      total_calories: plan.total_calories,
      meals: plan.meals.map(m => ({
        name: m.name, order: m.order, notes: m.notes,
        food_items: m.food_items.length > 0
          ? m.food_items.map(f => ({
              name: f.name, quantity: f.quantity,
              calories: f.calories, protein: f.protein,
              carbs: f.carbs, fat: f.fat, notes: f.notes
            }))
          : [emptyFood()]
      }))
    })
    setFormError(''); setShowModal(true)
  }

  const addMeal = () => {
    const used  = form.meals.map(m => m.name)
    const avail = MEAL_NAMES.find(n => !used.includes(n))
    if (!avail) return
    setForm({ ...form,
      meals: [...form.meals,
        emptyMeal(avail, form.meals.length + 1)] })
  }

  const removeMeal = (mi) =>
    setForm({ ...form, meals: form.meals.filter((_, i) => i !== mi) })

  const updateMeal = (mi, field, val) => {
    const meals = [...form.meals]
    meals[mi] = { ...meals[mi], [field]: val }
    setForm({ ...form, meals })
  }

  const addFood = (mi) => {
    const meals = [...form.meals]
    meals[mi].food_items = [...meals[mi].food_items, emptyFood()]
    setForm({ ...form, meals })
  }

  const removeFood = (mi, fi) => {
    const meals = [...form.meals]
    meals[mi].food_items = meals[mi].food_items.filter((_, i) => i !== fi)
    setForm({ ...form, meals })
  }

  const updateFood = (mi, fi, field, val) => {
    const meals = [...form.meals]
    meals[mi].food_items[fi] = { ...meals[mi].food_items[fi], [field]: val }
    setForm({ ...form, meals })
  }

  const handleSave = async () => {
    if (!form.name.trim()) { setFormError('Plan name is required'); return }
    for (const m of form.meals) {
      for (const f of m.food_items) {
        if (!f.name.trim()) {
          setFormError('All food items must have a name'); return
        }
        if (!f.quantity.toString().trim()) {
          setFormError('All food items must have a quantity (e.g. 100g)'); return
        }
      }
    }
    setSaving(true); setFormError('')
    try {
      const payload = {
        ...form,
        meals: form.meals.map((m, i) => ({
          ...m, order: i + 1,
          food_items: m.food_items.map((f, j) => ({ ...f, order: j + 1 }))
        }))
      }
      const url    = editPlan
        ? `${API_BASE_URL}/meals/admin/meal-plans/${editPlan.id}/`
        : `${API_BASE_URL}/meals/admin/meal-plans/`
      const method = editPlan ? 'PUT' : 'POST'
      const res    = await fetch(url, {
        method, headers, body: JSON.stringify(payload) })
      const data   = await res.json()
      if (res.ok) {
        if (editPlan) setPlans(plans.map(p => p.id === editPlan.id ? data : p))
        else setPlans([data, ...plans])
        setShowModal(false)
      } else {
        const messages = Object.entries(data).map(([key, val]) => {
          if (Array.isArray(val)) return val.map(v => typeof v === 'object' ? JSON.stringify(v) : v).join(', ')
          if (typeof val === 'object') return JSON.stringify(val)
          return val
        }).join(' | ')
        setFormError(messages || 'Failed to save meal plan')
      }
    } catch { setFormError('Cannot connect to server') }
    finally { setSaving(false) }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this meal plan?')) return
    await fetch(`${API_BASE_URL}/meals/admin/meal-plans/${id}/`,
      { method: 'DELETE', headers })
    setPlans(plans.filter(p => p.id !== id))
  }

  const handleToggle = async (id) => {
    const res  = await fetch(
      `${API_BASE_URL}/meals/admin/meal-plans/${id}/`,
      { method: 'PATCH', headers })
    const data = await res.json()
    if (res.ok) setPlans(plans.map(p => p.id === id ? data : p))
  }

  return (
    <div className="p-8">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Meal Plans</h1>
          <p className="text-gray-400 text-sm mt-1">
            Create and manage nutrition plans for your members
          </p>
        </div>
        <button onClick={openCreate}
          className="flex items-center gap-2 bg-green-500 hover:bg-green-600
            text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition shadow">
          + Create Plan
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Plans', value: plans.length, color: 'text-gray-800' },
          { label: 'Active', value: plans.filter(p => p.is_active).length, color: 'text-green-500' },
          { label: 'Veg Plans', value: plans.filter(p => p.diet_type === 'vegetarian').length, color: 'text-teal-500' },
          { label: 'Non-Veg Plans', value: plans.filter(p => p.diet_type === 'non_vegetarian').length, color: 'text-red-500' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">{s.label}</p>
            <p className={`text-3xl font-bold ${s.color}`}>{s.value}</p>
          </div>
        ))}
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-xl
          text-red-600 text-sm">{error}</div>
      )}

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-4 border-green-500 border-t-transparent
            rounded-full animate-spin" />
        </div>
      ) : plans.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-100 p-16
          text-center text-gray-400">
          <p className="text-lg font-medium mb-2">No meal plans yet</p>
          <p className="text-sm">Click "Create Plan" to add your first meal plan</p>
        </div>
      ) : (
        <div className="space-y-4">
          {plans.map(plan => (
            <div key={plan.id}
              className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              <div className="p-5 flex items-start justify-between">
                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-xl flex items-center
                    justify-center font-bold text-white text-sm
                    ${plan.goal === 'bulk' ? 'bg-blue-500' :
                      plan.goal === 'cut' ? 'bg-orange-500' : 'bg-green-500'}`}>
                    {plan.total_calories > 0
                      ? `${Math.round(plan.total_calories / 1000)}k`
                      : '—'}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold text-gray-800">{plan.name}</h3>
                      {!plan.is_active && (
                        <span className="text-xs bg-gray-100 text-gray-500
                          px-2 py-0.5 rounded-full">Inactive</span>
                      )}
                    </div>
                    {plan.description && (
                      <p className="text-xs text-gray-400 mt-0.5">
                        {plan.description}
                      </p>
                    )}
                    <div className="flex items-center gap-2 mt-2 flex-wrap">
                      <span className={`px-2.5 py-0.5 rounded-full text-xs
                        font-semibold ${goalColor(plan.goal)}`}>
                        {cap(plan.goal)}
                      </span>
                      <span className={`px-2.5 py-0.5 rounded-full text-xs
                        font-semibold ${dietColor(plan.diet_type)}`}>
                        {nice(plan.diet_type)}
                      </span>
                      {plan.total_calories > 0 && (
                        <span className="text-xs text-gray-400">
                          {plan.total_calories} cal/day
                        </span>
                      )}
                      <span className="text-xs text-gray-400">·</span>
                      <span className="text-xs text-gray-400">
                        {plan.meal_count} meals · {plan.food_count} items
                      </span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button onClick={() =>
                    setExpandedId(expandedId === plan.id ? null : plan.id)}
                    className="text-xs text-gray-400 hover:text-gray-600
                      border border-gray-200 px-3 py-1.5 rounded-lg transition">
                    {expandedId === plan.id ? 'Hide' : 'View'} Meals
                  </button>
                  <button onClick={() => handleToggle(plan.id)}
                    className={`text-xs px-3 py-1.5 rounded-lg border transition
                      ${plan.is_active
                        ? 'border-yellow-200 text-yellow-600 hover:bg-yellow-50'
                        : 'border-green-200 text-green-600 hover:bg-green-50'}`}>
                    {plan.is_active ? 'Deactivate' : 'Activate'}
                  </button>
                  <button onClick={() => openEdit(plan)}
                    className="text-xs text-blue-500 hover:text-blue-700
                      border border-blue-100 px-3 py-1.5 rounded-lg transition">
                    Edit
                  </button>
                  <button onClick={() => handleDelete(plan.id)}
                    className="text-xs text-red-500 hover:text-red-700
                      border border-red-100 px-3 py-1.5 rounded-lg transition">
                    Delete
                  </button>
                </div>
              </div>

              {expandedId === plan.id && (
                <div className="border-t border-gray-100 px-5 pb-5 pt-4">
                  <div className="space-y-3">
                    {plan.meals.map(meal => (
                      <div key={meal.id}
                        className="bg-gray-50 rounded-xl overflow-hidden">
                        <button
                          onClick={() => setExpandedMeal(
                            expandedMeal === meal.id ? null : meal.id)}
                          className="w-full flex items-center justify-between
                            px-4 py-3 text-left">
                          <div className="flex items-center gap-3">
                            <span className="text-sm font-semibold text-gray-700">
                              {nice(meal.name)}
                            </span>
                            <span className="text-xs text-gray-400">
                              {meal.food_items.length} items ·{' '}
                              {meal.total_calories} cal
                            </span>
                          </div>
                          <span className="text-gray-400 text-xs">
                            {expandedMeal === meal.id ? '▲' : '▼'}
                          </span>
                        </button>
                        {expandedMeal === meal.id && (
                          <div className="px-4 pb-3 space-y-1 border-t
                            border-gray-200">
                            <div className="grid grid-cols-5 gap-2 text-xs
                              text-gray-400 font-medium py-2">
                              <span className="col-span-2">Food</span>
                              <span>Quantity</span>
                              <span>Calories</span>
                              <span>P/C/F</span>
                            </div>
                            {meal.food_items.map(food => (
                              <div key={food.id}
                                className="grid grid-cols-5 gap-2 text-xs
                                  text-gray-600 py-1">
                                <span className="col-span-2 font-medium">
                                  {food.name}
                                </span>
                                <span>{food.quantity}</span>
                                <span>{food.calories}</span>
                                <span className="text-gray-400">
                                  {food.protein}g / {food.carbs}g / {food.fat}g
                                </span>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-start
          justify-center overflow-y-auto py-8 px-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl">
            <div className="flex items-center justify-between px-8 py-5
              border-b border-gray-100">
              <h2 className="text-xl font-bold text-gray-800">
                {editPlan ? 'Edit Meal Plan' : 'Create Meal Plan'}
              </h2>
              <button onClick={() => setShowModal(false)}
                className="text-gray-400 hover:text-gray-600 text-xl">✕</button>
            </div>

            <div className="px-8 py-6 space-y-6">
              {/* Basic info */}
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Plan Name *
                  </label>
                  <input value={form.name}
                    onChange={e => setForm({ ...form, name: e.target.value })}
                    className="w-full border border-gray-200 rounded-xl px-4
                      py-2.5 text-sm focus:outline-none focus:ring-2
                      focus:ring-green-400"
                    placeholder="e.g. High Protein Bulk Plan" />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Description
                  </label>
                  <textarea value={form.description}
                    onChange={e =>
                      setForm({ ...form, description: e.target.value })}
                    rows={2}
                    className="w-full border border-gray-200 rounded-xl px-4
                      py-2.5 text-sm focus:outline-none focus:ring-2
                      focus:ring-green-400"
                    placeholder="Brief description..." />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Goal
                  </label>
                  <select value={form.goal}
                    onChange={e => setForm({ ...form, goal: e.target.value })}
                    className="w-full border border-gray-200 rounded-xl px-4
                      py-2.5 text-sm focus:outline-none focus:ring-2
                      focus:ring-green-400">
                    {GOALS.map(g => (
                      <option key={g} value={g}>{cap(g)}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Diet Type
                  </label>
                  <select value={form.diet_type}
                    onChange={e =>
                      setForm({ ...form, diet_type: e.target.value })}
                    className="w-full border border-gray-200 rounded-xl px-4
                      py-2.5 text-sm focus:outline-none focus:ring-2
                      focus:ring-green-400">
                    {DIET_TYPES.map(d => (
                      <option key={d} value={d}>{nice(d)}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Total Calories/Day
                  </label>
                  <input type="number" value={form.total_calories}
                    onChange={e =>
                      setForm({ ...form,
                        total_calories: parseInt(e.target.value) || 0 })}
                    className="w-full border border-gray-200 rounded-xl px-4
                      py-2.5 text-sm focus:outline-none focus:ring-2
                      focus:ring-green-400"
                    placeholder="2500" />
                </div>
              </div>

              {/* Meals builder */}
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-semibold text-gray-800">Meals</h3>
                  <button onClick={addMeal}
                    className="text-sm text-green-600 hover:text-green-700
                      font-medium">
                    + Add Meal
                  </button>
                </div>

                {form.meals.map((meal, mi) => (
                  <div key={mi}
                    className="border border-gray-200 rounded-xl overflow-hidden">
                    <div className="bg-gray-50 px-4 py-3 flex items-center gap-3">
                      <select value={meal.name}
                        onChange={e => updateMeal(mi, 'name', e.target.value)}
                        className="border border-gray-200 rounded-lg px-3
                          py-1.5 text-sm focus:outline-none focus:ring-2
                          focus:ring-green-400">
                        {MEAL_NAMES.map(n => (
                          <option key={n} value={n}>{nice(n)}</option>
                        ))}
                      </select>
                      <input value={meal.notes}
                        onChange={e => updateMeal(mi, 'notes', e.target.value)}
                        className="flex-1 border border-gray-200 rounded-lg
                          px-3 py-1.5 text-sm focus:outline-none focus:ring-2
                          focus:ring-green-400"
                        placeholder="Notes (optional)" />
                      {form.meals.length > 1 && (
                        <button onClick={() => removeMeal(mi)}
                          className="text-red-400 hover:text-red-600">✕</button>
                      )}
                    </div>
                    <div className="p-4 space-y-2">
                      <div className="grid grid-cols-12 gap-2 text-xs
                        text-gray-400 font-medium px-1">
                        <span className="col-span-3">Food Item *</span>
                        <span className="col-span-2">Quantity</span>
                        <span>Cal</span>
                        <span>Protein</span>
                        <span>Carbs</span>
                        <span>Fat</span>
                        <span className="col-span-2">Notes</span>
                        <span></span>
                      </div>
                      {meal.food_items.map((food, fi) => (
                        <div key={fi}
                          className="grid grid-cols-12 gap-2 items-center">
                          <div className="col-span-3">
                            <input value={food.name}
                              onChange={e =>
                                updateFood(mi, fi, 'name', e.target.value)}
                              className="w-full border border-gray-200
                                rounded-lg px-2 py-1.5 text-xs
                                focus:outline-none focus:ring-2
                                focus:ring-green-400"
                              placeholder="e.g. Oats" />
                          </div>
                          <div className="col-span-2">
                            <input value={food.quantity}
                              onChange={e =>
                                updateFood(mi, fi, 'quantity', e.target.value)}
                              className="w-full border border-gray-200
                                rounded-lg px-2 py-1.5 text-xs
                                focus:outline-none focus:ring-2
                                focus:ring-green-400"
                              placeholder="100g" />
                          </div>
                          {['calories', 'protein', 'carbs', 'fat'].map(field => (
                            <div key={field}>
                              <input type="number" value={food[field]}
                                onChange={e =>
                                  updateFood(mi, fi, field,
                                    parseFloat(e.target.value) || 0)}
                                className="w-full border border-gray-200
                                  rounded-lg px-2 py-1.5 text-xs
                                  focus:outline-none focus:ring-2
                                  focus:ring-green-400"
                                placeholder="0" />
                            </div>
                          ))}
                          <div className="col-span-2">
                            <input value={food.notes}
                              onChange={e =>
                                updateFood(mi, fi, 'notes', e.target.value)}
                              className="w-full border border-gray-200
                                rounded-lg px-2 py-1.5 text-xs
                                focus:outline-none focus:ring-2
                                focus:ring-green-400"
                              placeholder="Optional" />
                          </div>
                          <div className="flex justify-center">
                            {meal.food_items.length > 1 && (
                              <button onClick={() => removeFood(mi, fi)}
                                className="text-red-400 hover:text-red-600">
                                ✕
                              </button>
                            )}
                          </div>
                        </div>
                      ))}
                      <button onClick={() => addFood(mi)}
                        className="text-sm text-green-600 hover:text-green-700
                          font-medium mt-1">
                        + Add Food Item
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              {formError && (
                <p className="text-red-500 text-sm">{formError}</p>
              )}
            </div>

            <div className="flex gap-3 px-8 py-5 border-t border-gray-100">
              <button onClick={() => setShowModal(false)}
                className="flex-1 border border-gray-200 text-gray-600
                  py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50
                  transition">
                Cancel
              </button>
              <button onClick={handleSave} disabled={saving}
                className="flex-1 bg-green-500 hover:bg-green-600 text-white
                  py-2.5 rounded-xl text-sm font-semibold transition
                  disabled:opacity-70">
                {saving ? 'Saving...' : editPlan ? 'Save Changes' : 'Create Plan'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}