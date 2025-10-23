/*
    RingAI Agents API
    Author: Azzeddine Remmal
    Date: 2025
*/

# تحميل المكتبات الأساسية
load "../libAgentAi.ring"
load "httplib.ring"
load "weblib.ring"

# تحميل المتغيرات العامة
load "Global.ring"

# تهيئة السيرفر
oServer = new Server

# تحميل الفئات
load "models\User.ring"

# تحميل دالة التهيئة
load "initialize.ring"

# تحميل مكونات التخطيط المشتركة
load "controllers\layout.ring"

# تحميل دوال العرض
load "controllers\showDashboard.ring"
load "controllers\showAgents.ring"
load "controllers\showTeams.ring"
load "controllers\showTasks.ring"
load "controllers\showUsers.ring"
load "controllers\showChat.ring"
load "controllers\showChatHistory.ring"
load "controllers\showAPIKeys.ring"

# تحميل دوال العملاء
load "agents\loadAgents.ring"
load "agents\saveAgents.ring"
load "agents\addAgent.ring"
load "agents\getAgent.ring"
load "agents\listAgents.ring"
load "agents\checkAgents.ring"
load "agents\updateAgent.ring"
load "agents\deleteAgent.ring"
load "agents\trainAgent.ring"
load "agents\getAgentSkills.ring"
load "agents\addAgentSkill.ring"

# تحميل دوال الفرق
load "teams\loadTeams.ring"
load "teams\saveTeams.ring"
load "teams\addTeam.ring"
load "teams\getTeam.ring"
load "teams\listTeams.ring"
load "teams\updateTeam.ring"
load "teams\deleteTeam.ring"
load "teams\addTeamMember.ring"
load "teams\removeTeamMember.ring"
load "teams\getTeamPerformance.ring"

# تحميل دوال المهام
load "tasks\loadTasks.ring"
load "tasks\saveTasks.ring"
load "tasks\addTask.ring"
load "tasks\getTask.ring"
load "tasks\listTasks.ring"
load "tasks\updateTask.ring"
load "tasks\deleteTask.ring"
load "tasks\addSubtask.ring"
load "tasks\updateTaskProgress.ring"
load "tasks\getTaskHistory.ring"

# تحميل دوال المستخدمين
load "users\addUser.ring"
load "users\getUser.ring"
load "users\updateUser.ring"
load "users\login.ring"
load "users\logout.ring"

# تحميل دوال الذكاء الاصطناعي
load "ai\aiChat.ring"
load "ai\aiAnalyze.ring"
load "ai\aiLearn.ring"
load "ai\getAIModels.ring"
load "ai\getChatHistory.ring"
load "ai\apiKeys.ring"

# تحميل دوال المراقبة
load "monitor\getMetrics.ring"
load "monitor\getPerformance.ring"
load "monitor\getEvents.ring"
load "monitor\configureAlerts.ring"

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
