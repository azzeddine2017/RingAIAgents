/*
    RingAI Agents Library - Crew Management
    Handles collaboration between multiple agents
*/


class Crew
    # Constants
    IDLE = :idle
    WORKING = :working
    PLANNING = :planning
    REVIEWING = :reviewing
    ERROR = :error
    POOL_SIZE = 4  # Number of worker threads
    oThreads
    # Constructor
    func init objectName, cCrewName, oLeaderAgent
        # Initialize properties
        cId = generateUniqueId("crew_")
        cName = cCrewName
        cObjective = ""
        cState = IDLE
        oObject = self

        # Initialize arrays
        aMembers = []
        aTaskQueue = []
        aCompletedTasks = []
        aWorkingPlan = []
        aConflicts = []
        aMessages = []
        aPerformance = []
        aMetadata = []

        # Initialize settings
        bVerbose = 1
        nMaxConcurrentTasks = 5

        # Initialize leader
        if type(oLeaderAgent) = "OBJECT" and classname(oLeaderAgent) = "agent" {
            oLeader = oLeaderAgent
            add(aMembers, oLeader)  # Add leader to members
            if bVerbose { logger(cName, "Crew created with leader: " + oLeaderAgent.getName(), :success) }
        else
            if bVerbose { logger(cName, "Failed to set leader - invalid agent object", :error) }
        }

        # Initialize thread pool
        oThreads = new ThreadManager(POOL_SIZE)
        //oThreads.enableDebug()

        # Initialize synchronization objects
        queueMutex = oThreads.createMutex(1)
        resultMutex = oThreads.createMutex(1)
        taskAvailable = oThreads.createCondition()

        # Initialize task queues
        taskQueue = []
        taskResults = []

        # Start worker threads
        for i = 1 to POOL_SIZE
            oThreads.setThreadName(i, "Worker-" + i)
            oThreads.createThread(i, objectName + ".processAgentTasks(" + i + ")")
        next

        return self

    # Basic getters and setters
    func getId return cId
    func setId cValue
        cId = cValue
        return self
    func getName return cName
    func getObjective return cObjective
    func getState return cState
    func getMembers return aMembers
    func getLeader return oLeader
    func getTaskQueue return aTaskQueue
    func getActiveTasks return aTaskQueue
    func getCompletedTasks return aCompletedTasks
    func getWorkingPlan return aWorkingPlan
    func getConflicts return aConflicts
    func getMetadata return aMetadata

    func setLeader oAgent
        if type(oAgent) = "OBJECT" and classname(oAgent) = "agent" {
            oLeader = oAgent
            oAgent.setCrew(self)
            if bVerbose { logger(cName, "Leader set to: " + oAgent.getName(), :info) }
        }
        return self

    func setName cValue
        cName = cValue
        return self

    func setObjective cValue
        cObjective = cValue
        return self

    func getPerformanceScore()
        nTotalScore = 0
        nMemberCount = len(aMembers)
        for member in aMembers {
            nTotalScore += member.getPerformanceScore()
        }
        return nTotalScore / nMemberCount

    # Member Management
    func addMember oAgent
        if type(oAgent) = "OBJECT" and classname(oAgent) = "agent" {
            if !isMember(oAgent) {
                add(aMembers, oAgent)
                oAgent.setCrew(self)
                if bVerbose { logger(cName, "Added new member: " + oAgent.getName(), :success) }
                return true
            else
                if bVerbose { logger(cName, "Agent is already a member", :warning) }
            }
       else
            if bVerbose { logger(cName, "Invalid agent object provided", :error) }
        }
        return false

    func removeMember oAgent
        if type(oAgent) = "OBJECT" and classname(oAgent) = "agent" {
            for i = 1 to len(aMembers) {
                if aMembers[i].getId() = oAgent.getId() {
                    agentName = aMembers[i].getName()
                    del(aMembers, i)
                    if bVerbose { logger(cName, "Removed member: " + agentName, :info) }
                    return true
                }
            }
            if bVerbose { logger(cName, "Member not found", :warning) }
       else
            if bVerbose { logger(cName, "Invalid agent object provided", :error) }
        }
        return false

    # Task Management
    func addTask p1
       
            # Called with just a task object
            oTask = p1
            if type(oTask) = "OBJECT" and classname(oTask) = "task" {
                add(aTaskQueue, oTask)
                if bVerbose {
                    logger(cName, "New task added: " + oTask.getDescription() + " (Priority: " + oTask.getPriority() + ")", :info)
                }
                return true
            }
            if bVerbose { logger(cName, "Invalid task object provided", :error) }
            return false

     func addAgentTask oAgent, aTaskData
            # Add to thread task queue
            oThreads.lockMutex(queueMutex)
            add(taskQueue, [oAgent, aTaskData])
            oThreads.signalCondition(taskAvailable)
            oThreads.unlockMutex(queueMutex)

            if bVerbose {
                logger(cName, "Added thread task for agent: " + oAgent.getName(), :info)
            }
            return true
        

    func assignTask oTask, oAgent
        if !isMember(oAgent) {
            if bVerbose { logger(cName, "Cannot assign task - agent is not a crew member", :error) }
            return false
        }

        if type(oTask) != "OBJECT" or classname(oTask) != "task" {
            if bVerbose { logger(cName, "Invalid task object provided", :error) }
            return false
        }

        if bVerbose { logger(cName, "Attempting to assign task to " + oAgent.getName(), :info) }

        # Add task to queue if not already added
        if !isTaskInQueue(oTask) {
            addTask(oTask)
        }

        # Assign task to agent
        if oAgent.assignTask(oTask) {
            if bVerbose { logger(cName, "Task successfully assigned to " + oAgent.getName(), :success) }
            return true
        }

        if bVerbose { logger(cName, "Failed to assign task to " + oAgent.getName(), :error) }
        return false

    # Planning
    func createWorkPlan
        if len(aTaskQueue) = 0 {
            if bVerbose { logger(cName, "No tasks in queue to plan", :warning) }
            return []
        }

        if bVerbose { logger(cName, "Creating work plan for " + len(aTaskQueue) + " tasks", :info) }
        try {
            aWorkingPlan = []
            for task in aTaskQueue {
                bestAgent = findBestAgentForTask(task)
                if bestAgent != NULL {
                    add(aWorkingPlan, [
                        :task = task,
                        :agent = bestAgent
                    ])
                    if bVerbose {
                        logger(cName, "Planned task '" + task.getDescription() + "' for " + bestAgent.getName(), :success)
                    }
               else
                    if bVerbose {
                        logger(cName, "No suitable agent found for task: " + task.getDescription(), :warning)
                    }
                }
            }
       catch
            if bVerbose { logger(cName, "Error creating work plan: " + cCatchError, :error) }
            return []
        }

        if bVerbose {
            logger(cName, "Work plan created with " + len(aWorkingPlan) + " assigned tasks", :success)
        }
        return aWorkingPlan

    # Conflict Resolution
    func reportConflict cDescription, oAgent1, oAgent2
        if bVerbose { logger(cName, "New conflict reported: " + cDescription, :warning) }
        add(aConflicts, [
            :id = generateUniqueId("conflict"),
            :description = cDescription,
            :agent1 = oAgent1.getId(),
            :agent2 = oAgent2.getId(),
            :status = :pending,
            :timestamp = date()
        ])
        return true

    func resolveConflict nConflictId, cResolution
        for conflict in aConflicts {
            if conflict[:id] = nConflictId {
                conflict[:status] = :resolved
                conflict[:resolution] = cResolution
                conflict[:resolvedAt] = date()
                if bVerbose { logger(cName, "Conflict #" + nConflictId + " resolved: " + cResolution, :success) }
                return true
            }
        }
        if bVerbose { logger(cName, "Conflict #" + nConflictId + " not found", :error) }
        return false

    # Role Management
    func assignRole oAgent, cRole
        if !isMember(oAgent) {
            if bVerbose { logger(cName, "Cannot assign role - agent is not a crew member", :error) }
            return false
        }

        for member in aMembers {
            if member.getId() = oAgent.getId() {
                member.setRole(cRole)
                if bVerbose { logger(cName, "Role " + cRole + " assigned to " + oAgent.getName(), :success) }
                return true
            }
        }
        return false

    func getMemberRole oAgent
        if !isMember(oAgent) { return null }

        for member in aMembers {
            if member.getId() = oAgent.getId() {
                return member.getRole()
            }
        }
        return null

    # Communication
    func broadcast cMessage
        if len(aMembers) = 0 {
            if bVerbose { logger(cName, "No members to broadcast to", :warning) }
            return false
        }

        add(aMessages, [
            :content = cMessage,
            :timestamp = TimeList()[5]
        ])

        if bVerbose { logger(cName, "Broadcasting message: " + cMessage, :info) }
        for member in aMembers {
            member.receiveMessage(cMessage)
        }
        return true

    func getMessages
        return aMessages

    # Performance Tracking
    func recordPerformance oAgent, cMetric, nValue
        if !isMember(oAgent) {
            if bVerbose { logger(cName, "Cannot record performance - agent is not a crew member", :error) }
            return false
        }

        if aPerformance[oAgent.getId()] = NULL {
            aPerformance[oAgent.getId()] = []
        }

        add(aPerformance[oAgent.getId()], [
            :metric = cMetric,
            :value = nValue,
            :timestamp = date()
        ])

        if bVerbose {
            logger(cName, "Recorded " + cMetric + " = " + nValue + " for " + oAgent.getName(), :info)
        }
        return true

    func getMemberPerformance oAgent, cMetric
        if !isMember(oAgent) { return null }

        if aPerformance[oAgent.getId()] = NULL { return null }

        for record in aPerformance[oAgent.getId()] {
            if record[:metric] = cMetric {
                return record[:value]
            }
        }
        return null

    func getConflictStatus nConflictId
        for conflict in aConflicts {
            if conflict[:id] = nConflictId {
                return conflict[:status]
            }
        }
        return null

    # State Management
    func setState cNewState
        if find([IDLE, WORKING, PLANNING, REVIEWING, ERROR], cNewState) {
            cState = cNewState
            if bVerbose { logger(cName, "State changed to: " + cNewState, :info) }
        }
        return self

    # Serialization
    func toJSON
        aSerializedMembers = []
        for member in aMembers {
            if type(member) = "OBJECT" {
                add(aSerializedMembers, member.toJSON())
            }
        }

        aSerializedTasks = []
        for task in aTaskQueue {
            if type(task) = "OBJECT" {
                add(aSerializedTasks, task.toJSON())
            }
        }

        aSerializedPlan = []
        for plan in aWorkingPlan {
            if type(plan) = "LIST" and type(plan[:task]) = "OBJECT" and type(plan[:agent]) = "OBJECT" {
                add(aSerializedPlan, [
                    :task = plan[:task].toJSON(),
                    :agent = plan[:agent].toJSON()
                ])
            }
        }

        aSerializedLeader = NULL
        if type(oLeader) = "OBJECT" {
            aSerializedLeader = oLeader.toJSON()
        }

        return listToJSON([
            :id = cId,
            :name = cName,
            :objective = cObjective,
            :state = cState,
            :members = aSerializedMembers,
            :leader = aSerializedLeader,
            :taskQueue = aSerializedTasks,
            :completedTasks = aCompletedTasks,
            :workingPlan = aSerializedPlan,
            :conflicts = aConflicts,
            :metadata = aMetadata
        ], 0)

    func fromJSON cJSON
        aData = json2list(cJSON)
        if type(aData) = "LIST" {
            cId = aData[:id]
            cName = aData[:name]
            cObjective = aData[:objective]
            cState = aData[:state]

            # Reconstruct leader
            if aData[:leader] != null {
                oLeader = new Agent("","")
                oLeader.fromJSON(aData[:leader])
            }

            # Reconstruct members
            aMembers = []
            for memberData in aData[:members] {
                oAgent = new Agent("","")
                oAgent.fromJSON(memberData)
                addMember(oAgent)
            }

            # Reconstruct tasks
            aTaskQueue = []
            for taskData in aData[:taskQueue] {
                oTask = new Task("")
                oTask.fromJSON(taskData)
                addTask(oTask)
            }

            # Reconstruct working plan
            aWorkingPlan = []
            for planData in aData[:workingPlan] {
                oTask = new Task("")
                oTask.fromJSON(planData[:task])

                oAgent = new Agent("","")
                oAgent.fromJSON(planData[:agent])

                add(aWorkingPlan, [
                    :task = oTask,
                    :agent = oAgent
                ])
            }

            aConflicts = aData[:conflicts]
            aMetadata = aData[:metadata]
        }
        return self

    func processAgentTasks nWorkerId
        while true
            oThreads.lockMutex(queueMutex)

            while len(taskQueue) = 0
                oThreads.waitCondition(taskAvailable, queueMutex)
            end

            # Get next task
            currentTask = taskQueue[1]
            del(taskQueue, 1)

            oThreads.unlockMutex(queueMutex)

            # Process task
            try {
                result = executeAgentTask(currentTask)

                # Store result
                oThreads.lockMutex(resultMutex)
                add(taskResults, [currentTask[1], result])
                oThreads.unlockMutex(resultMutex)
            catch
                logger("Worker-" + nWorkerId, "Error processing task: " + cCatchError, :error)
            }
        end

    private

    # private Properties
        cId = ""
        cName = ""
        cObjective = ""
        cState = IDLE
        aMembers = []
        oLeader = null
        aTaskQueue = []
        aCompletedTasks = []
        aWorkingPlan = []
        aConflicts = []
        aMessages = []
        aPerformance = []
        aMetadata = []
        bVerbose = false
        nMaxConcurrentTasks = 5

        taskQueue
        taskResults
        queueMutex
        resultMutex
        taskAvailable

    # private Functions

    func isMember oAgent
        if type(oAgent) != "OBJECT" or classname(oAgent) != "agent" { return false }

        for member in aMembers {
            if member.getId() = oAgent.getId() { return true }
        }
        return false

    func isTaskInQueue oTask
        for task in aTaskQueue {
            if task.getId() = oTask.getId() { return true }
        }
        return false

    # Execution
    func executeWorkPlan
        if len(aWorkingPlan) = 0 {
            if bVerbose { logger(cName, "No work plan to execute", :warning) }
            return false
        }

        if bVerbose { logger(cName, "Starting work plan execution", :info) }
        try {
            for assignment in aWorkingPlan {
                task = assignment[:task]
                agent = assignment[:agent]
                if bVerbose {
                    logger(cName, "Executing task '" + task.getDescription() + "' with " + agent.getName(), :info)
                }

                result = agent.executeTask(task)
                if result {
                    if bVerbose {
                        logger(cName, "Task completed successfully by " + agent.getName(), :success)
                    }
               else
                    if bVerbose {
                        logger(cName, "Task execution failed by " + agent.getName(), :error)
                    }
                }
            }
       catch
            if bVerbose { logger(cName, "Error executing work plan: " + cCatchError, :error) }
            return false
        }

        if bVerbose { logger(cName, "Work plan execution completed", :success) }
        return true

    func hasRunningTasks
        for item in aWorkingPlan {
            if item[:status] = :running {
                return true
            }
        }
        return false

    func areTasksComplete
        return !hasRunningTasks()

    func getTaskResults
        return taskResults

    func evaluateResults
        nSuccessful = 0
        nFailed = 0

        for task in aCompletedTasks {
            if task.getState() = task.COMPLETED {
                nSuccessful++
           else
                nFailed++
            }
        }

        return [
            :total = len(aCompletedTasks),
            :successful = nSuccessful,
            :failed = nFailed
        ]

    func sortTasks
        # Simple bubble sort by priority
        nLen = len(aTaskQueue)
        for i = 1 to nLen {
            for j = 1 to nLen - i {
                if aTaskQueue[j].getPriority() < aTaskQueue[j+1].getPriority() {
                    temp = aTaskQueue[j]
                    aTaskQueue[j] = aTaskQueue[j+1]
                    aTaskQueue[j+1] = temp
                }
            }
        }

    func findBestAgentForTask oTask
        nHighestScore = -1
        oBestAgent = null

        for oAgent in aMembers {
            if oAgent.getStatus() = oAgent.IDLE {
                nScore = calculateAgentTaskScore(oAgent, oTask)
                if nScore > nHighestScore {
                    nHighestScore = nScore
                    oBestAgent = oAgent
                }
            }
        }
        return oBestAgent

    func calculateAgentTaskScore oAgent, oTask
        nScore = 0

        # Check agent skills
        for skill in oAgent.getSkills() {
            if substr(lower(oTask.getDescription()), lower(skill[:name])) {
                nScore += skill[:proficiency]
            }
        }

        # Consider energy level
        nScore += (oAgent.getEnergyLevel() / 20)  # Max 5 points from energy

        # Consider confidence level
        nScore += oAgent.getConfidenceLevel()

        return nScore

    func monitorExecution
        while hasRunningTasks() {
            for item in aWorkingPlan {
                if item[:status] = :running {
                    if item[:agent].getCurrentTask() = null {
                        item[:status] = :completed
                        add(aCompletedTasks, item[:task])
                    }
                }
            }
        }

        setState(REVIEWING)
        return evaluateResults()


    func executeAgentTask aTask
        if type(aTask) != "LIST" { return null }

        taskAgent = aTask[1]
        taskData = aTask[2]

        # Execute task based on type
        switch taskData[:type]
            on "process"
                return taskAgent.processTask(taskData[:content])
            on "learn"
                return taskAgent.learn(taskData[:content])
            on "collaborate"
                return taskAgent.collaborate(taskData[:content])
            other
                return null
        off
