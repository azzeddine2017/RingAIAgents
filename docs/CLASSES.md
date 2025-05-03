# Class Documentation - RingAI Agents

## Agent Class

### Properties
- `cId`: Unique agent identifier
- `cName`: Agent name
- `cRole`: Agent role
- `cGoal`: Agent goal
- `cState`: Agent state (IDLE, WORKING, LEARNING, COLLABORATING, ERROR)
- `cLanguageModel`: Language model used 

### Objects
- `oMemory`: Agent memory
- `oToolRegistry`: Tool registry
- `oLLM`: Language model
- `oCrew`: Team


### States
- `nEmotionalState`: Emotional state (1-10)
- `nEnergyLevel`: Energy level (0-100)
- `nConfidenceLevel`: Confidence level (1-10)

### Arrays
- `aSkills`: Skills
- `aPersonalityTraits`: Personality traits
- `aCurrentTask`: Current task
- `aTaskHistory`: Task history
- `aCollaborators`: Collaborators
- `aLearningHistory`: Learning history
- `aObservations`: Observations
- `aMetadata`: Metadata

### Main Functions
- `init(cAgentName, cAgentDescription)`: Initialize agent
- `initializeMorgen()`: Initialize MorGen capabilities
- `processTask(oTask)`: Process tasks with MorGen
- `makeDecision(xData)`: Make decisions
- `learn(cTopic, cContent)`: Learn
- `executeTask()`: Execute tasks

## Crew Class

### Properties
- `cId`: Unique crew identifier
- `cName`: Crew name
- `cObjective`: Crew objective
- `cState`: Crew state (IDLE, WORKING, PLANNING, REVIEWING, ERROR)
- `POOL_SIZE`: Work pool size (4 threads)

### Arrays
- `aMembers`: Crew members
- `aTaskQueue`: Task queue
- `aCompletedTasks`: Completed tasks
- `aWorkingPlan`: Work plan
- `aConflicts`: Conflicts
- `aMessages`: Messages
- `aPerformance`: Performance
- `aMetadata`: Metadata

### Objects
- `oLeader`: Team leader
- `oThreads`: Thread manager
- `queueMutex`: Queue mutex
- `resultMutex`: Result mutex
- `taskAvailable`: Task availability condition

### Main Functions
- `init(cCrewName, oLeaderAgent)`: Initialize crew
- `addMember(oAgent)`: Add member
- `assignTask(oTask, oAgent)`: Assign task
- `recordPerformance(oAgent, cMetric, nValue)`: Record performance
- `isMember(oAgent)`: Check membership

## Task Class

### States
- `PENDING`: Pending
- `RUNNING`: Running
- `COMPLETED`: Completed
- `FAILED`: Failed
- `CANCELLED`: Cancelled

### Properties
- `cId`: Unique task identifier
- `cDescription`: Task description
- `dStartTime`: Start time
- `cState`: Task state
- `nPriority`: Priority (1-10)
- `cContext`: Context
- `nProgress`: Progress percentage (0-100)
- `nMaxRetries`: Maximum retries
- `nRetryCount`: Current retry count
- `cError`: Error message
- `dEndTime`: End time

### Arrays
- `aSubtasks`: Subtasks
- `aArtifacts`: Outputs
- `aMetadata`: Metadata

### Main Functions
- `init(cTaskDescription)`: Initialize task
- `setState(cNewState)`: Change task state
- `setPriority(nValue)`: Set priority
- `setContext(cValue)`: Set context
- `addSubtask(oSubtask)`: Add subtask
- `updateProgress(nValue)`: Update progress percentage
- `updateParentProgress()`: Update parent task progress

## LLM Class

### Supported Models
- `GEMINI`: Gemini 1.5 Flash model
- `GPT4`: GPT-4 model
- `CLAUDE`: Claude model
- `LLAMA`: Llama model

### Properties
- `cModel`: Model in use
- `nTemperature`: Randomness degree (0-1)
- `nMaxTokens`: Maximum tokens
- `nTopP`: Top P probability
- `nPresencePenalty`: Presence penalty
- `nFrequencyPenalty`: Frequency penalty
- `cSystemPrompt`: System prompt
- `cApiKey`: API key

### Main Functions
- `init(cModelName)`: Initialize model
- `setModel(cValue)`: Set model
- `getResponse(cPrompt, aParams)`: Get response
- `addToHistory(cRole, cContent)`: Add to conversation
- `clearHistory()`: Clear conversation

## Memory Class

### Memory Types
- `SHORT_TERM`: Short-term
- `LONG_TERM`: Long-term
- `EPISODIC`: Episodic
- `SEMANTIC`: Semantic

### Main Functions
- `init()`: Initialize memory system
- `store(cContent, cType, nPriority, aTags, aMetadata)`: Store memory
- `retrieve(cQuery, cType, nLimit)`: Retrieve memories
- `searchByTags(aTags, nLimit)`: Search by tags
- `updatePriority(nId, nNewPriority)`: Update priority
- `clear()`: Clear memory

## PerformanceMonitor Class

### Properties
- `bIsRunning`: Running state
- `nStartTime`: Start time

### Main Functions
- `init()`: Initialize monitoring system
- `registerAgent/LLM/RL/Crew/Tools/Tasks`: Register components
- `startMonitoring()`: Start monitoring
- `stopMonitoring()`: Stop monitoring
- `recordMetric(cComponent, cMetricName, nValue, aMetadata)`: Record metric
- `recordEvent(cComponent, cEventType, cDescription, aMetadata)`: Record event

## ReinforcementLearning Class

### Learning Strategies
- `EPSILON_GREEDY`: Epsilon greedy
- `UCB`: Upper Confidence Bound
- `THOMPSON`: Thompson sampling

### Properties
- `cStrategy`: Strategy in use
- `nEpsilon`: Exploration factor
- `nAlpha`: Learning rate
- `nGamma`: Discount factor

### Main Functions
- `init(cLearningStrategy)`: Initialize learning system
- `addState(cState)`: Add state
- `addAction(cAction)`: Add action
- `chooseAction(cState)`: Choose action
- `learn(cState, cAction, nReward, cNextState)`: Learn from experience

## Tool Class

### Properties
- `cName`: Tool name
- `cDescription`: Tool description
- `cVersion`: Version
- `bEnabled`: Enabled state

### Main Functions
- `init(cToolName, cToolDescription)`: Initialize tool
- `addParameter(cName, cType, bRequired, cDefaultValue)`: Add parameter
- `validateParameters(aInputParams)`: Validate parameters
- `addPermission(cPermission)`: Add permission
- `execute(aParams)`: Execute tool

## ToolRegistry Class

### Main Functions
- `registerTool(oTool)`: Register tool
- `unregisterTool(cToolName)`: Unregister tool
- `getTool(cToolName)`: Get tool
- `getToolsByCategory(cCategory)`: Get tools by category
- `addCategory(cName, cDescription)`: Add category

## Main Updates

1. Added MorGen support in `Agent` class:
   - Initialize MorGen capabilities
   - Analyze context and emotions
   - Process natural language
   - Manage knowledge
   - Improve results

2. Improved task management in `Crew` class:
   - Added concurrent processing system
   - Improved task queue management
   - Added synchronization mechanisms
   - Improved performance tracking

3. Improved task tracking in `Task` class:
   - Added new task states
   - Improved progress tracking
   - Supported subtasks
   - Improved error handling

4. Added new classes:
   - `LLM`: Support for multiple language models
   - `Memory`: Advanced memory system
   - `PerformanceMonitor`: Performance monitoring
   - `ReinforcementLearning`: Reinforcement learning
   - `Tool` and `ToolRegistry`: Tool management