/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getAgent
الوصف: الحصول على معلومات عميل محدد
*/
func getAgent
    try {
        # التحقق من وجود معرف في المعلمات
        cAgentID = ""

        # طباعة معلومات الطلب للتصحيح
        ? "Request method: " + oServer.getRequestMethod()

        # محاولة الحصول على المعرف من معلمات URL
        try {
            cAgentID = oServer.match(1)
            ? logger("getAgent function", "Using URL match parameter: " + cAgentID, :info)
        catch
            ? logger("getAgent function", "Error getting URL match parameter", :error)
        }

        # إذا كان المعرف فارغًا، حاول الحصول عليه من معلمات الاستعلام
        if cAgentID = NULL or len(cAgentID) = 0 {
            try {
                cAgentID = oServer.variable("agent_id")
                if cAgentID != NULL and len(cAgentID) > 0 {
                    ? logger("getAgent function", "Using variable agent_id: " + cAgentID, :info)
                }
            catch
                ? logger("getAgent function", "Error getting variable", :error)
            }
        }

        # لا نحتاج إلى هذا القسم بعد الآن لأننا استخدمنا oServer.variable

        # إذا كان المعرف لا يزال فارغًا، أرجع خطأ
        if cAgentID = NULL or len(cAgentID) = 0 {
            ? logger("getAgent function", "No agent_id found in any parameter", :error)
            oServer.setContent('{"status":"error","message":"No agent ID provided"}', "application/json")
            return
        }

        # التحقق من وجود معرف صالح
        if cAgentID = NULL or len(cAgentID) = 0 {
            oServer.setContent('{"status":"error","message":"Empty agent ID provided"}', "application/json")
            return
        }

        ? logger("getAgent function", "Getting agent with ID: " + cAgentID, :info)

        # البحث عن العميل بالمعرف
        oAgent = NULL
        ? logger("getAgent function", "Searching for agent with ID: " + cAgentID + " in " + len(aAgents) + " agents", :info)

        # تحويل المعرف إلى نص للمقارنة
        cAgentID = string(cAgentID)

        for i = 1 to len(aAgents) {
            cCurrentID = string(aAgents[i].getID())
            ? logger("getAgent function", "Agent " + i + " ID: " + cCurrentID, :info)

            if cCurrentID = cAgentID {
                oAgent = aAgents[i]
                ? logger("getAgent function", "Found agent: " + oAgent.getName(), :info)
                exit
            }
        }

        if isObject(oAgent) {
            # الحصول على المهارات
            cSkills = "[]"
            try {
                aSkills = oAgent.getSkills()
                if islist(aSkills) {
                    # تحويل المهارات إلى قائمة من الكائنات التي تحتوي على خاصية name
                    aFormattedSkills = []
                    for aSkill in aSkills {
                        if isList(aSkill) and aSkill[:name] != NULL {
                            add(aFormattedSkills, aSkill)
                        }
                    }
                    cSkills = list2JSON(aFormattedSkills)
                }
            catch
                # تجاهل الأخطاء
                ? logger("getAgent function", "Error getting skills: " + cCatchError, :error)
            }

            # الحصول على السمات الشخصية
            cPersonality = []
            try {
                aPersonality = oAgent.getPersonalityTraits()
                if isList(aPersonality) {
                    cPersonality = list2JSON(aPersonality)
                }
            catch
                # تجاهل الأخطاء
            }

            # الحصول على نموذج اللغة
            cLanguageModel = ""
            try {
                cLanguageModel = oAgent.getLanguageModel()
            catch
                cLanguageModel = "gemini-1.5-flash"
            }

            # الحصول على مستوى الطاقة
            nEnergy = 0
            try {
                nEnergy = oAgent.getEnergyLevel()
            catch
                nEnergy = 100
            }

            # الحصول على مستوى الثقة
            nConfidence = 0
            try {
                nConfidence = oAgent.getConfidenceLevel()
            catch
                nConfidence = 5
            }

            cJSON = '{"id":"' + oAgent.getID() +
                   '","name":"' + oAgent.getName() +
                   '","role":"' + oAgent.getRole() +
                   '","goal":"' + oAgent.getGoal() +
                   '","skills":' + cSkills +
                   ',"personality":' + cPersonality +
                   ',"status":"' + oAgent.getStatus() +
                   '","language_model":"' + cLanguageModel +
                   '","energy_level":' + nEnergy +
                   ',"confidence_level":' + nConfidence + '}'

            //? logger("getAgent function", "Agent found successfully", :info)
            oServer.setContent(cJSON, "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        ? logger("getAgent function", "Error getting agent: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
