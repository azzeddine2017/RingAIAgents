/*
    RingAI Agents Library - Reinforcement Learning Management
*/

class ReinforcementLearning
    # Constants
    EPSILON_GREEDY = "epsilon_greedy"
    UCB            = "ucb"
    THOMPSON       = "thompson"

    # Constructor
    func init cLearningStrategy  #EPSILON_GREEDY, UCB, THOMPSON
        if bVerbose { logger("RL", "Initializing reinforcement learning system", :info) }
        setStrategy(cLearningStrategy)
        if bVerbose { logger("RL", "RL system initialized successfully", :success) }
        return self

    # Basic getters and setters
    func getStrategy return cStrategy
    func getEpsilon return nEpsilon
    func getAlpha return nAlpha
    func getGamma return nGamma
    func getExplorationRate return nExplorationRate
    func getStates return aStates
    func getActions return aActions
    func getQTable return aQTable
    func getRewardHistory return aRewardHistory
    func getMetadata return aMetadata

    func getreward cAction
        if bVerbose { logger("RL", "Getting reward for action: " + cAction, :info) }
        if isAction(cAction) {
            nActionIndex = find(aActions, cAction)
            return aQTable[nStateIndex][nActionIndex]
        }
        return 0

    func setreward cAction, nReward
        if bVerbose { logger("RL", "Setting reward for action: " + cAction, :info) }
        if isAction(cAction) {
            nActionIndex = find(aActions, cAction)
            aQTable[nStateIndex][nActionIndex] = nReward
            if bVerbose { logger("RL", "Reward set successfully", :success) }
        }
        return self


    func setStrategy cValue
        if find([EPSILON_GREEDY, UCB, THOMPSON], cValue){
            cStrategy = cValue
        }
        return self

    func setEpsilon nValue
        if type(nValue) = "NUMBER" and nValue >= 0 and nValue <= 1{
            nEpsilon = nValue
        }
        return self

    func setAlpha nValue
        if type(nValue) = "NUMBER" and nValue >= 0 and nValue <= 1{
            nAlpha = nValue
        }
        return self

    func setGamma nValue
        if type(nValue) = "NUMBER" and nValue >= 0 and nValue <= 1{
            nGamma = nValue
        }
        return self

    # State and Action Management
    func addState cState
        if bVerbose { logger("RL", "Adding new state: " + cState, :info) }
        if !isState(cState){
            add(aStates, cState)
            updateQTable()
            if bVerbose { logger("RL", "State added successfully", :success) }
        else
            if bVerbose { logger("RL", "State already exists", :warning) }
        }
        return self

    func addAction cAction
        if bVerbose { logger("RL", "Adding action: " + cAction, :info) }
        if !isAction(cAction){
            add(aActions, cAction)
            updateQTable()
            if bVerbose { logger("RL", "Action added successfully", :success) }
        else
            if bVerbose { logger("RL", "Action already exists", :warning) }
        }
        return self

    # Core Learning Functions
    func chooseAction cState
        if bVerbose { logger("RL", "Choosing action for state: " + cState, :info) }
        if !isState(cState) { return null }

        nStateIndex = find(aStates, cState)

        switch cStrategy {
            On EPSILON_GREEDY
                return chooseEpsilonGreedy(nStateIndex)
            On UCB
                return chooseUCB(nStateIndex)
            On THOMPSON
                return chooseThompson(nStateIndex)
            default
                return chooseRandom()
        }

    # Learning and Updates
    func learn cState, cAction, nReward, cNextState
        if bVerbose { logger("RL", "Learning from experience: " + cState + " -> " + cAction + " -> " + nReward + " -> " + cNextState, :info) }
        if !isState(cState) or !isState(cNextState) or !isAction(cAction) {
            return false
        }

        nStateIndex = find(aStates, cState)
        nActionIndex = find(aActions, cAction)
        nNextStateIndex = find(aStates, cNextState)

        # Current Q-value
        nCurrentQ = aQTable[nStateIndex][nActionIndex]

        # Maximum Q-value for next state
        nMaxNextQ = maxQValue(nNextStateIndex)

        # Update Q-value using Q-learning formula
        nNewQ = nCurrentQ + nAlpha * (nReward + nGamma * nMaxNextQ - nCurrentQ)

        # Update Q-table
        aQTable[nStateIndex][nActionIndex] = nNewQ

        # Record reward
        add(aRewardHistory, [:state = cState,
                            :action = cAction,
                            :reward = nReward,
                            :timestamp =TimeList()[5]])

        # Update exploration rate
        updateExplorationRate()

        if bVerbose {
            logger("RL", "Learned: State= " + cState +
                ", Action= " + cAction +
                ", Reward= " + nReward +
                ", NewQ= " + nNewQ, :success)
        }

        return true

    # Serialization
    func toJSON
        if bVerbose { logger("RL", "Serializing RL model to JSON", :info) }
        return listToJSON([
            :strategy = cStrategy,
            :epsilon = nEpsilon,
            :alpha = nAlpha,
            :gamma = nGamma,
            :states = aStates,
            :actions = aActions,
            :qtable = aQTable,
            :exploration_rate = nExplorationRate,
            :metadata = aMetadata
        ], 0)

    func fromJSON cJSON
        if bVerbose { logger("RL", "Deserializing RL model from JSON", :info) }
        aData = JSON2List(cJSON)
        if type(aData) = "LIST" {
            setStrategy(aData[:strategy])
            setEpsilon(aData[:epsilon])
            setAlpha(aData[:alpha])
            setGamma(aData[:gamma])
            this.aStates = aData[:states]
            this.aActions = aData[:actions]
            this.aQTable = aData[:qtable]
            nExplorationRate = aData[:exploration_rate]
            this.aMetadata = aData[:metadata]
            if bVerbose { logger("RL", "RL model deserialized successfully", :success) }
        }
        return self


    private

    # Private Properties

        cStrategy = EPSILON_GREEDY
        nEpsilon = 0.1
        nAlpha = 0.1
        nGamma = 0.9
        aStates = []
        aActions = []
        aQTable = []
        aRewardHistory = []
        nExplorationRate = 0.1
        nMinExploration = 0.01
        nExplorationDecay = 0.995
        bVerbose = false
        aMetadata = []
        lenActions = len(aActions)

    func isState cState
        if find(aStates, cState) {
            return true
        }
        return false

    func isAction cAction
        if find(aActions, cAction) {
            return true
        }
        return false

    func updateQTable
        if bVerbose { logger("RL", "Updating Q-table", :info) }
        aQTable = []
        for state in aStates {
            aStateRow = []
            for action in aActions {
                add(aStateRow, 0)  # Initialize Q-values to 0
            }
            add(aQTable, aStateRow)
        }
        if bVerbose { logger("RL", "Q-table updated successfully", :success) }

    func chooseEpsilonGreedy nStateIndex
        if bVerbose { logger("RL", "Choosing epsilon-greedy action for state index: " + nStateIndex, :info) }
        if random(100) / 100 < nExplorationRate {
            return chooseRandom()
        }

        nMaxValue = -999999
        nBestAction = 1

        for i = 1 to lenActions {
            if aQTable[nStateIndex][i] > nMaxValue {
                nMaxValue = aQTable[nStateIndex][i]
                nBestAction = i
            }
        }
        if bVerbose { logger("RL", "Epsilon-greedy action chosen: " + aActions[nBestAction], :success) }
        return aActions[nBestAction]

    func chooseUCB nStateIndex
        if bVerbose { logger("RL", "Choosing UCB action for state index: " + nStateIndex, :info) }
        nMaxUCB = -999999
        nBestAction = 1
        nTotalVisits = sumlist(aRewardHistory)

        for i = 1 to lenActions {
            nVisits = countActionVisits(i)
            if nVisits = 0 {
                if bVerbose { logger("RL", "UCB action chosen: " + aActions[i], :success) }
                return aActions[i]
            }
            nUCB = aQTable[nStateIndex][i] +
                   2 * sqrt(log(nTotalVisits) / nVisits)
            if nUCB > nMaxUCB {
                nMaxUCB = nUCB
                nBestAction = i
            }
        }
        if bVerbose { logger("RL", "UCB action chosen: " + aActions[nBestAction], :success) }
        return aActions[nBestAction]

    func chooseThompson nStateIndex
        if bVerbose { logger("RL", "Choosing Thompson action for state index: " + nStateIndex, :info) }
        nMaxValue = -999999
        nBestAction = 1
        for i = 1 to lenActions {
            nMean = aQTable[nStateIndex][i]
            nStd = 1.0 / (countActionVisits(i) + 1)
            nSample = nMean + normalRandom() * nStd
            if nSample > nMaxValue {
                nMaxValue = nSample
                nBestAction = i
            }
        }
        if bVerbose { logger("RL", "Thompson action chosen: " + aActions[nBestAction], :success) }
        return aActions[nBestAction]

    func chooseRandom
        if bVerbose { logger("RL", "Choosing random action", :info) }
        return aActions[randomItem(lenActions)]

    func maxQValue nStateIndex
        if bVerbose { logger("RL", "Getting maximum Q-value for state index: " + nStateIndex, :info) }
        nMaxQ = -999999
        for qValue in aQTable[nStateIndex] {
            if qValue > nMaxQ {
                nMaxQ = qValue
            }
        }
        if bVerbose { logger("RL", "Maximum Q-value: " + nMaxQ, :success) }
        return nMaxQ

    func updateExplorationRate
        if bVerbose { logger("RL", "Updating exploration rate", :info) }
        nExplorationRate = max(nMinExploration,
                             nExplorationRate * nExplorationDecay)
        if bVerbose {
            logger("RL", "New exploration rate: " + nExplorationRate, :success)
        }

    func countActionVisits nActionIndex
        if bVerbose { logger("RL", "Counting visits for action index: " + nActionIndex, :info) }
        nCount = 0
        for record in aRewardHistory {
            if find(aActions, record[:action]) = nActionIndex {
                nCount++
            }
        }
        if bVerbose { logger("RL", "Action visits counted: " + nCount, :success) }
        return nCount

    func normalRandom
        if bVerbose { logger("RL", "Generating normal random number", :info) }
        # Box-Muller transform for normal distribution
        nU1 = random(1000000) / 1000000
        nU2 = random(1000000) / 1000000
        return sqrt(-2 * log(nU1)) * cos(2 * 3.14159 * nU2)

   /* func logger cMessage
        if bVerbose {
            see TimeList()[5] + " [] " + cMessage + nl
        }*/