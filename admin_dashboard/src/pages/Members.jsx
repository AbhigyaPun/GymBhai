import { useState, useEffect } from 'react'
import { getMembers, createMember, updateMember, deleteMember } from '../services/api'

const avatarColors = ['bg-green-500', 'bg-teal-500', 'bg-blue-500', 'bg-purple-500', 'bg-orange-500', 'bg-pink-500']

const getInitials = (firstName, lastName) => {
  return `${firstName?.[0] || ''}${lastName?.[0] || ''}`.toUpperCase() || '?'
}

const getColor = (name) => {
  const index = (name?.charCodeAt(0) || 0) % avatarColors.length
  return avatarColors[index]
}

const statusBadge = (status) => {
  const styles = {
    active: 'bg-green-100 text-green-700',
    frozen: 'bg-yellow-100 text-yellow-700',
    expired: 'bg-red-100 text-red-700',
  }
  return (
    <span className={`px-2.5 py-1 rounded-full text-xs font-semibold capitalize ${styles[status] || 'bg-gray-100 text-gray-600'}`}>
      {status}
    </span>
  )
}

const emptyForm = {
  first_name: '', last_name: '', email: '', phone: '',
  password: '', goal: 'maintain', membership: 'basic', expiry_date: ''
}

export default function Members() {
  const [members, setMembers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState('all')

  // Modals
  const [showAddModal, setShowAddModal] = useState(false)
  const [showEditModal, setShowEditModal] = useState(false)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [selectedMember, setSelectedMember] = useState(null)

  // Forms
  const [addForm, setAddForm] = useState(emptyForm)
  const [editForm, setEditForm] = useState({})
  const [formError, setFormError] = useState('')
  const [formLoading, setFormLoading] = useState(false)

  // Fetch members
  const fetchMembers = async () => {
    setLoading(true)
    setError('')
    try {
      const res = await getMembers()
      const data = await res.json()
      if (res.ok) setMembers(data)
      else setError('Failed to load members')
    } catch {
      setError('Cannot connect to server')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchMembers() }, [])

  // Filter members
  const filtered = members.filter((m) => {
    const fullName = `${m.first_name} ${m.last_name}`.toLowerCase()
    const matchSearch = fullName.includes(search.toLowerCase()) ||
      m.email.toLowerCase().includes(search.toLowerCase())
    const matchFilter = filter === 'all' || m.status === filter
    return matchSearch && matchFilter
  })

  const totalMembers = members.length
  const activeMembers = members.filter(m => m.status === 'active').length
  const frozenExpired = members.filter(m => m.status === 'frozen' || m.status === 'expired').length

  // Add member
  const handleAdd = async (e) => {
    e.preventDefault()
    setFormError('')
    setFormLoading(true)
    try {
      const res = await createMember(addForm)
      const data = await res.json()
      if (res.ok) {
        setMembers([data, ...members])
        setShowAddModal(false)
        setAddForm(emptyForm)
      } else {
        setFormError(Object.values(data).flat().join(' '))
      }
    } catch {
      setFormError('Cannot connect to server')
    } finally {
      setFormLoading(false)
    }
  }

  // Edit member
  const openEdit = (member) => {
    setSelectedMember(member)
    setEditForm({
      first_name: member.first_name,
      last_name: member.last_name || '',
      email: member.email,
      phone: member.phone || '',
      goal: member.goal,
      membership: member.membership,
      status: member.status,
      expiry_date: member.expiry_date || '',
      password: '',
    })
    setFormError('')
    setShowEditModal(true)
  }

  const handleEdit = async (e) => {
    e.preventDefault()
    setFormError('')
    setFormLoading(true)
    // Remove empty password
    const payload = { ...editForm }
    if (!payload.password) delete payload.password
    try {
      const res = await updateMember(selectedMember.id, payload)
      const data = await res.json()
      if (res.ok) {
        setMembers(members.map(m => m.id === selectedMember.id ? data : m))
        setShowEditModal(false)
      } else {
        setFormError(Object.values(data).flat().join(' '))
      }
    } catch {
      setFormError('Cannot connect to server')
    } finally {
      setFormLoading(false)
    }
  }

  // Delete member
  const openDelete = (member) => {
    setSelectedMember(member)
    setShowDeleteModal(true)
  }

  const handleDelete = async () => {
    setFormLoading(true)
    try {
      const res = await deleteMember(selectedMember.id)
      if (res.ok) {
        setMembers(members.filter(m => m.id !== selectedMember.id))
        setShowDeleteModal(false)
      }
    } catch {
      setFormError('Cannot connect to server')
    } finally {
      setFormLoading(false)
    }
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Member Management</h1>
          <p className="text-gray-400 text-sm mt-1">Manage your gym members and their subscriptions</p>
        </div>
        <button onClick={() => { setShowAddModal(true); setFormError('') }}
          className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-4 py-2.5 rounded-xl text-sm font-semibold transition shadow">
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-white"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
          Add Member
        </button>
      </div>

      {/* Search + Filter */}
      <div className="flex items-center gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-gray-400 absolute left-3 top-1/2 -translate-y-1/2">
            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
          </svg>
          <input type="text" placeholder="Search members by name or email..."
            value={search} onChange={(e) => setSearch(e.target.value)}
            className="w-full border border-gray-200 rounded-xl pl-9 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400" />
        </div>
        <div className="flex gap-2">
          {['all', 'active', 'frozen', 'expired'].map((f) => (
            <button key={f} onClick={() => setFilter(f)}
              className={`px-4 py-2 rounded-xl text-sm font-medium capitalize transition ${
                filter === f ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600 hover:border-green-300'
              }`}>
              {f === 'all' ? 'All' : f.charAt(0).toUpperCase() + f.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden mb-6">
        {loading ? (
          <div className="flex items-center justify-center py-20 text-gray-400">Loading members...</div>
        ) : error ? (
          <div className="flex items-center justify-center py-20 text-red-400">{error}</div>
        ) : filtered.length === 0 ? (
          <div className="flex items-center justify-center py-20 text-gray-400">No members found</div>
        ) : (
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Member</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Contact</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Membership</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Status</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Check-ins</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Expiry Date</th>
                <th className="text-left text-xs font-semibold text-gray-400 uppercase tracking-wide px-6 py-4">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((m, i) => {
                const initials = getInitials(m.first_name, m.last_name)
                const color = getColor(m.first_name)
                return (
                  <tr key={m.id} className={`border-b border-gray-50 hover:bg-gray-50 transition ${i === filtered.length - 1 ? 'border-0' : ''}`}>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className={`w-9 h-9 rounded-full ${color} flex items-center justify-center text-white text-xs font-bold`}>
                          {initials}
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-gray-800">{m.first_name} {m.last_name}</p>
                          <p className="text-xs text-gray-400 capitalize">{m.goal}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-sm text-gray-700">{m.email}</p>
                      <p className="text-xs text-gray-400">{m.phone || '-'}</p>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-sm font-medium text-gray-800 capitalize">{m.membership}</p>
                      <p className="text-xs text-gray-400">Since {m.member_since}</p>
                    </td>
                    <td className="px-6 py-4">{statusBadge(m.status)}</td>
                    <td className="px-6 py-4">
                      <p className="text-sm font-semibold text-gray-800">{m.checkins}</p>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-sm text-gray-700">{m.expiry_date || '-'}</p>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <button onClick={() => openEdit(m)} className="p-1.5 text-blue-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition">
                          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                        </button>
                        <button onClick={() => openDelete(m)} className="p-1.5 text-red-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition">
                          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* Bottom Stats */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Total Members</p>
          <p className="text-3xl font-bold text-gray-800">{totalMembers}</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Active Members</p>
          <p className="text-3xl font-bold text-green-500">{activeMembers}</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <p className="text-sm text-gray-500 mb-1">Frozen/Expired</p>
          <p className="text-3xl font-bold text-yellow-500">{frozenExpired}</p>
        </div>
      </div>

      {/* Add Member Modal */}
      {showAddModal && (
        <Modal title="Add New Member" onClose={() => setShowAddModal(false)}>
          <form onSubmit={handleAdd} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <Field label="First Name" required>
                <input required value={addForm.first_name} onChange={e => setAddForm({...addForm, first_name: e.target.value})}
                  className={inputClass} placeholder="Abhigya" />
              </Field>
              <Field label="Last Name">
                <input value={addForm.last_name} onChange={e => setAddForm({...addForm, last_name: e.target.value})}
                  className={inputClass} placeholder="Optional" />
              </Field>
            </div>
            <Field label="Email">
              <input required type="email" value={addForm.email} onChange={e => setAddForm({...addForm, email: e.target.value})}
                className={inputClass} placeholder="member@email.com" />
            </Field>
            <Field label="Phone">
              <input value={addForm.phone} onChange={e => setAddForm({...addForm, phone: e.target.value})}
                className={inputClass} placeholder="+977 98-XXXXXXXX" />
            </Field>
            <div className="grid grid-cols-2 gap-4">
              <Field label="Membership">
                <select value={addForm.membership} onChange={e => setAddForm({...addForm, membership: e.target.value})} className={inputClass}>
                  <option value="basic">Basic</option>
                  <option value="standard">Standard</option>
                  <option value="premium">Premium</option>
                </select>
              </Field>
              <Field label="Goal">
                <select value={addForm.goal} onChange={e => setAddForm({...addForm, goal: e.target.value})} className={inputClass}>
                  <option value="bulk">Bulk</option>
                  <option value="cut">Cut</option>
                  <option value="maintain">Maintain</option>
                </select>
              </Field>
            </div>
            <Field label="Expiry Date">
              <input type="date" value={addForm.expiry_date} onChange={e => setAddForm({...addForm, expiry_date: e.target.value})}
                className={inputClass} />
            </Field>
            <Field label="Login Password">
              <input required type="password" value={addForm.password} onChange={e => setAddForm({...addForm, password: e.target.value})}
                className={inputClass} placeholder="Min 6 characters" />
            </Field>
            {formError && <p className="text-red-500 text-sm">{formError}</p>}
            <ModalButtons onCancel={() => setShowAddModal(false)} loading={formLoading} label="Create Member" />
          </form>
        </Modal>
      )}

      {/* Edit Member Modal */}
      {showEditModal && (
        <Modal title="Edit Member" onClose={() => setShowEditModal(false)}>
          <form onSubmit={handleEdit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <Field label="First Name">
                <input required value={editForm.first_name} onChange={e => setEditForm({...editForm, first_name: e.target.value})}
                  className={inputClass} />
              </Field>
              <Field label="Last Name">
                <input value={editForm.last_name} onChange={e => setEditForm({...editForm, last_name: e.target.value})}
                  className={inputClass} />
              </Field>
            </div>
            <Field label="Email">
              <input required type="email" value={editForm.email} onChange={e => setEditForm({...editForm, email: e.target.value})}
                className={inputClass} />
            </Field>
            <Field label="Phone">
              <input value={editForm.phone} onChange={e => setEditForm({...editForm, phone: e.target.value})}
                className={inputClass} />
            </Field>
            <div className="grid grid-cols-3 gap-4">
              <Field label="Membership">
                <select value={editForm.membership} onChange={e => setEditForm({...editForm, membership: e.target.value})} className={inputClass}>
                  <option value="basic">Basic</option>
                  <option value="standard">Standard</option>
                  <option value="premium">Premium</option>
                </select>
              </Field>
              <Field label="Goal">
                <select value={editForm.goal} onChange={e => setEditForm({...editForm, goal: e.target.value})} className={inputClass}>
                  <option value="bulk">Bulk</option>
                  <option value="cut">Cut</option>
                  <option value="maintain">Maintain</option>
                </select>
              </Field>
              <Field label="Status">
                <select value={editForm.status} onChange={e => setEditForm({...editForm, status: e.target.value})} className={inputClass}>
                  <option value="active">Active</option>
                  <option value="frozen">Frozen</option>
                  <option value="expired">Expired</option>
                </select>
              </Field>
            </div>
            <Field label="Expiry Date">
              <input type="date" value={editForm.expiry_date} onChange={e => setEditForm({...editForm, expiry_date: e.target.value})}
                className={inputClass} />
            </Field>
            <Field label="New Password (leave blank to keep current)">
              <input type="password" value={editForm.password} onChange={e => setEditForm({...editForm, password: e.target.value})}
                className={inputClass} placeholder="Leave blank to keep current" />
            </Field>
            {formError && <p className="text-red-500 text-sm">{formError}</p>}
            <ModalButtons onCancel={() => setShowEditModal(false)} loading={formLoading} label="Save Changes" />
          </form>
        </Modal>
      )}

      {/* Delete Confirm Modal */}
      {showDeleteModal && (
        <Modal title="Delete Member" onClose={() => setShowDeleteModal(false)}>
          <p className="text-gray-600 mb-6">
            Are you sure you want to delete <span className="font-semibold text-gray-800">{selectedMember?.first_name} {selectedMember?.last_name}</span>? This action cannot be undone.
          </p>
          <div className="flex gap-3">
            <button onClick={() => setShowDeleteModal(false)}
              className="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition">
              Cancel
            </button>
            <button onClick={handleDelete} disabled={formLoading}
              className="flex-1 bg-red-500 hover:bg-red-600 text-white py-2.5 rounded-xl text-sm font-semibold transition disabled:opacity-70">
              {formLoading ? 'Deleting...' : 'Delete Member'}
            </button>
          </div>
        </Modal>
      )}
    </div>
  )
}

// Reusable components
const inputClass = "w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"

function Field({ label, children }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
      {children}
    </div>
  )
}

function Modal({ title, onClose, children }) {
  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 px-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8 max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-gray-800">{title}</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-current"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
          </button>
        </div>
        {children}
      </div>
    </div>
  )
}

function ModalButtons({ onCancel, loading, label }) {
  return (
    <div className="flex gap-3 pt-2">
      <button type="button" onClick={onCancel}
        className="flex-1 border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition">
        Cancel
      </button>
      <button type="submit" disabled={loading}
        className="flex-1 bg-green-500 hover:bg-green-600 text-white py-2.5 rounded-xl text-sm font-semibold transition disabled:opacity-70">
        {loading ? 'Saving...' : label}
      </button>
    </div>
  )
}