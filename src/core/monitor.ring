/*
    RingAI Agents Library - Monitor Management
*/

class PerformanceMonitor

    # Properties
    bVerbose = false
    bIsRunning = false
    nStartTime = 0

    # Constructor
    func init cDbPath
        if bVerbose { logger("Monitor", "Initializing performance monitor", :info) }
        try {
            connectDatabase(cDbPath)
            createTables()
            if bVerbose { logger("Monitor", "Monitor initialized successfully", :success) }
        catch
            if bVerbose { logger("Monitor", "Failed to initialize monitor: " + cCatchError, :error) }
        }
        return self

    # Component Registration
    func registerAgent oAgentRef
        oAgent = oAgentRef
        return self

    func unregisterAgent oAgentRef
        if oAgent = oAgentRef {
            oAgent = null
        }
        return self

    func registerLLM oLLMRef
        oLLM = oLLMRef
        return self

    func registerRL oRLRef
        oRL = oRLRef
        return self

    func registerCrew oCrewRef
        oCrew = oCrewRef
        return self

    func unregisterCrew oCrewRef
        if oCrew = oCrewRef {
            oCrew = null
        }
        return self

    func registerTools oToolsRef
        oTools = oToolsRef
        return self

    func registerTasks oTasksRef
        oTasks = oTasksRef
        return self

    # Monitoring Control
    func startMonitoring
        if bVerbose { logger("Monitor", "Starting performance monitoring", :info) }
        try {
            nStartTime = clock()
            bIsRunning = true
            startMetricsCollection()
            if bVerbose { logger("Monitor", "Monitoring started successfully", :success) }
       catch
            if bVerbose { logger("Monitor", "Failed to start monitoring: " + cCatchError, :error) }
        }
        return self

    func stopMonitoring
        if bVerbose { logger("Monitor", "Stopping performance monitoring", :info) }
        try {
            bIsRunning = false
            if bVerbose {
                logger("Monitor", "Monitoring stopped. Duration: " + (clock() - nStartTime) + "ms", :success)
            }
       catch
            if bVerbose { logger("Monitor", "Failed to stop monitoring: " + cCatchError, :error) }
        }
        return self

    # Recording Functions
    func recordMetric cComponent, cMetricName, nValue, aMetadata
        if !bIsRunning {
            if bVerbose { logger("Monitor", "Cannot record metric - monitoring not started", :warning) }
            return self
        }

        if bVerbose {
            logger("Monitor", "Recording metric: " + cComponent + "." + cMetricName + " = " + nValue, :info)
        }

        try {
            if type(aMetadata) != "LIST" { aMetadata = [] }
            cSQL = "INSERT INTO metrics (timestamp, component, metric_name, value, metadata)
                    VALUES ('" + TimeList()[5] + "', '" + cComponent + "', '" + cMetricName +
                    "', " + nValue + ", '" + listToJSON(aMetadata) + "')"
            sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Monitor", "Metric recorded successfully", :success) }
        catch
            if bVerbose { logger("Monitor", "Failed to record metric: " + cCatchError, :error) }
        }
        return self

    func recordEvent cComponent, cEventType, cDescription, aMetadata
        if !bIsRunning {
            if bVerbose { logger("Monitor", "Cannot record event - monitoring not started", :warning) }
            return self
        }

        if bVerbose {
            logger("Monitor", "Recording event: " + cComponent + "." + cEventType + " - " + cDescription, :info)
        }

        try {
            if type(aMetadata) != "LIST" { aMetadata = [] }
            cSQL = "INSERT INTO events (timestamp, component, event_type, description, metadata)
                    VALUES ('" + TimeList()[5] + "', '" + cComponent + "', '" + cEventType +
                    "', '" + cDescription + "', '" + listToJSON(aMetadata) + "')"
            sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Monitor", "Event recorded successfully", :success) }
        catch
            if bVerbose { logger("Monitor", "Failed to record event: " + cCatchError, :error) }
        }
        return self

    # Analysis Functions
    func getMetricHistory cComponent, cMetricName
        if bVerbose {
            logger("Monitor", "Retrieving metric history for " + cComponent + "." + cMetricName, :info)
        }

        try {
            aResult = []
            cSQL = "SELECT * FROM metrics
                    WHERE component = '"+ cComponent + "' AND metric_name = '"+ cMetricName +
                    "' ORDER BY timestamp"
            aRows = sqlite_execute(oDatabase, cSQL)

            if type(aRows) = "LIST" {
                for row in aRows {
                    aMetadata = JSON2List(row[6])
                    if type(aMetadata) != "LIST" { aMetadata = [] }
                    add(aResult, [
                        :timestamp = "" + row[2],
                        :value = number(row[5]),
                        :metadata = aMetadata
                    ])
                }
            }

            if len(aResult) > 0 {
                if bVerbose { logger("Monitor", "Retrieved " + len(aResult) + " metrics", :success) }
            else
                if bVerbose { logger("Monitor", "No metrics found", :warning) }
            }
            return aResult
        catch
            if bVerbose { logger("Monitor", "Failed to retrieve metrics: " + cCatchError, :error) }
            return []
        }
    func getRecentEvents nLimit
        if bVerbose { logger("Monitor", "Retrieving recent events", :info) }
        if nLimit = 0 nLimit = 10 ok
        try {
            aResult = []
            cSQL = "SELECT * FROM events ORDER BY timestamp DESC LIMIT " + nLimit
            aRows = sqlite_execute(oDatabase, cSQL)
            if type(aRows) = "LIST" {
                for row in aRows {
                    aMetadata = JSON2List(row[6])
                    if type(aMetadata) != "LIST" { aMetadata = [] }
                    add(aResult, [
                        :timestamp = "" + row[2],
                        :type = "" + row[4],
                        :description = "" + row[5],
                        :metadata = aMetadata
                    ])
                }
            }
            if len(aResult) > 0 {
                if bVerbose { logger("Monitor", "Retrieved " + len(aResult) + " events", :success) }
            else
                if bVerbose { logger("Monitor", "No events found", :warning) }
            }
            return aResult
       catch
            if bVerbose { logger("Monitor", "Failed to retrieve events: " + cCatchError, :error) }
            return []
        }

    func getEventHistory cComponent, cEventType
        if bVerbose {
            logger("Monitor", "Retrieving event history for " + cComponent + "." + cEventType, :info)
        }

        try {
            aResult = []
            cSQL = "SELECT * FROM events
                    WHERE component = '"+ cComponent + "' AND event_type = '"+ cEventType +
                    "' ORDER BY timestamp"
            aRows = sqlite_execute(oDatabase, cSQL)

            if type(aRows) = "LIST" {
                for row in aRows {
                    aMetadata = JSON2List(row[6])
                    if type(aMetadata) != "LIST" { aMetadata = [] }
                    add(aResult, [
                        :timestamp = "" + row[2],
                        :description = "" + row[5],
                        :metadata = aMetadata
                    ])
                }
            }

            if len(aResult) > 0 {
                if bVerbose { logger("Monitor", "Retrieved " + len(aResult) + " events", :success) }
            else
                if bVerbose { logger("Monitor", "No events found", :warning) }
            }

            return aResult
        catch
            if bVerbose { logger("Monitor", "Failed to retrieve events: " + cCatchError, :error) }
            return []
        }

    # Metric Management
    func updateMetric cMetricName, nValue
        if type(cMetricName) != "STRING" { return false }
        if type(nValue) != "NUMBER" { return false }

       // oThreads.lockMutex(mutexId)
        aMetrics[cMetricName] = nValue
       // oThreads.unlockMutex(mutexId)

        if bVerbose { logger(cName, "Updated metric: " + cMetricName + " = " + nValue, :info) }
        return true

    func getMetric cMetricName
        if type(cMetricName) != "STRING" { return 0 }

       // oThreads.lockMutex(mutexId)
        nValue = aMetrics[cMetricName]
       // oThreads.unlockMutex(mutexId)

        return nValue

    # Cleanup
    func destroy
        stopMonitoring()
        sqlite_close(oDatabase)

    private

    # Private Properties
        oDatabase
        aMetrics = []
        aEvents = []

        nSamplingRate = 0.1  # 1 = 1000 milliseconds


        # Component References
        oAgent = null
        oLLM = null
        oRL = null
        oCrew = null
        oTools = null
        oTasks = null

    # Database Management
    func connectDatabase cDatabasePath
        if bVerbose { logger("Monitor", "Connecting to monitor database", :info) }
        try {
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDatabasePath)
            if bVerbose { logger("Monitor", "Database connection established successfully", :success) }
       catch
            if bVerbose { logger("Monitor", "Failed to connect to database: " + cCatchError, :error) }
        }

    func createTables
        if bVerbose { logger("Monitor", "Creating monitor database tables", :info) }
        try {
            sqlite_execute(oDatabase, "CREATE TABLE IF NOT EXISTS metrics (
                id INTEGER PRIMARY KEY,
                timestamp TEXT,
                component TEXT,
                metric_name TEXT,
                value REAL,
                metadata TEXT
            )")

            sqlite_execute(oDatabase, "CREATE TABLE IF NOT EXISTS events (
                id INTEGER PRIMARY KEY,
                timestamp TEXT,
                component TEXT,
                event_type TEXT,
                description TEXT,
                metadata TEXT
            )")

            if bVerbose { logger("Monitor", "Database tables created successfully", :success) }
       catch
            if bVerbose { logger("Monitor", "Failed to create database tables: " + cCatchError, :error) }
        }

    # Metrics Collection
    func startMetricsCollection
        if bVerbose { logger("Monitor", "Starting metrics collection", :info) }
        try {
            collectMetrics()
            if bVerbose { logger("Monitor", "Metrics collection started", :success) }
       catch
            if bVerbose { logger("Monitor", "Failed to start metrics collection: " + cCatchError, :error) }
        }
    func collectMetrics
        if bVerbose { logger("Monitor", "Collecting metrics", :info) }
        try {
            if oAgent != null { collectAgentMetrics() }
            if oLLM != null { collectLLMMetrics() }
            if oRL != null { collectRLMetrics() }
            if oCrew != null { collectCrewMetrics() }
            if oTools != null { collectToolsMetrics() }
            if oTasks != null { collectTaskMetrics() }
            if bVerbose { logger("Monitor", "Metrics collected successfully", :success) }
       catch
            if bVerbose { logger("Monitor", "Failed to collect metrics: " + cCatchError, :error) }
        }

    func collectAgentMetrics
        if bVerbose { logger("Monitor", "Collecting agent metrics", :info) }
        try {
            recordMetric(:Agent, :energy_level, oAgent.getEnergyLevel())
            recordMetric(:Agent, :task_completion_rate,
                        calculateTaskCompletionRate(oAgent.getTaskHistory()))
            recordMetric(:Agent, :memory_usage,
                        calculateMemoryUsage(oAgent.getMemories()))
            if bVerbose { logger("Monitor", "Agent metrics collected successfully", :success) }
       catch
            recordEvent(:Agent, :metric_collection_error, cCatchError)
            if bVerbose { logger("Monitor", "Failed to collect agent metrics: " + cCatchError, :error) }
        }

    func collectLLMMetrics
        if bVerbose { logger("Monitor", "Collecting LLM metrics", :info) }
        try {
            recordMetric(:LLM, :response_time,
                        calculateAverageResponseTime(oLLM.getResponseHistory()))
            recordMetric(:LLM, :token_usage,
                        calculateTokenUsage(oLLM.getResponseHistory()))
            recordMetric(:LLM, :cache_hit_rate,
                        calculateCacheHitRate(oLLM.getCacheStats()))
            if bVerbose { logger("Monitor", "LLM metrics collected successfully", :success) }
       catch
            recordEvent(:LLM, :metric_collection_error, cCatchError)
            if bVerbose { logger("Monitor", "Failed to collect LLM metrics: " + cCatchError, :error) }
        }

    func collectRLMetrics
        if bVerbose { logger("Monitor", "Collecting RL metrics", :info) }
        try {
            recordMetric(:RL, :exploration_rate, oRL.getExplorationRate())
            recordMetric(:RL, :average_reward,
                        calculateAverageReward(oRL.getRewardHistory()))
            recordMetric(:RL, :q_value_convergence,
                        calculateQValueConvergence(oRL.getQTable()))
            if bVerbose { logger("Monitor", "RL metrics collected successfully", :success) }
       catch
            recordEvent(:RL, :metric_collection_error, cCatchError)
            if bVerbose { logger("Monitor", "Failed to collect RL metrics: " + cCatchError, :error) }
        }

    func collectCrewMetrics
        if bVerbose { logger("Monitor", "Collecting crew metrics", :info) }
        try {
            recordMetric(:Crew, :active_agents, len(oCrew.getActiveAgents()))
            recordMetric(:Crew, :task_distribution,
                        calculateTaskDistribution(oCrew.getTaskAssignments()))
            recordMetric(:Crew, :collaboration_score,
                        calculateCollaborationScore(oCrew.getInteractions()))
            if bVerbose { logger("Monitor", "Crew metrics collected successfully", :success) }
       catch
            recordEvent(:Crew, :metric_collection_error, cCatchError)
            if bVerbose { logger("Monitor", "Failed to collect crew metrics: " + cCatchError, :error) }
        }

    func collectToolsMetrics
        if bVerbose { logger("Monitor", "Collecting tools metrics", :info) }
        try {
            recordMetric(:Tools, :usage_frequency,
                        calculateToolUsage(oTools.getUsageStats()))
            recordMetric(:Tools, :success_rate,
                        calculateToolSuccessRate(oTools.getExecutionHistory()))
            recordMetric(:Tools, :average_execution_time,
                        calculateAverageExecutionTime(oTools.getExecutionHistory()))
            if bVerbose { logger("Monitor", "Tools metrics collected successfully", :success) }
       catch
            recordEvent(:Tools, :metric_collection_error, cCatchError)
            if bVerbose { logger("Monitor", "Failed to collect tools metrics: " + cCatchError, :error) }
        }

    func collectTaskMetrics
        if bVerbose { logger("Monitor", "Collecting task metrics", :info) }
        try {
            recordMetric(:Tasks, :completion_rate,
                        calculateTaskCompletionRate(oTasks.getAllTasks()))
            recordMetric(:Tasks, :average_duration,
                        calculateAverageTaskDuration(oTasks.getCompletedTasks()))
            recordMetric(:Tasks, :failure_rate,
                        calculateTaskFailureRate(oTasks.getAllTasks()))
            if bVerbose { logger("Monitor", "Task metrics collected successfully", :success) }
       catch
            recordEvent(:Tasks, :metric_collection_error, cCatchError)
            if bVerbose { logger("Monitor", "Failed to collect task metrics: " + cCatchError, :error) }
        }

    # Utility Functions
    func calculateTaskCompletionRate aTasks
        if len(aTasks) = 0 { return 0 }
        nCompleted = 0
        for task in aTasks {
            if task[:status] = :completed { nCompleted++ }
        }
        return nCompleted / len(aTasks) * 100

    func calculateMemoryUsage aMemories
        if len(aMemories) = 0 { return 0 }
        nTotal = 0
        for memory in aMemories {
            nTotal += len(listToJSON(memory))
        }
        return nTotal

    func calculateAverageResponseTime aHistory
        if len(aHistory) = 0 { return 0 }
        nTotal = 0
        for response in aHistory {
            nTotal += response[:duration]
        }
        return nTotal / len(aHistory)

    func calculateTokenUsage aHistory
        if len(aHistory) = 0 { return 0 }
        nTotal = 0
        for response in aHistory {
            nTotal += response[:tokens]
        }
        return nTotal

    func calculateCacheHitRate aCacheStats
        nTotal = aCacheStats[:hits] + aCacheStats[:misses]
        if nTotal = 0 { return 0 }
        return (aCacheStats[:hits] / nTotal) * 100

    func calculateAverageReward aRewardHistory
        if len(aRewardHistory) = 0 { return 0 }
        nTotal = 0
        for reward in aRewardHistory {
            nTotal += reward[:reward]
        }
        return nTotal / len(aRewardHistory)

    func calculateQValueConvergence aQTable
        if len(aQTable) = 0 { return 0 }
        nTotal = 0
        nCount = 0
        for row in aQTable {
            for value in row {
                nTotal += value
                nCount++
            }
        }
        return nTotal / nCount

    func calculateTaskDistribution aAssignments
        if len(aAssignments) = 0 { return 0 }
        aAgentCounts = []
        for assignment in aAssignments {
            cAgent = assignment[:agent]
            if !isKey(aAgentCounts, cAgent) {
                aAgentCounts[cAgent] = 0
            }
            aAgentCounts[cAgent]++
        }
        nMax = 0
        nMin = 999999
        for cAgent in aAgentCounts {
            if aAgentCounts[cAgent] > nMax { nMax = aAgentCounts[cAgent] }
            if aAgentCounts[cAgent] < nMin { nMin = aAgentCounts[cAgent] }
        }
        return (nMax - nMin) / len(aAssignments) * 100

    func calculateCollaborationScore aInteractions
        if len(aInteractions) = 0 { return 0 }
        nScore = 0
        for interaction in aInteractions {
            if interaction[:type] = :collaboration {
                nScore += iif(interaction[:success], 1, -1)
            }
        }
        return nScore / len(aInteractions) * 100

    func calculateToolUsage aStats
        if len(aStats) = 0 { return 0 }
        nTotal = 0
        for stat in aStats {
            nTotal += stat[:count]
        }
        return nTotal

    func calculateToolSuccessRate aHistory
        if len(aHistory) = 0 { return 0 }
        nSuccess = 0
        for execution in aHistory {
            if execution[:status] = :success { nSuccess++ }
        }
        return nSuccess / len(aHistory) * 100

    func calculateAverageExecutionTime aHistory
        if len(aHistory) = 0 { return 0 }
        nTotal = 0
        for execution in aHistory {
            nTotal += execution[:duration]
        }
        return nTotal / len(aHistory)

    func calculateAverageTaskDuration aTasks
        if len(aTasks) = 0 { return 0 }
        nTotal = 0
        for task in aTasks {
            nTotal += task[:duration]
        }
        return nTotal / len(aTasks)

    func calculateTaskFailureRate aTasks
        if len(aTasks) = 0 { return 0 }
        nFailed = 0
        for task in aTasks {
            if task[:status] = :failed { nFailed++ }
        }
        return nFailed / len(aTasks) * 100
