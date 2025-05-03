/*
    RingAI Agents - Software Development Team Example
    This example demonstrates a complete software development team using AI agents
    Author:  Azzeddine Remmal
    Date: 2025
*/

load "../../core/agent.ring"
load "../../core/crew.ring"
load "../../core/llm.ring"
load "RingThreadPro.ring"

# Initialize Thread Manager for parallel processing
oThreadManager = new ThreadManager(8)  # 8 worker threads
oThreadManager.enableDebug()

# Example Usage
func main
    # Create software team
    oTeam = new SoftwareTeam("E-Commerce Platform")
    
    # Define project requirements
    aRequirements = [
        "Create a modern e-commerce platform",
        "Implement user authentication",
        "Product catalog with search",
        "Shopping cart functionality",
        "Payment integration",
        "Responsive design"
    ]
    
    # Start the project
    oTeam.startProject(aRequirements)
    
    # Start progress monitoring in a separate thread
    oThreadManager.createThread(1, "oTeam.monitorProgress()")
    
    # Simulate some team activities
    oTeam.submitDesign("Homepage wireframe with modern UI elements")
    oTeam.submitCode(oTeam.oDevelopers[1], "User authentication API implementation")
    oTeam.reportBug("Frontend: Shopping cart not updating properly")
    
    # Wait for some time to see the progress
    for i = 1 to 10 {
        sleep(1000)
    }

class SoftwareTeam 
    # Team members
    oProjectManager
    oDevelopers
    oQATester
    oUIDesigner
    oCrew
    
    # Project state
    cProjectName
    aRequirements
    aCodebase
    aTestCases
    aUIDesigns
    
    # Synchronization objects
    oMutex
    oCondition
    
    func init cName 
        cProjectName = cName
        aRequirements = []
        aCodebase = []
        aTestCases = []
        aUIDesigns = []
        
        # Initialize synchronization
        oMutex = oThreadManager.createMutex(1)
        oCondition = oThreadManager.createCondition()
        
        # Create team members
        createTeamMembers()
        
        # Initialize crew
        oCrew = new Crew("Software Team Crew", oProjectManager)
        oCrew.addMember(oDevelopers[1])
        oCrew.addMember(oDevelopers[2])
        oCrew.addMember(oQATester)
        oCrew.addMember(oUIDesigner)
        
        return self
        
    func createTeamMembers
        # Create Project Manager
        oProjectManager = new Agent("Project Manager", "Manage software development project and team coordination")
        oProjectManager.addSkill("project_management")
        oProjectManager.addSkill("team_coordination")
        oProjectManager.addSkill("agile_methodologies")
        
        # Create Developers
        oDevelopers = []
        oDev1 = new Agent("Backend Developer", "Develop server-side components and APIs")
        oDev1.addSkill("backend_development")
        oDev1.addSkill("database_design")
        oDev1.addSkill("api_development")
        add(oDevelopers, oDev1)
        
        oDev2 = new Agent("Frontend Developer", "Develop user interface components")
        oDev2.addSkill("frontend_development")
        oDev2.addSkill("responsive_design")
        oDev2.addSkill("javascript")
        add(oDevelopers, oDev2)
        
        # Create QA Tester
        oQATester = new Agent("QA Engineer", "Ensure software quality through testing")
        oQATester.addSkill("software_testing")
        oQATester.addSkill("test_automation")
        oQATester.addSkill("bug_tracking")
        
        # Create UI Designer
        oUIDesigner = new Agent("UI Designer", "Design user interfaces and user experience")
        oUIDesigner.addSkill("ui_design")
        oUIDesigner.addSkill("ux_design")
        oUIDesigner.addSkill("prototyping")
    
    func startProject aProjectRequirements
        oThreadManager.lockMutex(oMutex)
        aRequirements = aProjectRequirements
        
        # Project Manager analyzes requirements
        oProjectManager.assignTask([:type = "analysis", :content = aRequirements])
        
        # UI Designer creates mockups in parallel
        oUIDesigner.assignTask([:type = "design", :content = aRequirements])
        
        # Developers start implementation
        for oDev in oDevelopers {
            oDev.assignTask([:type = "implement", :content = aRequirements])
        }
        
        # QA prepares test cases
        oQATester.assignTask([:type = "test_planning", :content = aRequirements])
        
        oThreadManager.unlockMutex(oMutex)
        oThreadManager.signalCondition(oCondition)
    
    func monitorProgress
        while true {
            oThreadManager.lockMutex(oMutex)
            
            # Check all team members' status
            ? "Project Status Report for: " + cProjectName
            ? "================================="
            ? "Project Manager: " + oProjectManager.getState()
            ? "Backend Developer: " + oDevelopers[1].getState()
            ? "Frontend Developer: " + oDevelopers[2].getState()
            ? "QA Engineer: " + oQATester.getState()
            ? "UI Designer: " + oUIDesigner.getState()
            ? "================================="
            
            oThreadManager.unlockMutex(oMutex)
            sleep(1)  # Update every second
        }
    
    func submitCode oDeveloper, cCode
        oThreadManager.lockMutex(oMutex)
        add(aCodebase, [oDeveloper.getName(), cCode])
        oThreadManager.unlockMutex(oMutex)
        
        # Notify QA for testing
        oQATester.assignTask([:type = "test_code", :content = cCode])
    
    func reportBug cBugDescription
        oThreadManager.lockMutex(oMutex)
        
        # Assign bug to appropriate developer
        if find(cBugDescription, "frontend") {
            oDevelopers[2].assignTask([:type = "fix_bug", :content = cBugDescription])
        else
            oDevelopers[1].assignTask([:type = "fix_bug", :content = cBugDescription])
        }
        
        oThreadManager.unlockMutex(oMutex)
    
    func submitDesign cDesign
        oThreadManager.lockMutex(oMutex)
        add(aUIDesigns, cDesign)
        oThreadManager.unlockMutex(oMutex)
        
        # Notify frontend developer
        oDevelopers[2].assignTask([:type = "implement_design", :content = cDesign])

