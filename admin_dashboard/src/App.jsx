import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import ScanQR from './pages/ScanQR'
import Members from './pages/Members'
import Attendance from './pages/Attendance'
import Financial from './pages/Financial'
import WorkoutPlans from './pages/WorkoutPlans'
import MealPlans from './pages/MealPlans'
import Feedback from './pages/Feedback'
import Settings from './pages/Settings'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="scan-qr" element={<ScanQR />} />
          <Route path="members" element={<Members />} />
          <Route path="attendance" element={<Attendance />} />
          <Route path="financial" element={<Financial />} />
          <Route path="workout-plans" element={<WorkoutPlans />} />
          <Route path="meal-plans" element={<MealPlans />} />
          <Route path="feedback" element={<Feedback />} />
          <Route path="settings" element={<Settings />} />
        </Route>
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  )
}