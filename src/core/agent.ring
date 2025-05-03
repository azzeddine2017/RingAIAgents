/*
    RingAI Agents Library - Agent Management

    RingAI Agents Library - Agent Core Implementation
    Enhanced with Morgen AI capabilities
*/

class Agent
    # Constants
    IDLE = :idle
    WORKING = :working
    LEARNING = :learning
    COLLABORATING = :collaborating
    ERROR = :error
    cLanguageModel = "gemini-1.5-flash"
    # Constructor
    func init cAgentName, cAgentDescription
        # Initialize properties
        cId = generateUniqueId("agent_")
        cName = cAgentName
        cRole = ""
        cGoal = cAgentDescription
        cStatus = IDLE
        cDBPath = "G:\RingAIAgents\db\agent_" + cName + ".db"

        # Initialize objects
        oMemory = new Memory(cDBPath)
        oToolRegistry = new ToolRegistry
        oLLM = null

        # Initialize Status
        nEmotionalStatus = 5
        nEnergyLevel = 100
        nConfidenceLevel = 5

        # Initialize arrays
        aSkills = []
        aPersonalityTraits = []
        aCurrentTask = null
        aTaskHistory = []
        aCollaborators = []
        aLearningHistory = []
        aObservations = []
        aMetadata = []

        # Initialize other settings
        nMaxRetries = 3
        bVerbose = 1

        # Initialize LLM
        initializeLLM()

        if bVerbose { logger(cName, "Agent initialized with ID: " + cId, :success) }
        return self

    # Basic getters and setters
    func getId return cId
    func getName return cName
    func getRole return cRole
    func getGoal return cGoal
    func getStatus return cStatus
    func getEmotionalStatus return nEmotionalStatus
    func getEnergyLevel return nEnergyLevel
    func getConfidenceLevel return nConfidenceLevel
    func getSkills return aSkills
    func getPersonalityTraits return aPersonalityTraits
    func getCurrentTask return aCurrentTask
    func getTaskHistory return aTaskHistory
    func getCollaborators return aCollaborators
    func getLearningHistory return aLearningHistory
    func getObservations return aObservations
    func getMetadata return aMetadata
    func getLanguageModel return cLanguageModel
    func getPerformanceScore() return (nEmotionalStatus + nEnergyLevel + nConfidenceLevel) / 3
    
    func setCrew oCrew
        this.oCrew = oCrew
        return self

    func setName cValue
        cName = cValue
        return self

    func setRole cValue
        cRole = cValue
        return self

    func setGoal cValue
        cGoal = cValue
        return self

    func setSkills aValue
        if type(aValue) = "LIST" {
            aSkills = aValue
            if bVerbose { logger(cName, "Skills updated", :info) }
        }
        return self

    func setProperties aProperties
        aMetadata = aProperties
        if bVerbose { logger(cName, "Properties updated", :info) }
        return self

    func setPersonalityTraits aPersonalityTraits
        aPersonalityTraits = aPersonalityTraits
        if bVerbose { logger(cName, "PersonalityTraits updated", :info) }
        return self

    func setLanguageModel cValue
        cLanguageModel = cValue
        if bVerbose { logger(cName, "Language model updated", :info) }
        return self

    # Emotional and Energy Management
    func updateEmotionalStatus nValue
        if type(nValue) = "NUMBER" and nValue >= 1 and nValue <= 10{
            nEmotionalStatus = nValue
            if bVerbose { logger(cName, "Emotional Status updated to: " + nValue, :info) }
        }
        return self

    func updateEnergyLevel nValue
        if type(nValue) = "NUMBER" and nValue >= 0 and nValue <= 100{
            nEnergyLevel = nValue
            if bVerbose { logger(cName, "Energy level updated to: " + nValue, :info) }
        }
        return self

    func updateConfidenceLevel nValue
        if type(nValue) = "NUMBER" and nValue >= 1 and nValue <= 10{
            nConfidenceLevel = nValue
            if bVerbose { logger(cName, "Confidence level updated to: " + nValue, :info) }
        }
        return self

    # Skill Management
    func addSkill cSkill, nProficiency
        add(aSkills, [:name = cSkill, :proficiency = nProficiency])
        return self

    func improveSkill cSkill, nImprovement
        for skill in aSkills {
            if skill[:name] = cSkill {
                skill[:proficiency] = min(10, skill[:proficiency] + nImprovement)
                if bVerbose {
                    logger(cName, "Improved skill: " + cSkill + " to level " + skill[:proficiency], :info)
                }
                return true
            }
        }
        return false

    # Personality Management
    func addPersonalityTrait cTrait, nStrength
        add(aPersonalityTraits, [:trait = cTrait, :strength = nStrength])
        return self

    # Task Management
    func assignTask oTask
        if type(oTask) = "OBJECT" and classname(oTask) = "task"{
            aCurrentTask = oTask
            setStatus(WORKING)
            if bVerbose { logger(cName, "Assigned new task: " + oTask.getDescription(), :info) }
            return true
        }
        return false

    func completeTask
        if aCurrentTask != null {
            aCurrentTask.setStatus(aCurrentTask.COMPLETED)
            add(aTaskHistory, aCurrentTask)
            aCurrentTask = null
            setStatus(IDLE)
            if bVerbose { logger(cName, "Task completed successfully", :info) }
            return true
        }
        return false

    # Collaboration
    func addCollaborator oAgent
        if type(oAgent) = "OBJECT" and classname(oAgent) = "agent"{
            add(aCollaborators, oAgent)
            if bVerbose {
                logger(cName, "Added collaborator: " + oAgent.getName(), :info)
            }
            return true
        }
        return false

    func removeCollaborator cAgentId
        for i = 1 to len(aCollaborators) {
            if aCollaborators[i].getId() = cAgentId {
                del(aCollaborators, i)
                if bVerbose { logger(cName, "Removed collaborator with ID: " + cAgentId, :info) }
                return true
            }
        }
        return false

    # Learning and Observation
    func learn cTopic, cContent
        if bVerbose { logger(cName, "Learning new information about: " + cTopic, :info) }
        try {
            oMemory.store([
                :topic = cTopic,
                :content = cContent,
                :timestamp = timelist()[5]
            ])
            if bVerbose { logger(cName, "Successfully stored new knowledge", :success) }
        catch
            if bVerbose { logger(cName, "Failed to store knowledge: " + cCatchError, :error) }
        }
        return self

    func observe cObservation
        add(aObservations, [
            :content = cObservation,
            :timestamp = timelist()[5]
        ])
        if bVerbose { logger(cName, "New observation recorded", :info) }
        return self

    # Tool Management
    func addTool oTool
        return oToolRegistry.registerTool(oTool)

    func removeTool cToolName
        return oToolRegistry.unregisterTool(cToolName)

    func useTool cToolName, aParams
        oTool = oToolRegistry.getTool(cToolName)
        if oTool = null {
            if bVerbose { logger(cName, "Tool not found: " + cToolName, :error) }
            return [:error = "Tool not found"]
        }
        if bVerbose { logger(cName, "Using tool: " + cToolName, :info) }
        try {
            result = oTool.execute(aParams)
            if type(result) = "MAP" and result[:error] != NULL
                if bVerbose { logger(cName, "Tool execution failed: " + result[:error], :error) }
            else
                if bVerbose { logger(cName, "Tool executed successfully", :success) }
            ok
            return result
       catch
            if bVerbose { logger(cName, "Tool execution error: " + cCatchError, :error) }
            return [:error = cCatchError]
        }
    
    
    # Memory and Learning Management
    func setMemory oMemorySystem
        if type(oMemorySystem) = "OBJECT" {
            oMemory = oMemorySystem
            if bVerbose { logger(cName, "Memory system updated", :info) }
            return true
        }
        return false

    func setReinforcementLearning oLearningSystem
        if type(oLearningSystem) = "OBJECT" {
            oReinforcementSystem = oLearningSystem
            if bVerbose { logger(cName, "Reinforcement learning system updated", :info) }
            return true
        }
        return false

    func getMemory
        return oMemory

    func getReinforcementLearning
        return oReinforcementSystem

    # Status Management
    func setStatus cNewStatus
        if find([IDLE, WORKING, LEARNING, COLLABORATING, ERROR], cNewStatus){
            cStatus = cNewStatus
            if bVerbose { logger(cName, "Status changed to: " + cNewStatus, :info) }
        }
        return self

    # Task Processing
    func processTask oTask
        if nEnergyLevel < 20 {
            return [:error = "Insufficient energy to process task"]
        }
        setStatus(WORKING)
        updateEnergyLevel(nEnergyLevel - 10)  # Task processing consumes energy
        try {
            # Prepare context for the task
            cContext = prepareContext()

            # Get LLM response
            oResponse = oLLM.getResponse(cContext + nl + oTask.getDescription(), [])

            # Parse and execute LLM response
            aActions = parseLLMResponse(oResponse)

            # Execute actions
            aResults = []
            for action in aActions {
                add(aResults, executeAction(action))
            }
            # Update task progress
            oTask.updateProgress(100)
            completeTask()

            return [:success = true, :results = aResults]
       catch
            setStatus(ERROR)
            return [:error = "Task processing failed: " + cCatchError]
        }

    # Message Processing
    func receiveMessage cMessage
        if bVerbose { logger(cName, "Received message: " + cMessage, :info) }
        try {
            return processMessage(cMessage)
       catch
            setStatus(ERROR)
            return [:error = "Message processing failed: " + cCatchError]
        }

    func processMessage cMessage
        # Process the message using LLM
        try {
            # Prepare context for the message
            cContext = prepareContext()

            # Get LLM response
            oResponse = oLLM.getResponse(cContext + nl + "Message: " + cMessage, [])

            # Parse and execute LLM response
            aActions = parseLLMResponse(oResponse)

            # Execute actions
            aResults = []
            for action in aActions {
                add(aResults, executeAction(action))
            }

            return [:success = true, :results = aResults]
       catch
            return [:error = "Message processing failed: " + cCatchError]
        }

    # Serialization
    func toJSON
        return listToJSON([
            :id = cId,
            :name = cName,
            :role = cRole,
            :goal = cGoal,
            :Status = cStatus,
            :emotionalStatus = nEmotionalStatus,
            :energyLevel = nEnergyLevel,
            :confidenceLevel = nConfidenceLevel,
            :skills = aSkills,
            :personalityTraits = aPersonalityTraits,
            :currentTask = aCurrentTask,
            :taskHistory = aTaskHistory,
            :collaborators = aCollaborators,
            :learningHistory = aLearningHistory,
            :observations = aObservations,
            :metadata = aMetadata,
            :languageModel = cLanguageModel
        ], 0)

    func fromJSON cJSON
        aData = json2list(cJSON)
        if type(aData) = "LIST" {
            cId = aData[:id]
            cName = aData[:name]
            cRole = aData[:role]
            cGoal = aData[:goal]
            cStatus = aData[:Status]
            nEmotionalStatus = aData[:emotionalStatus]
            nEnergyLevel = aData[:energyLevel]
            nConfidenceLevel = aData[:confidenceLevel]
            aSkills = aData[:skills]
            aPersonalityTraits = aData[:personalityTraits]
            aCurrentTask = aData[:currentTask]
            aTaskHistory = aData[:taskHistory]
            aCollaborators = aData[:collaborators]
            aLearningHistory = aData[:learningHistory]
            aObservations = aData[:observations]
            aMetadata = aData[:metadata]
            cLanguageModel = aData[:languageModel]
        }
        return self

    func executeTask
        if aCurrentTask = null {
            if bVerbose { logger(cName, "No task assigned to execute", :warning) }
            return false
        }

        try {
            # Split task into subtasks if possible
            aSubtasks = splitTask( aCurrentTask )

            if len(aSubtasks) > 1 {
                # Process subtasks in parallel using thread pool
                for subtask in aSubtasks {
                    oCrew.addAgentTask(self, [:type = "process", :content = subtask])
                }

                # Wait for all subtasks to complete
                while not oCrew.areTasksComplete() {
                    sleep(100)
                }

                # Combine results
                aResults = oCrew.getTaskResults()
                finalResult = combineResults(aResults)
            else
                # Process single task normally
                finalResult = processTask(aCurrentTask)
            }

            # Update task history
            add(aTaskHistory, [aCurrentTask, finalResult])

            if bVerbose { logger(cName, "Task completed successfully", :success) }
            return true

        catch
            if bVerbose { logger(cName, "Error executing task: " + cCatchError, :error) }
            return false
        }

    private

    # private Properties
        cId = ""
        cName = ""          # Agent name
        cRole = ""          # Agent role/description
        cGoal = ""          # Agent's primary goal
        cStatus = IDLE

        oMemory = null      # Memory instance
        oToolRegistry = null
        oLLM = null        # Language model instance
        nEmotionalStatus = 5  # 1-10 scale
        nEnergyLevel = 100   # 0-100 scale
        nConfidenceLevel = 5 # 1-10 scale
        aSkills = []
        aPersonalityTraits = []
        aCurrentTask = null
        aTaskHistory = []   # History of completed tasks
        aCollaborators = []
        aLearningHistory = []
        aObservations = []
        nMaxRetries = 3     # Maximum number of task retries
        bVerbose = false    # Enable verbose mode
        aMetadata = []
        oCrew = null  # Crew instance for parallel task processing
        oReinforcementSystem = null
        oDelegate = null
       

    # private Methods

    func prepareContext
        cContext = "Agent: " + cName + nl +
                  "Role: " + cRole + nl +
                  "Goal: " + cGoal + nl +
                  "Current Status: " + cStatus + nl +
                  "Available Tools: " + list2str(oToolRegistry.getAllTools()) + nl +
                  "Recent Memories: " + list2str(oMemory.retrieve("")) + nl
        return cContext

    func executeAction oAction
        if !isList(oAction) { return [:error = "Invalid action format"] }

        try {
            return useTool(oAction[:tool], oAction[:params])
       catch
            return [:error = "Action execution failed: " + cCatchError]
        }

    # LLM initialization and configuration
    func initializeLLM
        if bVerbose { logger(cName, "Initializing LLM with model: " + cLanguageModel, :info) }
        try {
            oLLM = new LLM(cLanguageModel)
            oLLM.setApiKey(sysget("GEMINI_API_KEY"))
            if bVerbose { logger(cName, "LLM initialized successfully", :success) }
       catch
            if bVerbose { logger(cName, "Failed to initialize LLM: " + cCatchError, :error) }
        }
        return self

    func shouldDelegate oTask
        if oDelegate = null return false ok
        return oTask.complexity() > 0.7  # Delegate complex tasks

    func delegateTask oTask
        if oDelegate {
            return oDelegate.execute(oTask.description)
        }
        return false

    # Helper functions for LLM integration
    func parseLLMResponse oResponse
        try {
            # Convert LLM response to list of tools to use
            # Format: [[:name = "toolName", :params = "params"], ...]
            aResult = []

            # Split response into lines
            aLines = str2list(oResponse)
            for cLine in aLines {
                if substr(cLine, "- ") {
                    cLine = substr(cLine, 3)  # Remove "- " prefix
                    aLineParts = split(cLine, ":")
                    if len(aLineParts) >= 2 {
                        add(aResult, [
                            :name = trim(aLineParts[1]),
                            :params = trim(aLineParts[2])
                        ])
                    }
                }
            }
            return aResult
       catch
            return []
        }

    func findTool cToolName
        for tool in aTools {
            if tool.name = cToolName {
                return tool
            }
        }
        return NULL




    func splitTask task
        # Analyze task and split into subtasks if possible
        aSubtasks = []

        if type(task) = "LIST" and len(task) > 1 {
            # Split list tasks
            for item in task {
                add(aSubtasks, item)
            }
        else
            # Can't split, return as single task
            add(aSubtasks, task)
        }

        return aSubtasks

    func combineResults aResults
        if len(aResults) = 0 { return null }

        combinedResult = ""
        for result in aResults {
            if type(result[2]) = "STRING" {
                combinedResult += result[2] + nl
            }
        }

        return combinedResult
