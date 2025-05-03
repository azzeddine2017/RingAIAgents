Load "G:/RingAIAgents/src/libAgantAi.ring"


# Test ReinforcementLearning Class
func main
    ? "=== Testing ReinforcementLearning Class ==="
    
    # Test initialization
    oRL = new ReinforcementLearning(:epsilon_greedy)
    assert(oRL.getStrategy() = :epsilon_greedy, "Testing strategy initialization...")
    assert(oRL.getEpsilon() = 0.1, "Testing epsilon initialization...")
    assert(oRL.getAlpha() = 0.1, "Testing alpha initialization...")
    assert(oRL.getGamma() = 0.9, "Testing gamma initialization...")
    assert(oRL.getExplorationRate() = 0.1, "Testing exploration rate initialization...")
    
    # Test parameter setters
    oRL.setEpsilon(0.2)
    assert(oRL.getEpsilon() = 0.2, "Testing epsilon setter...")
    oRL.setAlpha(0.3)
    assert(oRL.getAlpha() = 0.3, "Testing alpha setter...")
    oRL.setGamma(0.8)
    assert(oRL.getGamma() = 0.8, "Testing gamma setter...")
    
    # Test invalid parameter values
    oRL.setEpsilon(1.5)  # Should not change
    assert(oRL.getEpsilon() = 0.2, "Testing epsilon bounds...")
    oRL.setAlpha(-0.1)  # Should not change
    assert(oRL.getAlpha() = 0.3, "Testing alpha bounds...")
    oRL.setGamma(2.0)  # Should not change
    assert(oRL.getGamma() = 0.8, "Testing gamma bounds...")
    
    # Test state management
    assert(oRL.addState("state1") != null, "Testing state addition...")
    assert(oRL.addState("state2") != null, "Testing multiple state addition...")
    assert(len(oRL.getStates()) = 2, "Testing states count...")
    assert(oRL.addState("state1") != null, "Testing duplicate state addition...")
    assert(len(oRL.getStates()) = 2, "Testing states count after duplicate...")
    
    # Test action management
    assert(oRL.addAction("action1") != null, "Testing action addition...")
    assert(oRL.addAction("action2") != null, "Testing multiple action addition...")
    assert(len(oRL.getActions()) = 2, "Testing actions count...")
    assert(oRL.addAction("action1") != null, "Testing duplicate action addition...")
    assert(len(oRL.getActions()) = 2, "Testing actions count after duplicate...")
    
    # Test Q-table initialization
    aQTable = oRL.getQTable()
    assert(len(aQTable) = 2, "Testing Q-table state dimension...")
    assert(len(aQTable[1]) = 2, "Testing Q-table action dimension...")
    
    # Test action selection with different strategies
    # Epsilon-Greedy
    cAction = oRL.chooseAction("state1")
    assert(cAction != null, "Testing epsilon-greedy action selection...")
    assert(find(oRL.getActions(),cAction), "Testing selected action validity...")
    
    # UCB
    oRL.setStrategy(:ucb)
    cAction = oRL.chooseAction("state1")
    assert(cAction != null, "Testing UCB action selection...")
    assert(find(oRL.getActions(),cAction), "Testing UCB selected action validity...")
    
    # Thompson Sampling
    oRL.setStrategy(:thompson)
    cAction = oRL.chooseAction("state1")
    assert(cAction != null, "Testing Thompson sampling action selection...")
    assert(find(oRL.getActions(),cAction), "Testing Thompson selected action validity...")
    
    # Test learning process
    oRL.setStrategy(:epsilon_greedy)  # Reset to epsilon-greedy for learning tests
    assert(oRL.learn("state1", "action1", 1.0, "state2"), "Testing learning process...")
    assert(oRL.learn("state2", "action2", 0.5, "state1"), "Testing multiple learning steps...")
    assert(!oRL.learn("invalid_state", "action1", 1.0, "state2"), "Testing learning with invalid state...")
    assert(!oRL.learn("state1", "invalid_action", 1.0, "state2"), "Testing learning with invalid action...")
    
    # Test reward history
    aHistory = oRL.getRewardHistory()
    assert(type(aHistory) = "LIST", "Testing reward history type...")
    assert(len(aHistory) = 2, "Testing reward history count...")
    assert(aHistory[1][:reward] = 1.0, "Testing recorded reward value...")
    
    # Test model serialization
    cJSON = oRL.toJSON()
    assert(type(cJSON) = "STRING", "Testing JSON serialization type...")
    oNewRL = new ReinforcementLearning(:epsilon_greedy)
    oNewRL.fromJSON(cJSON)
    assert(len(oNewRL.getStates()) = len(oRL.getStates()), "Testing deserialized states...")
    assert(len(oNewRL.getActions()) = len(oRL.getActions()), "Testing deserialized actions...")
    assert(oNewRL.getStrategy() = oRL.getStrategy(), "Testing deserialized strategy...")
    
    ? "All ReinforcementLearning tests passed successfully!"
