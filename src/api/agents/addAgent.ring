/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: addAgent
الوصف: إضافة عميل جديد
*/
func addAgent
    try {
        ? logger("addAgent function", "Adding agent: " + oServer["name"], :info)
        oAgent = new Agent(oServer["name"], oServer["goal"]) {
            setRole(oServer["role"])

            # تهيئة المهارات
            if oServer["skills"] != NULL {
                # تقسيم المهارات المفصولة بفواصل
                Skills = split(oServer["skills"], ",")
                ? logger("addAgent function", "Skills to add: " + ToCode(Skills), :info)

                # إضافة كل مهارة
                for i = 1 to len(Skills) {
                    cSkill = trim(Skills[i])
                    if len(cSkill) > 0 {
                        ? logger("addAgent function", "Adding skill: " + cSkill, :info)
                        try {
                            addSkill(cSkill, 50)  # مستوى افتراضي 50
                        catch
                            ? logger("addAgent function", "Error adding skill: " + cCatchError, :error)
                        }
                    }
                }

                # طباعة المهارات بعد التهيئة
                try {
                    ? logger("addAgent function", "Initial skills: " + ToCode(getSkills()), :info)
                catch
                    ? logger("addAgent function", "Error getting skills: " + cCatchError, :error)
                }
            else
                # إضافة مهارة افتراضية إذا لم يتم تحديد مهارات
                ? logger("addAgent function", "No skills specified, adding default skill", :info)
                addSkill("General Knowledge", 50)
            }

            # تهيئة الخصائص
            setProperties(oServer["properties"])

            # تهيئة السمات الشخصية
            setPersonalityTraits([
                :openness = number(oServer["openness"]),
                :conscientiousness = number(oServer["conscientiousness"]),
                :extraversion = number(oServer["extraversion"]),
                :agreeableness = number(oServer["agreeableness"]),
                :neuroticism = number(oServer["neuroticism"])
            ])

            # تهيئة نموذج اللغة
            setLanguageModel(oServer["language_model"])
        }

        # إضافة العميل وتسجيله في المراقب
        add(aAgents, oAgent)
        oMonitor.registerAgent(oAgent)

        # تخزين معلومات العميل في الذاكرة content, type, priority, tags, metadata
        oMemory.store([
            :content = "Agent created: " + oAgent.getName(),
            :type =  oMemory.LONG_TERM ,
            :priority = 8,
            :tags = ["agent", "creation"],
            :metadata = [:timestamp = TimeList()[5]]
        ])

        # حفظ العملاء في قاعدة البيانات
        saveAgents()

        oServer.setContent('{"status":"success","message":"Agent added successfully","id":' +
                          len(aAgents) + '}', "application/json")
    catch
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
