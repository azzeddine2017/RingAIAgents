/*
    RingAI Agents API
    Author: Azzeddine Remmal
    Date: 2025
*/

# تحميل المكتبات الأساسية
load "G:\RingAIAgents\src\libAgantAi.ring"
load "httplib.ring"
load "weblib.ring"

# تحميل المتغيرات العامة
load "G:\RingAIAgents\src\api\Global.ring"

# تهيئة السيرفر
oServer = new Server

# تحميل الفئات
load "G:\RingAIAgents\src\api\models\User.ring"

# تحميل دالة التهيئة
load "G:\RingAIAgents\src\api\initialize.ring"

# تحميل مكونات التخطيط المشتركة
load "G:\RingAIAgents\src\api\controllers\layout.ring"

# تحميل دوال العرض
load "G:\RingAIAgents\src\api\controllers\showDashboard.ring"
load "G:\RingAIAgents\src\api\controllers\showAgents.ring"
load "G:\RingAIAgents\src\api\controllers\showTeams.ring"
load "G:\RingAIAgents\src\api\controllers\showTasks.ring"
load "G:\RingAIAgents\src\api\controllers\showUsers.ring"
load "G:\RingAIAgents\src\api\controllers\showChat.ring"
load "G:\RingAIAgents\src\api\controllers\showChatHistory.ring"
load "G:\RingAIAgents\src\api\controllers\showAPIKeys.ring"

# تحميل دوال العملاء
load "G:\RingAIAgents\src\api\agents\loadAgents.ring"
load "G:\RingAIAgents\src\api\agents\saveAgents.ring"
load "G:\RingAIAgents\src\api\agents\addAgent.ring"
load "G:\RingAIAgents\src\api\agents\getAgent.ring"
load "G:\RingAIAgents\src\api\agents\listAgents.ring"
load "G:\RingAIAgents\src\api\agents\checkAgents.ring"
load "G:\RingAIAgents\src\api\agents\updateAgent.ring"
load "G:\RingAIAgents\src\api\agents\deleteAgent.ring"
load "G:\RingAIAgents\src\api\agents\trainAgent.ring"
load "G:\RingAIAgents\src\api\agents\getAgentSkills.ring"
load "G:\RingAIAgents\src\api\agents\addAgentSkill.ring"

# تحميل دوال الفرق
load "G:\RingAIAgents\src\api\teams\loadTeams.ring"
load "G:\RingAIAgents\src\api\teams\saveTeams.ring"
load "G:\RingAIAgents\src\api\teams\addTeam.ring"
load "G:\RingAIAgents\src\api\teams\getTeam.ring"
load "G:\RingAIAgents\src\api\teams\listTeams.ring"
load "G:\RingAIAgents\src\api\teams\updateTeam.ring"
load "G:\RingAIAgents\src\api\teams\deleteTeam.ring"
load "G:\RingAIAgents\src\api\teams\addTeamMember.ring"
load "G:\RingAIAgents\src\api\teams\removeTeamMember.ring"
load "G:\RingAIAgents\src\api\teams\getTeamPerformance.ring"

# تحميل دوال المهام
load "G:\RingAIAgents\src\api\tasks\loadTasks.ring"
load "G:\RingAIAgents\src\api\tasks\saveTasks.ring"
load "G:\RingAIAgents\src\api\tasks\addTask.ring"
load "G:\RingAIAgents\src\api\tasks\getTask.ring"
load "G:\RingAIAgents\src\api\tasks\listTasks.ring"
load "G:\RingAIAgents\src\api\tasks\updateTask.ring"
load "G:\RingAIAgents\src\api\tasks\deleteTask.ring"
load "G:\RingAIAgents\src\api\tasks\addSubtask.ring"
load "G:\RingAIAgents\src\api\tasks\updateTaskProgress.ring"
load "G:\RingAIAgents\src\api\tasks\getTaskHistory.ring"

# تحميل دوال المستخدمين
load "G:\RingAIAgents\src\api\users\addUser.ring"
load "G:\RingAIAgents\src\api\users\getUser.ring"
load "G:\RingAIAgents\src\api\users\updateUser.ring"
load "G:\RingAIAgents\src\api\users\login.ring"
load "G:\RingAIAgents\src\api\users\logout.ring"

# تحميل دوال الذكاء الاصطناعي
load "G:\RingAIAgents\src\api\ai\aiChat.ring"
load "G:\RingAIAgents\src\api\ai\aiAnalyze.ring"
load "G:\RingAIAgents\src\api\ai\aiLearn.ring"
load "G:\RingAIAgents\src\api\ai\getAIModels.ring"
load "G:\RingAIAgents\src\api\ai\getChatHistory.ring"
load "G:\RingAIAgents\src\api\ai\apiKeys.ring"

# تحميل دوال المراقبة
load "G:\RingAIAgents\src\api\monitor\getMetrics.ring"
load "G:\RingAIAgents\src\api\monitor\getPerformance.ring"
load "G:\RingAIAgents\src\api\monitor\getEvents.ring"
load "G:\RingAIAgents\src\api\monitor\configureAlerts.ring"

# تهيئة النظام وتشغيل السيرفر
initialize()

# تهيئة مجلدات الموارد
oServer.shareFolder("static")

? logger("RingAI Agents API Server", "RingAI Agents API Server running at http://localhost:8080", :info)

try {
    # تشغيل السيرفر
    oServer.listen("0.0.0.0", 8080)

    # فتح المتصفح على العنوان
    //system("start chrome --new-window http://localhost:8080")

    ? logger("RingAI Agents API Server", "Browser opened successfully!", :info)
catch
    ? logger("RingAI Agents API Server", "Error starting server: " + cCatchError, :error)
}
