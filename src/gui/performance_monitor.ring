/*
    RingAI Agents Library - GUI Performance Monitor
    Tracks system performance and logs events
*/

class GUIPerformanceMonitor
    # Properties
    aLogs = []
    aMetrics = []
    aHistoricalData = []
    lRunning = false
    nUpdateInterval = 1000  # Default update interval in milliseconds
    nMaxHistoryPoints = 100  # Maximum number of historical data points to keep
    oTimer = NULL

    # UI Components
    oCpuChart = NULL
    oMemoryChart = NULL
    oNetworkChart = NULL
    oDiskChart = NULL
    oLogView = NULL

    func init {
        # Initialize metrics
        aMetrics = [
            :cpu = 0,
            :memory = 0,
            :network = 0,
            :disk = 0,
            :agents_active = 0,
            :tasks_pending = 0,
            :tasks_completed = 0,
            :response_time = 0
        ]

        # Initialize historical data structure
        aHistoricalData = [
            :timestamps = [],
            :cpu = [],
            :memory = [],
            :network = [],
            :disk = []
        ]
    }

    func start {
        lRunning = true
        log("Performance monitoring started")

        # Start timer for automatic updates if not already running
        if oTimer = NULL {
            oTimer = new QTimer(NULL) {
                setInterval(this.nUpdateInterval)
                setTimeoutEvent("this.updateMetrics()")
                start()
            }
        else
            oTimer.start()
        }

        return self
    }

    func stop {
        lRunning = false
        log("Performance monitoring stopped")

        # Stop timer
        if oTimer != NULL {
            oTimer.stop()
        }

        return self
    }

    func setUpdateInterval nInterval {
        if nInterval >= 100 {  # Minimum 100ms to prevent excessive updates
            this.nUpdateInterval = nInterval

            # Update timer if running
            if oTimer != NULL {
                oTimer.setInterval(this.nUpdateInterval)
            }

            log("Update interval set to " + this.nUpdateInterval + "ms")
        }

        return self
    }

    func log cMessage {
        add(aLogs, [
            :timestamp = date(),
            :message = cMessage
        ])

        # Keep only the last 100 logs
        if len(aLogs) > 100 {
            aLogs = slice(aLogs, len(aLogs) - 100, len(aLogs))
        }
    }

    func getLatestLogs nCount {
        if nCount = NULL {
            nCount = 10
        }

        aResult = []
        nStart = max(1, len(aLogs) - nCount + 1)

        for i = nStart to len(aLogs) {
            cTimestamp = aLogs[i][:timestamp]
            cMessage = aLogs[i][:message]
            add(aResult, cTimestamp + " --> " + cMessage)
        }

        return aResult
    }

    func updateMetrics {
        if lRunning {
            # Simulate metrics update
            aMetrics[:cpu] = random(100)
            aMetrics[:memory] = random(100)
            aMetrics[:network] = random(100)
            aMetrics[:disk] = random(100)
            aMetrics[:agents_active] = random(10)
            aMetrics[:tasks_pending] = random(20)
            aMetrics[:tasks_completed] = random(50)
            aMetrics[:response_time] = random(500)

            # Add current metrics to historical data
            addHistoricalDataPoint()

            # Update UI if components are set
            updateCharts()
            updateLogView()
        }

        return self
    }

    func getMetrics {
        return aMetrics
    }

    func getMetric cName {
        if aMetrics[cName] != NULL {
            return aMetrics[cName]
        }
        return 0
    }

    func setMetric cName, nValue {
        aMetrics[cName] = nValue
        return self
    }

    func getHistoricalData {
        return aHistoricalData
    }

    func getHistoricalDataForMetric cMetric {
        if aHistoricalData[cMetric] != NULL {
            return aHistoricalData[cMetric]
        }
        return []
    }

    func setChartComponents oCpu, oMemory, oNetwork, oDisk {
        oCpuChart = oCpu
        oMemoryChart = oMemory
        oNetworkChart = oNetwork
        oDiskChart = oDisk
        return self
    }

    func setLogComponent oLog {
        oLogView = oLog
        return self
    }

    private

    func max x, y {
        if x > y {
            return x
        }
        return y
    }

    func addHistoricalDataPoint {
        # Add timestamp
        add(aHistoricalData[:timestamps], date() + " " + time())

        # Add metrics
        add(aHistoricalData[:cpu], aMetrics[:cpu])
        add(aHistoricalData[:memory], aMetrics[:memory])
        add(aHistoricalData[:network], aMetrics[:network])
        add(aHistoricalData[:disk], aMetrics[:disk])

        # Trim historical data if exceeds maximum points
        if len(aHistoricalData[:timestamps]) > nMaxHistoryPoints {
            aHistoricalData[:timestamps] = slice(aHistoricalData[:timestamps],
                                               len(aHistoricalData[:timestamps]) - nMaxHistoryPoints,
                                               len(aHistoricalData[:timestamps]))
            aHistoricalData[:cpu] = slice(aHistoricalData[:cpu],
                                        len(aHistoricalData[:cpu]) - nMaxHistoryPoints,
                                        len(aHistoricalData[:cpu]))
            aHistoricalData[:memory] = slice(aHistoricalData[:memory],
                                           len(aHistoricalData[:memory]) - nMaxHistoryPoints,
                                           len(aHistoricalData[:memory]))
            aHistoricalData[:network] = slice(aHistoricalData[:network],
                                            len(aHistoricalData[:network]) - nMaxHistoryPoints,
                                            len(aHistoricalData[:network]))
            aHistoricalData[:disk] = slice(aHistoricalData[:disk],
                                         len(aHistoricalData[:disk]) - nMaxHistoryPoints,
                                         len(aHistoricalData[:disk]))
        }
    }

    func updateCharts {
        # Update charts if UI components are set
        if oCpuChart != NULL {
            updateCpuChart()
        }

        if oMemoryChart != NULL {
            updateMemoryChart()
        }

        if oNetworkChart != NULL {
            updateNetworkChart()
        }

        if oDiskChart != NULL {
            updateDiskChart()
        }
    }

    func updateCpuChart {
        # In a real implementation, this would update a chart widget
        # For now, we'll just update a label with the current value
        oCpuChart.setText("CPU Usage: " + aMetrics[:cpu] + "%")
    }

    func updateMemoryChart {
        # In a real implementation, this would update a chart widget
        oMemoryChart.setText("Memory Usage: " + aMetrics[:memory] + "%")
    }

    func updateNetworkChart {
        # In a real implementation, this would update a chart widget
        oNetworkChart.setText("Network Usage: " + aMetrics[:network] + "%")
    }

    func updateDiskChart {
        # In a real implementation, this would update a chart widget
        oDiskChart.setText("Disk Usage: " + aMetrics[:disk] + "%")
    }

    func updateLogView {
        # Update log view if UI component is set
        if oLogView != NULL {
            aLatestLogs = getLatestLogs(5)
            cLogText = ""

            for cLog in aLatestLogs {
                cLogText += cLog + "\n"
            }

            oLogView.setText(cLogText)
        }
    }

    func generatePerformanceReport {
        cReport = "Performance Report - " + date() + " " + time() + "\n"
        cReport += "===========================================\n\n"

        cReport += "Current Metrics:\n"
        cReport += "CPU Usage: " + aMetrics[:cpu] + "%\n"
        cReport += "Memory Usage: " + aMetrics[:memory] + "%\n"
        cReport += "Network Usage: " + aMetrics[:network] + "%\n"
        cReport += "Disk Usage: " + aMetrics[:disk] + "%\n\n"

        cReport += "System Status:\n"
        cReport += "Active Agents: " + aMetrics[:agents_active] + "\n"
        cReport += "Pending Tasks: " + aMetrics[:tasks_pending] + "\n"
        cReport += "Completed Tasks: " + aMetrics[:tasks_completed] + "\n"
        cReport += "Average Response Time: " + aMetrics[:response_time] + "ms\n\n"

        cReport += "Recent Logs:\n"
        aRecentLogs = getLatestLogs(10)
        for cLog in aRecentLogs {
            cReport += cLog + "\n"
        }

        return cReport
    }
