import { useState, useEffect, useRef } from 'react'
import API_BASE_URL from '../config'

export default function ScanQR() {
  const [activeTab, setActiveTab] = useState('scan')
  const [scanning, setScanning] = useState(false)
  const [manualId, setManualId] = useState('')
  const [result, setResult] = useState(null)
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)
  const [stats, setStats] = useState({ today: 0, inside: 0, denied: 0 })
  const [recentScans, setRecentScans] = useState([])
  const videoRef = useRef(null)
  const streamRef = useRef(null)
  const intervalRef = useRef(null)

  useEffect(() => {
    fetchStats()
    return () => stopCamera()
  }, [])

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('admin_token')
      const res = await fetch(`${API_BASE_URL}/attendance/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      if (res.ok) {
        const data = await res.json()
        const today = new Date().toDateString()
        const todayScans = data.filter(r => new Date(r.checked_in).toDateString() === today)
        setStats({ today: todayScans.length, inside: todayScans.length, denied: 0 })
        setRecentScans(data.slice(0, 8))
      }
    } catch (e) {}
  }

  const sendQRToBackend = async (qrData) => {
    if (loading) return
    setLoading(true)
    setResult(null)
    setError(null)
    try {
      const token = localStorage.getItem('admin_token')
      const res = await fetch(`${API_BASE_URL}/attendance/scan/`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ qr_data: qrData })
      })
      const data = await res.json()
      if (res.status === 201) {
        setResult({ success: true, message: data.message, member: data.member, time: data.checked_in })
        fetchStats()
        stopCamera()
      } else {
        setError(data.error || 'Check-in failed')
        setResult({ success: false, member: data.member })
        stopCamera()
      }
    } catch (e) {
      setError('Cannot connect to server')
    } finally {
      setLoading(false)
    }
  }

  const startCamera = async () => {
    setResult(null)
    setError(null)
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
      streamRef.current = stream
      if (videoRef.current) videoRef.current.srcObject = stream
      setScanning(true)

      // Use BarcodeDetector API if available
      if ('BarcodeDetector' in window) {
        const detector = new window.BarcodeDetector({ formats: ['qr_code'] })
        intervalRef.current = setInterval(async () => {
          if (videoRef.current && videoRef.current.readyState === 4) {
            try {
              const barcodes = await detector.detect(videoRef.current)
              if (barcodes.length > 0) {
                clearInterval(intervalRef.current)
                await sendQRToBackend(barcodes[0].rawValue)
              }
            } catch (e) {}
          }
        }, 500)
      }
    } catch (e) {
      setError('Camera access denied. Please allow camera permission.')
    }
  }

  const stopCamera = () => {
    if (intervalRef.current) clearInterval(intervalRef.current)
    if (streamRef.current) streamRef.current.getTracks().forEach(t => t.stop())
    streamRef.current = null
    setScanning(false)
  }

  const handleManualCheckin = async (e) => {
    e.preventDefault()
    if (!manualId.trim()) return
    await sendQRToBackend(manualId.trim())
    setManualId('')
  }

  const formatTime = (iso) => {
    if (!iso) return ''
    return new Date(iso).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
  }

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">QR Code Scanner</h1>
        <p className="text-gray-400 text-sm mt-1">Scan member QR codes for quick check-in</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        <button onClick={() => { setActiveTab('scan'); setResult(null); setError(null); stopCamera() }}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium transition ${activeTab === 'scan' ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M3 11h2v2H3zm0-4h2v2H3zm4 0h2v2H7zm0 4h2v2H7zm-4 8h2v2H3zm4 0h2v2H7zm4-12h2v2h-2zm0 4h2v2h-2zm4-4h2v2h-2zm0 4h2v2h-2zM3 3v6h6V3H3zm2 4V5h2v2H5zm6-4v6h6V3h-6zm2 4V5h2v2h-2zM3 15v6h6v-6H3zm2 4v-2h2v2H5z"/></svg>
          QR Code Scan
        </button>
        <button onClick={() => { setActiveTab('manual'); setResult(null); setError(null); stopCamera() }}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium transition ${activeTab === 'manual' ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
          Manual Check In
        </button>
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Scanner / Manual Area */}
        <div className="col-span-2 bg-white rounded-2xl border border-gray-100 p-8">

          {/* Success Result */}
          {result?.success && (
            <div className="mb-6 p-5 bg-green-50 border border-green-200 rounded-xl">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center">
                  <svg viewBox="0 0 24 24" className="w-6 h-6 fill-white"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                </div>
                <div>
                  <p className="font-bold text-green-700 text-lg">{result.message}</p>
                  <p className="text-green-600 text-sm">
                    {result.member?.membership && `${result.member.membership.charAt(0).toUpperCase() + result.member.membership.slice(1)} Member`}
                    {result.time && ` · ${formatTime(result.time)}`}
                  </p>
                </div>
              </div>
              <button onClick={() => { setResult(null); setError(null) }}
                className="mt-3 text-sm text-green-600 font-medium hover:text-green-700">
                ← Scan another member
              </button>
            </div>
          )}

          {/* Error Result */}
          {(error || result?.success === false) && (
            <div className="mb-6 p-5 bg-red-50 border border-red-200 rounded-xl">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-10 h-10 bg-red-500 rounded-full flex items-center justify-center">
                  <svg viewBox="0 0 24 24" className="w-6 h-6 fill-white"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </div>
                <div>
                  <p className="font-bold text-red-700">Check-in Denied</p>
                  <p className="text-red-600 text-sm">{error}</p>
                  {result?.member && (
                    <p className="text-red-500 text-xs mt-1">
                      Member: {result.member.first_name} {result.member.last_name} · Status: {result.member.status}
                    </p>
                  )}
                </div>
              </div>
              <button onClick={() => { setResult(null); setError(null) }}
                className="mt-3 text-sm text-red-600 font-medium hover:text-red-700">
                ← Try again
              </button>
            </div>
          )}

          {/* QR Scan Tab */}
          {activeTab === 'scan' && !result && (
            <div className="flex flex-col items-center justify-center min-h-64">
              {!scanning ? (
                <>
                  <div className="w-24 h-24 bg-gray-50 rounded-2xl flex items-center justify-center mb-6">
                    <svg viewBox="0 0 24 24" className="w-12 h-12 fill-gray-300"><path d="M9.5 6.5v3h-3v-3h3M11 5H5v6h6V5zm-1.5 9.5v3h-3v-3h3M11 13H5v6h6v-6zm6.5-6.5v3h-3v-3h3M19 5h-6v6h6V5zm-6 8h1.5v1.5H13V13zm1.5 1.5H16V16h-1.5v-1.5zM16 13h1.5v1.5H16V13zm-3 3h1.5v1.5H13V16zm1.5 1.5H16V19h-1.5v-1.5zM16 16h1.5v1.5H16V16zm1.5-1.5H19V16h-1.5v-1.5zm0 3H19V19h-1.5v-1.5z"/></svg>
                  </div>
                  <p className="text-gray-500 text-sm mb-6">Click the button below to start scanning QR codes</p>
                  <button onClick={startCamera}
                    className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-xl font-semibold transition">
                    <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white"><path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm-7 7H3v4h4v-2H5v-2zm14 0v2h-2v2h4v-4h-2zM5 5h2V3H3v4h2V5zm12-2v2h2v2h2V3h-4z"/></svg>
                    Start Camera
                  </button>
                  <p className="text-xs text-gray-400 mt-3">Or switch to Manual Check In to enter QR data directly</p>
                </>
              ) : (
                <div className="w-full">
                  <div className="relative bg-gray-900 rounded-xl overflow-hidden mb-4" style={{ height: '300px' }}>
                    <video ref={videoRef} autoPlay playsInline muted className="w-full h-full object-cover" />
                    {/* Scanner overlay */}
                    <div className="absolute inset-0 flex items-center justify-center">
                      <div className="w-52 h-52 relative">
                        <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-green-400"></div>
                        <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-green-400"></div>
                        <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-green-400"></div>
                        <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-green-400"></div>
                        <div className="absolute top-1/2 left-0 right-0 h-0.5 bg-green-400 opacity-70 animate-pulse"></div>
                      </div>
                    </div>
                    {loading && (
                      <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
                        <div className="text-white text-center">
                          <div className="w-10 h-10 border-4 border-white border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
                          <p className="text-sm">Verifying...</p>
                        </div>
                      </div>
                    )}
                  </div>
                  <p className="text-center text-sm text-gray-500 mb-3">Point camera at member's QR code</p>
                  <button onClick={stopCamera}
                    className="w-full border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition">
                    Stop Camera
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Manual Tab */}
          {activeTab === 'manual' && !result && (
            <div>
              <h3 className="font-semibold text-gray-800 mb-2">Manual Check-in</h3>
              <p className="text-sm text-gray-400 mb-6">Paste the QR data string from the member's app</p>
              <form onSubmit={handleManualCheckin} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">QR Data</label>
                  <input value={manualId} onChange={e => setManualId(e.target.value)}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400 font-mono"
                    placeholder="GYMBHAI:1:abc123:signature..." />
                  <p className="text-xs text-gray-400 mt-1">Format: GYMBHAI:member_id:qr_token:signature</p>
                </div>
                <button type="submit" disabled={loading}
                  className="flex items-center gap-2 bg-green-500 hover:bg-green-600 disabled:opacity-50 text-white px-6 py-2.5 rounded-xl text-sm font-semibold transition">
                  {loading ? 'Checking in...' : 'Check In Member'}
                </button>
              </form>
            </div>
          )}
        </div>

        {/* Stats */}
        <div className="space-y-4">
          <div className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-xs text-gray-400 mb-1">Today's Check-ins</p>
            <p className="text-3xl font-bold text-green-500">{stats.today}</p>
            <p className="text-xs text-gray-400 mt-1">Total today</p>
          </div>
          <div className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-xs text-gray-400 mb-1">Currently in Gym</p>
            <p className="text-3xl font-bold text-blue-500">{stats.inside}</p>
            <p className="text-xs text-gray-400 mt-1">Checked in today</p>
          </div>
          <div className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-xs text-gray-400 mb-1">Denied Check-ins</p>
            <p className="text-3xl font-bold text-red-500">{stats.denied}</p>
            <p className="text-xs text-gray-400 mt-1">Expired/frozen</p>
          </div>

          {/* Recent scans */}
          {recentScans.length > 0 && (
            <div className="bg-white rounded-2xl border border-gray-100 p-5">
              <p className="text-sm font-semibold text-gray-700 mb-3">Recent Check-ins</p>
              <div className="space-y-2">
                {recentScans.slice(0, 5).map((s) => (
                  <div key={s.id} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 bg-green-100 rounded-full flex items-center justify-center text-green-600 text-xs font-bold">
                        {s.member_name?.[0] ?? '?'}
                      </div>
                      <span className="text-xs text-gray-700 font-medium truncate max-w-24">{s.member_name}</span>
                    </div>
                    <span className="text-xs text-gray-400">{formatTime(s.checked_in)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}