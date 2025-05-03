/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: saveAgents
الوصف: حفظ العملاء في قاعدة البيانات
*/
func saveAgents
    try {
        # التحقق من وجود عملاء
        if len(aAgents) = 0 {
            return false
        }

        # تحديد مسار قاعدة البيانات
        cDBPath = "G:\RingAIAgents\db\agents.db"

        # إنشاء قاعدة بيانات للعملاء إذا لم تكن موجودة
        if !fexists(cDBPath) {
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # إنشاء جدول العملاء
            cSQL = "CREATE TABLE IF NOT EXISTS agents (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT,
                    role TEXT,
                    goal TEXT,
                    skills TEXT,
                    personality TEXT,
                    language_model TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # إغلاق قاعدة البيانات
            sqlite_close(oDatabase)
        }

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # حذف جميع العملاء الموجودين
        sqlite_execute(oDatabase, "DELETE FROM agents")

        # حفظ العملاء الحاليين
        for i = 1 to len(aAgents) {
            oAgent = aAgents[i]

            # تحويل المهارات والسمات الشخصية إلى JSON
            cSkills = "[]"
            try {
                aSkills = oAgent.getSkills()

                # التحقق من أن aSkills هي قائمة وليست فارغة
                if islist(aSkills) and len(aSkills) > 0 {
                    # طباعة المهارات للتصحيح
                    ? logger("saveAgents function", "Skills for agent " + oAgent.getName() + ": " + list2str(aSkills), :info)

                    # تحويل المهارات إلى JSON
                    try {
                        cSkills = listTojson(aSkills, 0)
                        ? logger("saveAgents function", "Skills JSON: " + cSkills, :info)
                    catch
                        ? logger("saveAgents function", "Error converting skills to JSON: " + cCatchError, :error)
                        cSkills = "[]"
                    }
                else
                    ? logger("saveAgents function", "No skills found or empty skills list for agent: " + oAgent.getName(), :info)
                }
            catch
                # تجاهل الأخطاء
                ? logger("saveAgents function", "Error getting skills: " + cCatchError, :error)
            }

            cPersonality = []
            try {
                aPersonality = oAgent.getPersonalityTraits()
                if isList(aPersonality) {
                    cPersonality = listToJSON(aPersonality, 0)
                }
            catch
                # تجاهل الأخطاء
            }

            # الحصول على هدف العميل
            cGoal = ""
            try {
                cGoal = oAgent.getGoal()
            catch
                cGoal = "General purpose agent"
            }

            # الحصول على نموذج اللغة
            cLanguageModel = ""
            try {
                cLanguageModel = oAgent.getLanguageModel()
            catch
                cLanguageModel = "gemini-1.5-flash"
            }

            # إضافة العميل إلى قاعدة البيانات
            cSQL = "INSERT INTO agents (name, role, goal, skills, personality, language_model) VALUES (
                    '" + oAgent.getName() + "',
                    '" + oAgent.getRole() + "',
                    '" + cGoal + "',
                    '" + cSkills + "',
                    '" + cPersonality + "',
                    '" + cLanguageModel + "'
                )"
            sqlite_execute(oDatabase, cSQL)
        }

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        return true
    catch
        ? logger("saveAgents function", "Error saving agents: " + cCatchError, :error)
        return false
    }
