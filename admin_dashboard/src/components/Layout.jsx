import { Outlet, Navigate } from 'react-router-dom'
import Sidebar from '../components/Sidebar'

export default function Layout() {
  const token = localStorage.getItem('admin_token')
  if (!token) return <Navigate to="/login" replace />

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="ml-64 flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  )
}