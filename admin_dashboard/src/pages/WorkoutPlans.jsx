import { useState, useEffect } from 'react'
import API_BASE_URL from '../config.js'

const GOALS = ['bulk', 'cut', 'maintain', 'strength']
const LEVELS = ['beginner', 'intermediate', 'advanced']
const DAYS_OPTIONS = [3, 4, 5, 6, 7]

const goalColor = (g) => {
  const map = { bulk: 'bg-blue-100 text-blue-700', cut: 'bg-orange-100 text-orange-700',
    maintain: 'bg-green-100 text-green-700', strength: 'bg-purple-100 text-purple-700' }
  return map[g] || 'bg-gray-100 text-gray-600'
}
const levelColor = (l) => {
  const map = { beginner: 'bg-green-100 text-green-700',
    intermediate: 'bg-yellow-100 text-yellow-700', advanced: 'bg-red-100 text-red-700' }
  return map[l] || 'bg-gray-100 text-gray-600'
}
const cap = (s) => s ? s[0].toUpperCase() + s.slice(1) : ''

const emptyExercise = () => ({ name: '', sets: 3, reps: '8-10', weight_note: '', notes: '' })
const emptyDay = (n) => ({ day_number: n, name: '', notes: '', exercises: [emptyExercise()] })
const emptyForm = () => ({
  name: '', description: '', goal: 'bulk', level: 'beginner', days_per_week: 3,
  days: [emptyDay(1), emptyDay(2), emptyDay(3)]
})

export default function WorkoutPlans() {
  const [splits, setSplits]       = useState([])
  const [loading, setLoading]     = useState(true)
  const [error, setError]         = useState(null)
  const [showModal, setShowModal] = useState(false)
  const [editSplit, setEditSplit] = useState(null)
  const [form, setForm]           = useState(emptyForm())
  const [saving, setSaving]       = useState(false)
  const [formError, setFormError] = useState('')
  const [expandedId, setExpandedId] = useState(null)

  const token = localStorage.getItem('admin_token')
  const headers = { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }

  useEffect(() => { fetchSplits() }, [])

  const fetchSplits = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/workouts/admin/splits/`, { headers })
      if (res.ok) setSplits(await res.json())
      else setError('Failed to load splits')
    } catch { setError('Cannot connect to server') }
    finally { setLoading(false) }
  }

  const openCreate = () => {
    setEditSplit(null)
    setForm(emptyForm())
    setFormError('')
    setShowModal(true)
  }

  const openEdit = (split) => {
    setEditSplit(split)
    setForm({
      name: split.name, description: split.description,
      goal: split.goal, level: split.level,
      days_per_week: split.days_per_week,
      days: split.days.map(d => ({
        day_number: d.day_number, name: d.name, notes: d.notes,
        exercises: d.exercises.length > 0 ? d.exercises.map(e => ({
          name: e.name, sets: e.sets, reps: e.reps,
          weight_note: e.weight_note, notes: e.notes
        })) : [emptyExercise()]
      }))
    })
    setFormError('')
    setShowModal(true)
  }

  const handleDaysChange = (n) => {
    const current = form.days
    const newDays = Array.from({ length: n }, (_, i) => {
      return current[i] || emptyDay(i + 1)
    }).map((d, i) => ({ ...d, day_number: i + 1 }))
    setForm({ ...form, days_per_week: n, days: newDays })
  }

  const updateDay = (di, field, val) => {
    const days = [...form.days]
    days[di] = { ...days[di], [field]: val }
    setForm({ ...form, days })
  }

  const addExercise = (di) => {
    const days = [...form.days]
    days[di] = { ...days[di], exercises: [...days[di].exercises, emptyExercise()] }
    setForm({ ...form, days })
  }

  const removeExercise = (di, ei) => {
    const days = [...form.days]
    days[di].exercises = days[di].exercises.filter((_, i) => i !== ei)
    setForm({ ...form, days })
  }

  const updateExercise = (di, ei, field, val) => {
    const days = [...form.days]
    days[di].exercises[ei] = { ...days[di].exercises[ei], [field]: val }
    setForm({ ...form, days })
  }

  const handleSave = async () => {
    if (!form.name.trim()) { setFormError('Split name is required'); return }
    for (const d of form.days) {
      if (!d.name.trim()) { setFormError(`Day ${d.day_number} name is required`); return }
      for (const e of d.exercises) {
        if (!e.name.trim()) { setFormError(`All exercises must have a name`); return }
      }
    }
    setSaving(true); setFormError('')
    try {
      const payload = { ...form, days: form.days.map((d, i) => ({
        ...d, exercises: d.exercises.map((e, j) => ({ ...e, order: j + 1 }))
      }))}
      const url    = editSplit
        ? `${API_BASE_URL}/workouts/admin/splits/${editSplit.id}/`
        : `${API_BASE_URL}/workouts/admin/splits/`
      const method = editSplit ? 'PUT' : 'POST'
      const res    = await fetch(url, { method, headers, body: JSON.stringify(payload) })
      const data   = await res.json()
      if (res.ok) {
        if (editSplit) setSplits(splits.map(s => s.id === editSplit.id ? data : s))
        else setSplits([data, ...splits])
        setShowModal(false)
      } else setFormError(Object.values(data).flat().join(' '))
    } catch { setFormError('Cannot connect to server') }
    finally { setSaving(false) }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this split?')) return
    await fetch(`${API_BASE_URL}/workouts/admin/splits/${id}/`, { method: 'DELETE', headers })
    setSplits(splits.filter(s => s.id !== id))
  }

  const handleToggle = async (id) => {
    const res  = await fetch(`${API_BASE_URL}/workouts/admin/splits/${id}/`, { method: 'PATCH', headers })
    const data = await res.json()
    if (res.ok) setSplits(splits.map(s => s.id === id ? data : s))
  }

  return (
    <div className="p-8">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Workout Plans</h1>
          <p className="text-gray-400 text-sm mt-1">Create and manage workout splits for your members</p>
        </div>
        <button onClick={openCreate}
          className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition shadow">
          + Create Split
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Splits', value: splits.length, color: 'text-gray-800' },
          { label: 'Active', value: splits.filter(s => s.is_active).length, color: 'text-green-500' },
          { label: 'Total Exercises', value: splits.reduce((a, s) => a + (s.exercise_count || 0), 0), color: 'text-blue-500' },
          { label: 'Avg Days/Week', value: splits.length ? Math.round(splits.reduce((a, s) => a + s.days_per_week, 0) / splits.length) : 0, color: 'text-purple-500' },
        ].map(s => (
          <div key={s.label} className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">{s.label}</p>
            <p className={`text-3xl font-bold ${s.color}`}>{s.value}</p>
          </div>
        ))}
      </div>

      {error && <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-xl text-red-600 text-sm">{error}</div>}

      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : splits.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-100 p-16 text-center text-gray-400">
          <p className="text-lg font-medium mb-2">No splits yet</p>
          <p className="text-sm">Click "Create Split" to add your first workout plan</p>
        </div>
      ) : (
        <div className="space-y-4">
          {splits.map(split => (
            <div key={split.id} className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              {/* Header */}
              <div className="p-5 flex items-start justify-between">
                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold text-white text-sm
                    ${split.goal === 'bulk' ? 'bg-blue-500' : split.goal === 'cut' ? 'bg-orange-500' :
                      split.goal === 'strength' ? 'bg-purple-500' : 'bg-green-500'}`}>
                    {split.days_per_week}d
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="font-semibold text-gray-800">{split.name}</h3>
                      {!split.is_active && <span className="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">Inactive</span>}
                    </div>
                    {split.description && <p className="text-xs text-gray-400 mt-0.5">{split.description}</p>}
                    <div className="flex items-center gap-2 mt-2 flex-wrap">
                      <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${goalColor(split.goal)}`}>{cap(split.goal)}</span>
                      <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${levelColor(split.level)}`}>{cap(split.level)}</span>
                      <span className="text-xs text-gray-400">{split.days_per_week} days/week</span>
                      <span className="text-xs text-gray-400">·</span>
                      <span className="text-xs text-gray-400">{split.exercise_count} exercises</span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button onClick={() => setExpandedId(expandedId === split.id ? null : split.id)}
                    className="text-xs text-gray-400 hover:text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg transition">
                    {expandedId === split.id ? 'Hide' : 'View'} Days
                  </button>
                  <button onClick={() => handleToggle(split.id)}
                    className={`text-xs px-3 py-1.5 rounded-lg border transition
                      ${split.is_active ? 'border-yellow-200 text-yellow-600 hover:bg-yellow-50' : 'border-green-200 text-green-600 hover:bg-green-50'}`}>
                    {split.is_active ? 'Deactivate' : 'Activate'}
                  </button>
                  <button onClick={() => openEdit(split)}
                    className="text-xs text-blue-500 hover:text-blue-700 border border-blue-100 px-3 py-1.5 rounded-lg transition">
                    Edit
                  </button>
                  <button onClick={() => handleDelete(split.id)}
                    className="text-xs text-red-500 hover:text-red-700 border border-red-100 px-3 py-1.5 rounded-lg transition">
                    Delete
                  </button>
                </div>
              </div>

              {/* Expanded days */}
              {expandedId === split.id && (
                <div className="border-t border-gray-100 px-5 pb-5 pt-4">
                  <div className="grid grid-cols-1 gap-3">
                    {split.days.map(day => (
                      <div key={day.id} className="bg-gray-50 rounded-xl p-4">
                        <p className="text-sm font-semibold text-gray-700 mb-2">
                          Day {day.day_number}: {day.name}
                          {day.notes && <span className="text-xs text-gray-400 ml-2 font-normal">{day.notes}</span>}
                        </p>
                        <div className="space-y-1">
                          {day.exercises.map((ex, i) => (
                            <div key={ex.id} className="flex items-center gap-3 text-xs text-gray-600">
                              <span className="w-5 h-5 bg-green-100 text-green-700 rounded-full flex items-center justify-center font-semibold text-xs flex-shrink-0">{i + 1}</span>
                              <span className="font-medium">{ex.name}</span>
                              <span className="text-gray-400">{ex.sets} sets × {ex.reps} reps</span>
                              {ex.weight_note && <span className="text-gray-400">· {ex.weight_note}</span>}
                            </div>
                          ))}
                        </div>
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
        <div className="fixed inset-0 bg-black/40 z-50 flex items-start justify-center overflow-y-auto py-8 px-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl">
            {/* Modal header */}
            <div className="flex items-center justify-between px-8 py-5 border-b border-gray-100">
              <h2 className="text-xl font-bold text-gray-800">
                {editSplit ? 'Edit Split' : 'Create Workout Split'}
              </h2>
              <button onClick={() => setShowModal(false)} className="text-gray-400 hover:text-gray-600 text-xl">✕</button>
            </div>

            <div className="px-8 py-6 space-y-6">
              {/* Basic info */}
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Split Name *</label>
                  <input value={form.name} onChange={e => setForm({ ...form, name: e.target.value })}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    placeholder="e.g. Push Pull Legs — Bulk" />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea value={form.description} onChange={e => setForm({ ...form, description: e.target.value })}
                    rows={2} className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    placeholder="Brief description of this split..." />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Goal</label>
                  <select value={form.goal} onChange={e => setForm({ ...form, goal: e.target.value })}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                    {GOALS.map(g => <option key={g} value={g}>{cap(g)}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Level</label>
                  <select value={form.level} onChange={e => setForm({ ...form, level: e.target.value })}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400">
                    {LEVELS.map(l => <option key={l} value={l}>{cap(l)}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Days Per Week</label>
                  <div className="flex gap-2">
                    {DAYS_OPTIONS.map(n => (
                      <button key={n} onClick={() => handleDaysChange(n)}
                        className={`w-10 h-10 rounded-xl text-sm font-semibold transition
                          ${form.days_per_week === n ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                        {n}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Days builder */}
              <div className="space-y-4">
                <h3 className="font-semibold text-gray-800">Workout Days</h3>
                {form.days.map((day, di) => (
                  <div key={di} className="border border-gray-200 rounded-xl overflow-hidden">
                    <div className="bg-gray-50 px-4 py-3 flex items-center gap-3">
                      <span className="text-sm font-semibold text-gray-700">Day {day.day_number}</span>
                      <input value={day.name} onChange={e => updateDay(di, 'name', e.target.value)}
                        className="flex-1 border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                        placeholder='e.g. Push Day, Pull Day, Legs...' />
                      <input value={day.notes} onChange={e => updateDay(di, 'notes', e.target.value)}
                        className="w-40 border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                        placeholder="Notes (optional)" />
                    </div>
                    <div className="p-4 space-y-2">
                      {day.exercises.map((ex, ei) => (
                        <div key={ei} className="grid grid-cols-12 gap-2 items-center">
                          <div className="col-span-4">
                            <input value={ex.name} onChange={e => updateExercise(di, ei, 'name', e.target.value)}
                              className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                              placeholder="Exercise name *" />
                          </div>
                          <div className="col-span-2">
                            <input type="number" min="1" value={ex.sets} onChange={e => updateExercise(di, ei, 'sets', parseInt(e.target.value))}
                              className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                              placeholder="Sets" />
                          </div>
                          <div className="col-span-2">
                            <input value={ex.reps} onChange={e => updateExercise(di, ei, 'reps', e.target.value)}
                              className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                              placeholder="Reps" />
                          </div>
                          <div className="col-span-3">
                            <input value={ex.weight_note} onChange={e => updateExercise(di, ei, 'weight_note', e.target.value)}
                              className="w-full border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                              placeholder="Weight note" />
                          </div>
                          <div className="col-span-1 flex justify-center">
                            {day.exercises.length > 1 && (
                              <button onClick={() => removeExercise(di, ei)}
                                className="text-red-400 hover:text-red-600 text-lg">✕</button>
                            )}
                          </div>
                        </div>
                      ))}
                      <button onClick={() => addExercise(di)}
                        className="text-sm text-green-600 hover:text-green-700 font-medium mt-1">
                        + Add Exercise
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              {formError && <p className="text-red-500 text-sm">{formError}</p>}
            </div>

            <div className="flex gap-3 px-8 py-5 border-t border-gray-100">
              <button onClick={() => setShowModal(false)}
                className="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition">
                Cancel
              </button>
              <button onClick={handleSave} disabled={saving}
                className="flex-1 bg-green-500 hover:bg-green-600 text-white py-2.5 rounded-xl text-sm font-semibold transition disabled:opacity-70">
                {saving ? 'Saving...' : editSplit ? 'Save Changes' : 'Create Split'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}