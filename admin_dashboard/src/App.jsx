import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Layout from './components/Layout'
import Members from './pages/Members'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/members" replace />} />
          <Route path="dashboard" element={<div />} />
          <Route path="scan-qr" element={<div />} />
          <Route path="members" element={<Members />} />
          <Route path="attendance" element={<div />} />
          <Route path="financial" element={<div />} />
          <Route path="workout-plans" element={<div />} />
          <Route path="feedback" element={<div />} />
          <Route path="staff" element={<div />} />
          <Route path="settings" element={<div />} />
        </Route>
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  )
}