/*
    RingAI Agents API - Initialization
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: initialize
الوصف: تهيئة النظام
*/
func initialize
    try {
        ? logger("initialize function", "Initializing RingAI Agents API System...", :info)

        # تهيئة المكونات الأساسية
        oMonitor = new PerformanceMonitor("G:\RingAIAgents\db/performance_metrics.db")
        oMemory = new Memory("G:\RingAIAgents\db/memories.db")

        # التحقق من وجود مفتاح API لـ Gemini
        cGeminiApiKey = sysget("GEMINI_API_KEY")
        if cGeminiApiKey = "" {
            ? logger("initialize function", "GEMINI_API_KEY environment variable not set. Using default key.", :warning)
            cGeminiApiKey = "AIzaSyDJC5a7TpnJWQfG2rPlOvDpGDWCRKigDGc"  # مفتاح API افتراضي للاختبار فقط
        }

        # تهيئة نموذج اللغة
        oLLM = new LLM(GEMINI)
        oLLM.setApiKey(cGeminiApiKey)

        # تسجيل المكونات للمراقبة
        oMonitor.registerLLM(oLLM)
        oMonitor.startMonitoring()

        # تحميل العملاء
        loadAgents()

        # تحميل الفرق
        loadTeams()

        # تحميل المهام
        loadTasks()

        ? logger("initialize function", "System initialized successfully!", :info)
    catch
        ? logger("initialize function", "Error initializing system: " + cCatchError, :error)
    }

    # تعريف المسارات

    ## مسارات العرض الرئيسية
    oServer.route(:Get, "/", :showDashboard)
    oServer.route(:Get, "/agents", :showAgents)
    oServer.route(:Get, "/teams", :showTeams)
    oServer.route(:Get, "/tasks", :showTasks)
    oServer.route(:Get, "/users", :showUsers)
    oServer.route(:Get, "/chat", :showChat)
    oServer.route(:Get, "/chat/history", :showChatHistory)
    oServer.route(:Get, "/api-keys", :showAPIKeys)

    ## مسارات العملاء
    oServer.route(:Post, "/agents/add", :addAgent)
    oServer.route(:Get, "/agents/([^/]+)", :getAgent)
    oServer.route(:Get, "/api/agents/list", :listAgents)  # مسار للحصول على قائمة العملاء
    oServer.route(:Get, "/api/agents/check", :checkAgents)  # مسار للتحقق من حالة العملاء
    oServer.route(:Post, "/agents/([^/]+)/update", :updateAgent)
    oServer.route(:Post, "/agents/([^/]+)/delete", :deleteAgent)
    oServer.route(:Post, "/agents/([^/]+)/train", :trainAgent)
    oServer.route(:Get, "/agents/([^/]+)/skills", :getAgentSkills)
    oServer.route(:Post, "/agents/([^/]+)/skills", :addAgentSkill)

    ## مسارات الفرق
    oServer.route(:Post, "/teams/add", :addTeam)
    oServer.route(:Get, "/teams/([^/]+)", :getTeam)
    oServer.route(:Get, "/api/teams/list", :listTeams)  # مسار للحصول على قائمة الفرق
    oServer.route(:Post, "/teams/([^/]+)/update", :updateTeam)
    oServer.route(:Post, "/teams/([^/]+)/delete", :deleteTeam)
    oServer.route(:Post, "/teams/([^/]+)/members", :addTeamMember)
    oServer.route(:Post, "/teams/([^/]+)/members/([^/]+)", :removeTeamMember)
    oServer.route(:Get, "/teams/([^/]+)/performance", :getTeamPerformance)

    ## مسارات المهام
    oServer.route(:Post, "/tasks/add", :addTask)
    oServer.route(:Get, "/tasks/([^/]+)", :getTask)
    oServer.route(:Get, "/api/tasks/list", :listTasks)  
    oServer.route(:Post, "/tasks/([^/]+)/update", :updateTask)
    oServer.route(:Post, "/tasks/([^/]+)/delete", :deleteTask)
    oServer.route(:Post, "/tasks/([^/]+)/subtasks", :addSubtask)
    oServer.route(:Post, "/tasks/([^/]+)/progress", :updateTaskProgress)
    oServer.route(:Get, "/tasks/([^/]+)/history", :getTaskHistory)

    ## مسارات المستخدمين
    oServer.route(:Post, "/users/add", :addUser)
    oServer.route(:Get, "/users/([^/]+)", :getUser)
    oServer.route(:Post, "/users/([^/]+)/update", :updateUser)
    oServer.route(:Post, "/users/([^/]+)/delete", :deleteUser)
    oServer.route(:Post, "/login", :login)
    oServer.route(:Get, "/logout", :logout)

    ## مسارات الذكاء الاصطناعي
    oServer.route(:Post, "/ai/chat", :aiChat)
    oServer.route(:Post, "/ai/analyze", :aiAnalyze)
    oServer.route(:Post, "/ai/learn", :aiLearn)
    oServer.route(:Get, "/ai/models", :getAIModels)
    oServer.route(:Post, "/ai/chat/history", :getChatHistory)

    ## مسارات مفاتيح API
    oServer.route(:Get, "/api/keys", :getAPIKeys)
    oServer.route(:Post, "/api/keys", :addAPIKey)
    oServer.route(:Post, "/api/keys/([^/]+)/update", :updateAPIKey)
    oServer.route(:Post, "/api/keys/([^/]+)/delete", :deleteAPIKey)
    oServer.route(:Post, "/api/keys/([^/]+)/test", :testAPIKey)

    ## مسارات المراقبة
    oServer.route(:Get, "/monitor/metrics", :getMetrics)
    oServer.route(:Get, "/monitor/performance", :getPerformance)
    oServer.route(:Get, "/monitor/events", :getEvents)
    oServer.route(:Post, "/monitor/alerts", :configureAlerts)
