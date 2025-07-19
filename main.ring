/*
    RingAI Agents - Main Application
    Author: Azzeddine Remmal
    Date: 2025
*/

# Load the core library
load "src/libAgentAi.ring"

# Initialize the system
oSystem = new AgentAI()

# Create agents
oFrontendDev = oSystem.createAgent("Frontend Developer", "Specializes in UI/UX development")
oFrontendDev.setRole("Frontend Developer")
oFrontendDev.addSkill("JavaScript", 90)
oFrontendDev.addSkill("React", 85)
oFrontendDev.addSkill("CSS", 80)

oBackendDev = oSystem.createAgent("Backend Developer", "Specializes in server-side development")
oBackendDev.setRole("Backend Developer")
oBackendDev.addSkill("Python", 90)
oBackendDev.addSkill("Node.js", 85)
oBackendDev.addSkill("Databases", 80)

# Create a team
oDevTeam = oSystem.createTeam("Development Team", oBackendDev)
oDevTeam.addMember(oFrontendDev)

# Create tasks
oLoginTask = oSystem.createTask("Implement user login functionality")
oLoginTask.setPriority(8)

oDashboardTask = oSystem.createTask("Create dashboard UI")
oDashboardTask.setPriority(7)

# Assign tasks
oSystem.assignTask(oLoginTask, oBackendDev)
oSystem.assignTask(oDashboardTask, oFrontendDev)

# Display system status
? "System Status:"
? "=============="
aStatus = oSystem.getSystemStatus()
? "Agents: " + aStatus[:agents]
? "Teams: " + aStatus[:teams]
? "Tasks: " + aStatus[:tasks]
? "Tools: " + aStatus[:tools]

# Execute tasks
? nl + "Executing tasks..."
oBackendDev.executeTask()
oFrontendDev.executeTask()

? nl + "Done!"
