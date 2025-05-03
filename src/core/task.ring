/*
    RingAI Agents Library - Task Management
*/




class Task
    # Task States
    PENDING     = :pending
    RUNNING     = :running
    COMPLETED   = :completed
    FAILED = :failed
    CANCELLED = :cancelled

    # Properties
    bVerbose = false

    func init cTaskDescription
        if bVerbose { logger("Task", "Initializing task: " + cTaskDescription, :info) }
        try {
            cId = generateUniqueId("task")
            cDescription = cTaskDescription
            dStartTime = TimeList()[17]
            cState = PENDING
            nPriority = 5
            cContext = ""
            aSubtasks = []
            nProgress = 0
            nMaxRetries = 3
            nRetryCount = 0
            cError = ""
            oParentTask = null
            aArtifacts = []
            dEndTime = ""
            aMetadata = []
            cTitle = ""

            if bVerbose { logger("Task", "Task initialized successfully", :success) }
        catch
            if bVerbose { logger("Task", "Failed to initialize task: " + cCatchError, :error) }
        }
        return self

    func getId return cId
    func getDescription return cDescription
    func getState return cState
    func getPriority return nPriority
    func getProgress return nProgress
    func getError return cError
    func getStartTime return dStartTime
    func getEndTime return dEndTime
    func getMetadata return aMetadata
    func getTitle return cTitle
    func getAssignedTo return oAssignedTo
    func getcontext return cContext
    func getstatus return cState
    func getduetime return dEndTime

    func setId cValue
        if bVerbose { logger("Task", "Setting task ID: " + cValue, :info) }
        try {
            cId = cValue

            if bVerbose { logger("Task", "Task ID set successfully", :success) }
        catch
            if bVerbose { logger("Task", "Failed to set task ID: " + cCatchError, :error) }
        }
        return self


    func setTitle cValue
        if bVerbose { logger("Task", "Setting task title: " + cValue, :info) }
        try {
            cTitle = cValue

            if bVerbose { logger("Task", "Task title set successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to set task title: " + cCatchError, :error) }
        }
        return self

    func setState cNewState
        if bVerbose { logger("Task", "Setting task state: " + cNewState, :info) }
        try {
            if find([PENDING, RUNNING, COMPLETED, FAILED, CANCELLED], cNewState) {
                cState = cNewState
                if cState = COMPLETED or cState = FAILED{
                    dEndTime = TimeList()[17]
                }
                if bVerbose { logger("Task", "Task state set successfully", :success) }
            else
                if bVerbose { logger("Task", "Invalid task state", :warning) }
            }
       catch
            if bVerbose { logger("Task", "Failed to set task state: " + cCatchError, :error) }
        }
        return self

    func setStatus cNewState
        # Alias for setState for compatibility
        return setState(cNewState)

    func setPriority nValue
        if bVerbose { logger("Task", "Setting task priority: " + nValue, :info) }
        try {
            if type(nValue) = :NUMBER and nValue >= 1 and nValue <= 10 {
                nPriority = nValue

                if bVerbose { logger("Task", "Task priority set successfully", :success) }
           else
                if bVerbose { logger("Task", "Invalid task priority", :warning) }
            }
       catch
            if bVerbose { logger("Task", "Failed to set task priority: " + cCatchError, :error) }
        }
        return self

    func setContext cValue
        if bVerbose { logger("Task", "Setting task context: " + cValue, :info) }
        try {
            cContext = cValue

            if bVerbose { logger("Task", "Task context set successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to set task context: " + cCatchError, :error) }
        }
        return self

    func setStartTime cValue
        if bVerbose { logger("Task", "Setting task start time: " + cValue, :info) }
        try {
            dStartTime = cValue

            if bVerbose { logger("Task", "Task start time set successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to set task start time: " + cCatchError, :error) }
        }
        return self

    func setDueTime cValue
        if bVerbose { logger("Task", "Setting task due time: " + cValue, :info) }
        try {
            dEndTime = cValue

            if bVerbose { logger("Task", "Task due time set successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to set task due time: " + cCatchError, :error) }
        }
        return self

    func addSubtask oSubtask
        if bVerbose { logger("Task", "Adding subtask: " + oSubtask.getDescription(), :info) }
        try {
            if type(oSubtask) = :OBJECT and classname(oSubtask) = :Task{
                oSubtask.setParentTask(self)
                add(aSubtasks, oSubtask)

                if bVerbose { logger("Task", "Subtask added successfully", :success) }
           else
                if bVerbose { logger("Task", "Invalid subtask", :warning) }
            }
       catch
            if bVerbose { logger("Task", "Failed to add subtask: " + cCatchError, :error) }
        }
        return self

    func getSubtasks
        if bVerbose { logger("Task", "Getting subtasks", :info) }
        try {
            return aSubtasks

            if bVerbose { logger("Task", "Subtasks retrieved successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to retrieve subtasks: " + cCatchError, :error) }
        }

    func setParentTask oTask
        if bVerbose { logger("Task", "Setting parent task: " + oTask.getDescription(), :info) }
        try {
            oParentTask = oTask

            if bVerbose { logger("Task", "Parent task set successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to set parent task: " + cCatchError, :error) }
        }
        return self

    func getParentTask
        if bVerbose { logger("Task", "Getting parent task", :info) }
        try {
            return oParentTask

            if bVerbose { logger("Task", "Parent task retrieved successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to retrieve parent task: " + cCatchError, :error) }
        }

    func updateProgress nValue
        if bVerbose { logger("Task", "Updating task progress: " + nValue, :info) }
        try {
            if type(nValue) = :NUMBER and nValue >= 0 and nValue <= 100{
                nProgress = nValue
                if nProgress = 100{
                    setState(COMPLETED)
                }
                updateParentProgress()

                if bVerbose { logger("Task", "Task progress updated successfully", :success) }
           else
                if bVerbose { logger("Task", "Invalid task progress", :warning) }
            }
       catch
            if bVerbose { logger("Task", "Failed to update task progress: " + cCatchError, :error) }
        }
        return self

    func setProgress nValue
        # Alias for updateProgress for compatibility
        return updateProgress(nValue)

    func addArtifact cName, cValue
        if bVerbose { logger("Task", "Adding artifact: " + cName, :info) }
        try {
            add(aArtifacts, [:name = cName, :value = cValue])

            if bVerbose { logger("Task", "Artifact added successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to add artifact: " + cCatchError, :error) }
        }
        return self

    func getArtifacts
        if bVerbose { logger("Task", "Getting artifacts", :info) }
        try {
            return aArtifacts

            if bVerbose { logger("Task", "Artifacts retrieved successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to retrieve artifacts: " + cCatchError, :error) }
        }

    func addMetadata cKey, cValue
        if bVerbose { logger("Task", "Adding metadata: " + cKey, :info) }
        try {
            add(aMetadata, [:key = cKey, :value = cValue])

            if bVerbose { logger("Task", "Metadata added successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to add metadata: " + cCatchError, :error) }
        }
        return self

    func assignTo oAgent
        if bVerbose { logger("Task", "Assigning task to agent: " + oAgent.getName(), :info) }
        try {
            oAssignedTo = oAgent

            if bVerbose { logger("Task", "Task assigned successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to assign task: " + cCatchError, :error) }
        }
        return self

    func retry
        if bVerbose { logger("Task", "Retrying task", :info) }
        try {
            if nRetryCount < nMaxRetries and cState = FAILED {
                nRetryCount++
                setState(PENDING)

                if bVerbose { logger("Task", "Task retried successfully", :success) }
                return true
           else
                if bVerbose { logger("Task", "Task retry failed", :warning) }
                return false
            }
       catch
            if bVerbose { logger("Task", "Failed to retry task: " + cCatchError, :error) }
            return false
        }

    func cancel
        if bVerbose { logger("Task", "Cancelling task", :info) }
        try {
            setState(CANCELLED)
            for oSubtask in aSubtasks{
                oSubtask.cancel()
            }
            if bVerbose { logger("Task", "Task cancelled successfully", :success) }
            return self
       catch
            if bVerbose { logger("Task", "Failed to cancel task: " + cCatchError, :error) }
        }

    # Serialization
    func toJSON
        return listToJSON([
            :id = cId,
            :title = cTitle,
            :description = cDescription,
            :startTime = dStartTime,
            :state = cState,
            :priority = nPriority,
            :context = cContext,
            :subtasks = aSubtasks,
            :progress = nProgress,
            :maxRetries = nMaxRetries,
            :retryCount = nRetryCount,
            :error = cError,
            :parentTask = oParentTask,
            :artifacts = aArtifacts,
            :endTime = dEndTime,
            :metadata = aMetadata,
            :assignedTo = oAssignedTo
        ], 0)

    func fromJSON cJSON
        aData = json2list(cJSON)
        if type(aData) = "LIST" {
            cId = aData[:id]
            cTitle = aData[:title]
            cDescription = aData[:description]
            dStartTime = aData[:startTime]
            cState = aData[:state]
            nPriority = aData[:priority]
            cContext = aData[:context]
            aSubtasks = aData[:subtasks]
            nProgress = aData[:progress]
            nMaxRetries = aData[:maxRetries]
            nRetryCount = aData[:retryCount]
            cError = aData[:error]
            oParentTask = aData[:parentTask]
            aArtifacts = aData[:artifacts]
            dEndTime = aData[:endTime]
            aMetadata = aData[:metadata]
            oAssignedTo = aData[:assignedTo]
        }
        return self

    private

    # Private Properties

        cId
        cDescription
        cState
        nPriority
        cContext
        aSubtasks
        nProgress
        nMaxRetries
        nRetryCount
        cError
        oParentTask
        aArtifacts
        dStartTime
        dEndTime
        aMetadata
        cTitle
        oAssignedTo

    # Private Functions

    func updateParentProgress
        if bVerbose { logger("Task", "Updating parent task progress", :info) }
        try {
            if oParentTask != null{
                nTotalProgress = 0
                for oSubtask in oParentTask.getSubtasks(){
                    nTotalProgress += oSubtask.getProgress()
                }
                oParentTask.updateProgress(nTotalProgress / len(oParentTask.getSubtasks()))
            }
            if bVerbose { logger("Task", "Parent task progress updated successfully", :success) }
       catch
            if bVerbose { logger("Task", "Failed to update parent task progress: " + cCatchError, :error) }
        }
