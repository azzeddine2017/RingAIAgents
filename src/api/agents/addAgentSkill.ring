/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: addAgentSkill
الوصف: إضافة مهارة جديدة لعميل
*/
func addAgentSkill
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aAgents) {
            oAgent = aAgents[nID]

            cSkill = oServer["skill"]
            nInitialLevel = number(oServer["initial_level"])

            # إضافة المهارة
            oAgent.addSkill(cSkill, nInitialLevel)
            ? logger("addAgentSkill function", "Skill added successfully", :info)
            oServer.setContent('{"status":"success","message":"Skill added successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
