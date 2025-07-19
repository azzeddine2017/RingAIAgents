Load "../src/libAgentAi.ring"


# Test Crew Class
func main
    ? "=== Testing Crew Class ==="
    
    # Create leader agent
    oLeader = new Agent("Leader Agent", "Test leader agent")
    oLeader.setRole("manager")
    oLeader.setSkills([
        [:name = "leadership", :proficiency = 5],
        [:name = "management", :proficiency = 4]
    ])
    
    # Test initialization
    oCrew = new Crew("oCrew", "TestCrew", oLeader)
    assert(oCrew.getName() = "TestCrew", "Testing initialization...")
    assert(oCrew.getLeader().getName() = oLeader.getName(), "Testing leader initialization...")
    assert(len(oCrew.getMembers()) = 1, "Testing members initialization...")  # Leader is also a member
    assert(oCrew.getState() = oCrew.IDLE, "Testing initial state...")
  
    # Test member management
    oAgent1 = new Agent("Agent1", "Test agent 1")
    oAgent1.setRole("developer")
    oAgent1.setSkills([
        [:name = "coding", :proficiency = 4],
        [:name = "testing", :proficiency = 3]
    ])
    
    oAgent2 = new Agent("Agent2", "Test agent 2")
    oAgent2.setRole("designer")
    oAgent2.setSkills([
        [:name = "design", :proficiency = 5],
        [:name = "documentation", :proficiency = 4]
    ])
    
    assert(oCrew.addMember(oAgent1), "Testing member addition...")
    assert(len(oCrew.getMembers()) = 2, "Testing members count...")
    
    assert(oCrew.addMember(oAgent2), "Testing member addition...")
    assert(len(oCrew.getMembers()) = 3, "Testing members count...")
    
    assert(oCrew.removeMember(oAgent1), "Testing member removal...")
    assert(len(oCrew.getMembers()) = 2, "Testing members count...")
    
    # Test role assignment
    assert(oCrew.assignRole(oAgent2, "developer"), "Testing role assignment...")
    assert(oCrew.getMemberRole(oAgent2) = "developer", "Testing role retrieval...")
    
    # Test task management
    oTask1 = new Task("Design new feature")
    oTask1.setPriority(3)
    assert(oCrew.addTask(oTask1), "Testing task addition...")
    assert(len(oCrew.getTaskQueue()) = 1, "Testing task queue...")
    
    oTask2 = new Task("Document API")
    oTask2.setPriority(2)
    assert(oCrew.addTask(oTask2), "Testing task addition...")
    assert(len(oCrew.getTaskQueue()) = 2, "Testing task queue...")
     
    # Test work plan creation
    aWorkPlan = oCrew.createWorkPlan()
    assert(len(aWorkPlan) > 0, "Testing work plan creation...")
    
    # Test task assignment
    assert(oCrew.assignTask(oTask2, oAgent2), "Testing task assignment...")
    assert(oAgent2.getCurrentTask().getid() = oTask2.getid(), "Testing current task...")
    
    # Test communication
    assert(oCrew.broadcast("Team meeting at 2 PM"), "Testing message broadcast...")
    assert(len(oCrew.getMessages()) = 1, "Testing messages count...")
    
    # Test performance tracking
    assert(oCrew.recordPerformance(oAgent2, "task_completion", 0.9), "Testing performance recording...")
    assert(oCrew.getMemberPerformance(oAgent2, "task_completion") = 0.9, "Testing performance retrieval...")
    
    # Test conflict management
    assert(oCrew.reportConflict("Resource allocation conflict", oAgent2, oLeader), "Testing conflict reporting...")
    assert(len(oCrew.getConflicts()) = 1, "Testing conflicts count...")
    
    # Test state management
    assert(oCrew.setState(oCrew.WORKING).getState() = oCrew.WORKING, "Testing state change...")
    
    # Test serialization
    cJSON = oCrew.toJSON()
    assert(type(cJSON) = "STRING", "Testing JSON serialization...")
    
    oNewCrew = new Crew("oNewCrew","NewCrew", oLeader)
    oNewCrew.fromJSON(cJSON)
    assert(oNewCrew.getName() = oCrew.getName(), "Testing JSON deserialization...")
    
    ? "All Crew tests passed successfully!"
