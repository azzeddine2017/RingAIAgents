/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: listAgents
الوصف: الحصول على قائمة العملاء
*/
func listAgents
    try {
        ? logger("listAgents function", "listAgents function called", :info)
        ? logger("listAgents function", "Number of agents: " + len(aAgents), :info)

        aAgentsList = []

        # تجميع معلومات العملاء من المتغير العام aAgents
        for i = 1 to len(aAgents) {
            oAgent = aAgents[i]

            # تجميع المعلومات الأساسية
            aAgentInfo = [
                :id = oAgent.getID(),
                :name = oAgent.getName(),
                :role = oAgent.getRole()
            ]

            ? logger("listAgents function", "Agent " + i + ": " + oAgent.getName() + " (" + oAgent.getRole() + ")", :info)
            add(aAgentsList, aAgentInfo)
        }

        # إذا لم يكن هناك عملاء، إنشاء عملاء افتراضيين
        if len(aAgentsList) = 0 {
            ? logger("listAgents function", "No agents found, creating default agents", :info)

            # إنشاء عميل افتراضي
            oDefaultAgent = new Agent("Default Assistant", "A helpful AI assistant that can answer questions and provide information.")
            oDefaultAgent {
                setRole("Assistant")
                addSkill("General Knowledge", 90)
                setLanguageModel("gemini-1.5-flash")
            }

            # إضافة العميل الافتراضي إلى القائمة العامة
            add(aAgents, oDefaultAgent)

            # إضافة العميل الافتراضي إلى قائمة الاستجابة
            add(aAgentsList, [
                :id = oDefaultAgent.getID(),
                :name = oDefaultAgent.getName(),
                :role = oDefaultAgent.getRole()
            ])

            # إنشاء عميل للبرمجة
            oCodingAgent = new Agent("Code Assistant", "A specialized AI assistant for programming and software development.")
            oCodingAgent {
                setRole("Developer")
                addSkill("Programming", 95)
                setLanguageModel("gemini-1.5-flash")
            }

            # إضافة عميل البرمجة إلى القائمة العامة
            add(aAgents, oCodingAgent)

            # إضافة عميل البرمجة إلى قائمة الاستجابة
            add(aAgentsList, [
                :id = oCodingAgent.getID(),
                :name = oCodingAgent.getName(),
                :role = oCodingAgent.getRole()
            ])

            # حفظ العملاء الافتراضيين في قاعدة البيانات
            saveAgents()
        }

        # تحويل القائمة إلى JSON بشكل يدوي لضمان التنسيق الصحيح
        ? logger("listAgents function", "Creating JSON manually", :info)

        cJSON = '{"agents":['
        for i = 1 to len(aAgentsList) {
            oAgent = aAgentsList[i]

            # التأكد من أن المعرف هو نص وليس رقم
            cId = string(oAgent[:id])

            cJSON += '{"id":"' + cId +
                    '","name":"' + oAgent[:name] +
                    '","role":"' + oAgent[:role] + '"}'

            if i < len(aAgentsList) {
                cJSON += ","
            }
        }
        cJSON += ']}'

        # تسجيل JSON النهائي للتحقق
        ? logger("listAgents function", "Final JSON: " + cJSON, :info)

        ? logger("listAgents function", "Agents listed successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("listAgents function", "Error listing agents: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
