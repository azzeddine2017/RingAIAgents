/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getAgentSkills
الوصف: الحصول على مهارات عميل
*/
func getAgentSkills
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aAgents) {
            oAgent = aAgents[nID]
            ? logger("getAgentSkills function", "Skills retrieved successfully", :info)
            oServer.setContent('{
                "agent_id": ' + nID + ',
                "skills": ' + listToJSON(oAgent.getSkills(), 0) + ',
                "skill_levels": ' + listToJSON(oAgent.getSkillLevels(), 0) + '
            }', "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found"}',
                              "application/json")
        }
    catch
        ? logger("getAgentSkills function", "Error retrieving skills: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
