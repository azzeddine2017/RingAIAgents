/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: updateAgent
الوصف: تحديث معلومات عميل
*/
func updateAgent
    try {
        # التحقق من وجود معرف في المعلمات
        cAgentID = ""

        # طباعة معلومات الطلب للتصحيح
        ? "Request method: " + oServer.getRequestMethod()

        # محاولة الحصول على المعرف من معلمات URL
        try {
            cAgentID = oServer.match(1)
            ? logger("updateAgent function", "Using URL match parameter: " + cAgentID, :info)
        catch
            ? logger("updateAgent function", "Error getting URL match parameter", :error)
        }

        # إذا كان المعرف فارغًا، حاول الحصول عليه من معلمات الاستعلام
        if cAgentID = NULL or len(cAgentID) = 0 {
            try {
                cAgentID = oServer.variable("agent_id")
                if cAgentID != NULL and len(cAgentID) > 0 {
                    ? logger("updateAgent function", "Using variable agent_id: " + cAgentID, :info)
                }
            catch
                ? logger("updateAgent function", "Error getting variable", :error)
            }
        }

        # إذا كان المعرف لا يزال فارغًا، أرجع خطأ
        if cAgentID = NULL or len(cAgentID) = 0 {
            ? logger("updateAgent function", "No agent_id found in any parameter", :error)
            oServer.setContent('{"status":"error","message":"No agent ID provided"}', "application/json")
            return
        }

        # التحقق من وجود معرف صالح
        if cAgentID = NULL or len(cAgentID) = 0 {
            oServer.setContent('{"status":"error","message":"Empty agent ID provided"}', "application/json")
            return
        }

        # تسجيل معلومات تحديث العميل
        ? logger("updateAgent function", "Updating agent with ID: " + cAgentID, :info)

        # البحث عن العميل بالمعرف
        oAgent = NULL

        # تحويل المعرف إلى نص للمقارنة
        cAgentID = string(cAgentID)

        for i = 1 to len(aAgents) {
            cCurrentID = string(aAgents[i].getID())

            if cCurrentID = cAgentID {
                oAgent = aAgents[i]
                ? logger("updateAgent function", "Found agent for update: " + oAgent.getName(), :info)
                exit
            }
        }

        if isObject(oAgent) {

            # تحديث المعلومات الأساسية
            oAgent.setName(oServer["name"])
            oAgent.setRole(oServer["role"])
            oAgent.setGoal(oServer["goal"])

            # تحديث المهارات
            if oServer["skills"] != NULL {
                try {
                    # حذف المهارات الحالية
                    ? logger("updateAgent function", "Clearing existing skills", :info)
                    oAgent.setSkills([])

                    # تقسيم المهارات المفصولة بفواصل
                    Skills = split(oServer["skills"], ",")
                    ? logger("updateAgent function", "Skills to add: " + list2str(Skills), :info)

                    # إضافة المهارات الجديدة
                    for i = 1 to len(Skills) {
                        if i <= len(Skills) {  # التحقق من أن المؤشر ضمن النطاق
                            cSkill = trim(Skills[i])
                            if len(cSkill) > 0 {
                                ? logger("updateAgent function", "Adding skill: " + cSkill, :info)
                                try {
                                    oAgent.addSkill(cSkill, 50)  # مستوى افتراضي 50
                                catch
                                    ? logger("updateAgent function", "Error adding skill: " + cCatchError, :error)
                                }
                            }
                        }
                    }

                    # طباعة المهارات بعد التحديث
                    try {
                        ? logger("updateAgent function", "Updated skills: " + list2str(oAgent.getSkills()), :info)
                    catch
                        ? logger("updateAgent function", "Error getting updated skills: " + cCatchError, :error)
                    }
                catch
                    ? logger("updateAgent function", "Error updating skills: " + cCatchError, :error)
                }
            else
                ? logger("updateAgent function", "No skills specified in update", :info)
            }

            # تحديث نموذج اللغة
            if oServer["language_model"] != NULL {
                oAgent.setLanguageModel(oServer["language_model"])
            }

            # تحديث السمات الشخصية
            try {
                aPersonality = [
                    :openness = number(oServer["openness"]),
                    :conscientiousness = number(oServer["conscientiousness"]),
                    :extraversion = number(oServer["extraversion"]),
                    :agreeableness = number(oServer["agreeableness"]),
                    :neuroticism = number(oServer["neuroticism"])
                ]
                oAgent.setPersonalityTraits(aPersonality)
            catch
                # تجاهل الأخطاء
            }

            # حفظ العملاء في قاعدة البيانات
            saveAgents()

            ? logger("updateAgent function", "Agent updated successfully", :info)
            oServer.setContent('{"status":"success","message":"Agent updated successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        ? logger("updateAgent function", "Error updating agent: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
