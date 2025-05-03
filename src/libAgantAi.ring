/*
    مكتبة RingAI Agents - الواجهة الرئيسية
    تجمع كل المكونات الأساسية في مكان واحد
*/

# تحميل المكتبات الأساسية
load "sqlitelib.ring"
load "ringThreadPro.ring"
load "consolecolors.ring"
load "stdlib.ring"
load "jsonlib.ring"
load "ziplib.ring"
load "csvlib.ring"
load "subprocess.ring"
load "openssllib.ring"

# تحميل المكتبات المساعدة
load "G:/RingAIAgents/src/utils/ringToJson.ring"
Load "G:/RingAIAgents/src/utils/helpers.ring"
Load "G:/RingAIAgents/src/utils/http_client.ring"
Load "G:/RingAIAgents/src/core/state.ring"

# تحميل المكونات الأساسية بالترتيب الصحيح
Load "G:/RingAIAgents/src/core/tools.ring"      # لا يعتمد على أي مكون آخر
Load "G:/RingAIAgents/src/core/memory.ring"     # لا يعتمد على أي مكون آخر
Load "G:/RingAIAgents/src/core/task.ring"       # لا يعتمد على أي مكون آخر
Load "G:/RingAIAgents/src/core/llm.ring"        # يعتمد على helpers
Load "G:/RingAIAgents/src/core/monitor.ring"    # لا يعتمد على أي مكون آخر
Load "G:/RingAIAgents/src/core/reinforcement.ring" # لا يعتمد على أي مكون آخر
Load "G:/RingAIAgents/src/core/flow.ring"       # يعتمد على state
Load "G:/RingAIAgents/src/core/agent.ring"      # يعتمد على llm, task, memory, tools
Load "G:/RingAIAgents/src/core/crew.ring"       # يعتمد على agent
Load "G:/RingAIAgents/src/core/integration.ring" # يعتمد على memory, task, agent, crew

# تحميل أدوات البناء 
Load "G:\RingAIAgents\src\tools\development_tools.ring"
Load "G:\RingAIAgents\src\tools\DefaultTools.ring"
//Load "G:\RingAIAgents\src\tools\advancedtools.ring"

if isMainSourceFile() {
    serverdebug = true
    aDebag = [:error, :info]
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
}

class AgentAI

    # الثوابت
    IDLE = :idle
    WORKING = :working
    LEARNING = :learning
    ERROR = :error
    
    # المتغيرات العامة
    bVerbose = true

    func init
        if bVerbose { ? "تهيئة نظام العملاء الذكي" }

        # تهيئة المكونات الأساسية
        oMemory = new Memory("G:/RingAIAgents/db/AgentAI_memory.db")
        oMonitor = new PerformanceMonitor("G:/RingAIAgents/db/AgentAI_monitor.db")
        oRL = new ReinforcementLearning(:epsilon_greedy)

        # تهيئة القوائم
        aAgents = []
        aTeams = []
        aTools = []
        aTasks = []

        return self

    # إدارة العملاء
    func createAgent cName, cDescription
        oAgent = new Agent(cName, cDescription)
        add(aAgents, oAgent)
        if bVerbose { ? "تم إنشاء عميل جديد: " + cName }
        return oAgent

    func removeAgent cAgentId
        for i = 1 to len(aAgents) {
            if aAgents[i].getId() = cAgentId {
                del(aAgents, i)
                if bVerbose { ? "تم حذف العميل: " + cAgentId }
                return true
            }
        }
        return false

    # إدارة الفرق
    func createTeam  objectName, cName, oLeaderAgent
        oTeam = new Crew(objectName, cName, oLeaderAgent)
        add(aTeams, oTeam)
        if bVerbose { ? "تم إنشاء فريق جديد: " + cName }
        return oTeam

    func removeTeam cTeamId
        for i = 1 to len(aTeams) {
            if aTeams[i].getId() = cTeamId {
                del(aTeams, i)
                if bVerbose { ? "تم حذف الفريق: " + cTeamId }
                return true
            }
        }
        return false

    # إدارة المهام
    func createTask cDescription
        oTask = new Task(cDescription)
        add(aTasks, oTask)
        if bVerbose { ? "تم إنشاء مهمة جديدة: " + cDescription }
        return oTask

    func assignTask oTask, oAgent
        if oAgent.assignTask(oTask) {
            if bVerbose { ? "تم إسناد المهمة للعميل: " + oAgent.getName() }
            return true
        }
        return false

    # إدارة الأدوات
    func registerTool oTool
        add(aTools, oTool)
        if bVerbose { ? "تم تسجيل أداة جديدة: " + oTool.getName() }
        return true

    func unregisterTool cToolName
        for i = 1 to len(aTools) {
            if aTools[i].getName() = cToolName {
                del(aTools, i)
                if bVerbose { ? "تم إلغاء تسجيل الأداة: " + cToolName }
                return true
            }
        }
        return false

    # المراقبة والتحليل
    func getPerformanceMetrics
        return oMonitor.getMetrics()

    func getSystemStatus
        return [
            :agents = len(aAgents),
            :teams = len(aTeams),
            :tasks = len(aTasks),
            :tools = len(aTools)
        ]

    private
        # المكونات الأساسية
        oMemory
        oMonitor
        oRL

        # القوائم
        aAgents
        aTeams
        aTools
        aTasks

        # الدوال المساعدة
        func logger cMessage, cType
            if bVerbose {
                ? "[" + cType + "] " + cMessage
            }
