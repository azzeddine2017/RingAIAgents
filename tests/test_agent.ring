Load "G:/RingAIAgents/src/libAgantAi.ring"

# Test Agent Class
func main
    ? "=== Testing Agent Class ==="
    
    # Test initialization and basic setters
    oAgent = new Agent("TestAgent", "Testing the agent class")
    oAgent.setRole("Tester")
    
    assert(oAgent.getName() = "TestAgent", "Testing name setter...")
    assert(oAgent.getRole() = "Tester", "Testing role setter...")
    assert(oAgent.getGoal() = "Testing the agent class", "Testing goal setter...")
    assert(oAgent.getState() = :idle, "Testing initial state...")
    
    # Test state management
    oAgent.setState(:working)
    assert(oAgent.getState() = :working, "Testing state setter...")
    
    # Test emotional and energy management
    oAgent.updateEmotionalState(8)
    assert(oAgent.getEmotionalState() = 8, "Testing emotional state...")
    
    oAgent.updateEnergyLevel(75)
    assert(oAgent.getEnergyLevel() = 75, "Testing energy level...")
    
    oAgent.updateConfidenceLevel(9)
    assert(oAgent.getConfidenceLevel() = 9, "Testing confidence level...")
    
    # Test skill management
    oAgent.addSkill("programming", 7)
    aSkills = oAgent.getSkills()
    assert(len(aSkills) = 1, "Testing skill addition...")
    assert(aSkills[1][:name] = "programming", "Testing skill name...")
    assert(aSkills[1][:proficiency] = 7, "Testing skill proficiency...")
    
    # Test personality management
    oAgent.addPersonalityTrait("analytical", 8)
    aTraits = oAgent.getPersonalityTraits()
    assert(len(aTraits) = 1, "Testing personality trait addition...")
    assert(aTraits[1][:trait] = "analytical", "Testing trait name...")
    assert(aTraits[1][:strength] = 8, "Testing trait strength...")
    
    # Test observation
    oAgent.observe("Test observation")
    assert(len(oAgent.getObservations()) = 1, "Testing observation...")
    
    # Test tool management
    oTool = new Tool("TestTool", "A test tool")
    assert(oAgent.addTool(oTool), "Testing tool addition...")
    assert(oAgent.removeTool("TestTool"), "Testing tool removal...")
    
    ? "All Agent tests passed successfully!"
