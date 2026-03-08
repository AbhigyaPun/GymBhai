import { useState } from 'react'

export default function ScanQR() {
  const [activeTab, setActiveTab] = useState('scan')
  const [scanning, setScanning] = useState(false)
  const [manualId, setManualId] = useState('')
  const [result, setResult] = useState(null)

  const handleStartScan = () => setScanning(true)

  const handleManualCheckin = (e) => {
    e.preventDefault()
    if (!manualId) return
    setResult({ name: 'Member', id: manualId, time: new Date().toLocaleTimeString(), status: 'success' })
    setManualId('')
  }

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">QR Code Scanner</h1>
        <p className="text-gray-400 text-sm mt-1">Scan member QR codes for quick check-in</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        <button onClick={() => setActiveTab('scan')}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium transition ${activeTab === 'scan' ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M3 11h2v2H3zm0-4h2v2H3zm4 0h2v2H7zm0 4h2v2H7zm-4 8h2v2H3zm4 0h2v2H7zm4-12h2v2h-2zm0 4h2v2h-2zm4-4h2v2h-2zm0 4h2v2h-2zM3 3v6h6V3H3zm2 4V5h2v2H5zm6-4v6h6V3h-6zm2 4V5h2v2h-2zM3 15v6h6v-6H3zm2 4v-2h2v2H5z"/></svg>
          QR Code Scan
        </button>
        <button onClick={() => setActiveTab('manual')}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium transition ${activeTab === 'manual' ? 'bg-green-500 text-white' : 'bg-white border border-gray-200 text-gray-600'}`}>
          <svg viewBox="0 0 24 24" className="w-4 h-4 fill-current"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
          Manual Check In
        </button>
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Scanner Area */}
        <div className="col-span-2 bg-white rounded-2xl border border-gray-100 p-8">
          {activeTab === 'scan' ? (
            <div className="flex flex-col items-center justify-center min-h-64">
              {!scanning ? (
                <>
                  <div className="w-24 h-24 bg-gray-50 rounded-2xl flex items-center justify-center mb-6">
                    <svg viewBox="0 0 24 24" className="w-12 h-12 fill-gray-300"><path d="M9.5 6.5v3h-3v-3h3M11 5H5v6h6V5zm-1.5 9.5v3h-3v-3h3M11 13H5v6h6v-6zm6.5-6.5v3h-3v-3h3M19 5h-6v6h6V5zm-6 8h1.5v1.5H13V13zm1.5 1.5H16V16h-1.5v-1.5zM16 13h1.5v1.5H16V13zm-3 3h1.5v1.5H13V16zm1.5 1.5H16V19h-1.5v-1.5zM16 16h1.5v1.5H16V16zm1.5-1.5H19V16h-1.5v-1.5zm0 3H19V19h-1.5v-1.5z"/></svg>
                  </div>
                  <p className="text-gray-500 text-sm mb-6">Click the button below to start scanning QR codes</p>
                  <button onClick={handleStartScan}
                    className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-xl font-semibold transition">
                    <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white"><path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm-7 7H3v4h4v-2H5v-2zm14 0v2h-2v2h4v-4h-2zM5 5h2V3H3v4h2V5zm12-2v2h2v2h2V3h-4z"/></svg>
                    Start Camera
                  </button>
                </>
              ) : (
                <div className="w-full">
                  <div className="bg-gray-900 rounded-xl h-64 flex items-center justify-center mb-4">
                    <div className="text-center text-white">
                      <div className="w-48 h-48 border-2 border-green-400 rounded-lg relative mx-auto">
                        <div className="absolute top-0 left-0 w-6 h-6 border-t-4 border-l-4 border-green-400 rounded-tl"></div>
                        <div className="absolute top-0 right-0 w-6 h-6 border-t-4 border-r-4 border-green-400 rounded-tr"></div>
                        <div className="absolute bottom-0 left-0 w-6 h-6 border-b-4 border-l-4 border-green-400 rounded-bl"></div>
                        <div className="absolute bottom-0 right-0 w-6 h-6 border-b-4 border-r-4 border-green-400 rounded-br"></div>
                        <div className="absolute inset-0 flex items-center justify-center">
                          <p className="text-xs text-green-400">Scanning...</p>
                        </div>
                      </div>
                    </div>
                  </div>
                  <button onClick={() => setScanning(false)}
                    className="w-full border border-gray-200 text-gray-600 py-2.5 rounded-xl text-sm font-medium hover:bg-gray-50 transition">
                    Stop Camera
                  </button>
                </div>
              )}
            </div>
          ) : (
            <div>
              <h3 className="font-semibold text-gray-800 mb-4">Manual Check-in</h3>
              <form onSubmit={handleManualCheckin} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Member ID or Email</label>
                  <input value={manualId} onChange={e => setManualId(e.target.value)}
                    className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    placeholder="Enter member ID or email" />
                </div>
                <button type="submit" className="bg-green-500 hover:bg-green-600 text-white px-6 py-2.5 rounded-xl text-sm font-semibold transition">
                  Check In Member
                </button>
              </form>
              {result && (
                <div className="mt-4 p-4 bg-green-50 border border-green-200 rounded-xl">
                  <p className="text-green-700 font-medium">✓ Check-in successful</p>
                  <p className="text-green-600 text-sm">ID: {result.id} at {result.time}</p>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Stats */}
        <div className="space-y-4">
          <div className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-xs text-gray-400 mb-1">Today's Check-ins</p>
            <p className="text-3xl font-bold text-green-500">58</p>
            <p className="text-xs text-gray-400 mt-1">+8% from yesterday</p>
          </div>
          <div className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-xs text-gray-400 mb-1">Currently in Gym</p>
            <p className="text-3xl font-bold text-blue-500">24</p>
            <p className="text-xs text-gray-400 mt-1">#currently inside</p>
          </div>
          <div className="bg-white rounded-2xl border border-gray-100 p-5">
            <p className="text-xs text-gray-400 mb-1">Denied Check-ins</p>
            <p className="text-3xl font-bold text-red-500">3</p>
            <p className="text-xs text-gray-400 mt-1">Expired memberships</p>
          </div>
        </div>
      </div>
    </div>
  )
}