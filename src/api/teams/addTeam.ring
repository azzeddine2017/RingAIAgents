/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: addTeam
الوصف: إنشاء فريق جديد
*/
func addTeam
    try {
        # الحصول على معلومات الفريق
        cName = oServer.variable("name")
        cObjective = oServer.variable("objective")
        cLeaderId = oServer.variable("leader_id")

        ? logger("addTeam function", "Creating team: " + cName, :info)
        ? logger("addTeam function", "Objective: " + cObjective, :info)
        ? logger("addTeam function", "Leader ID: " + cLeaderId, :info)

        # تعيين القائد وإنشاء الفريق
        for i = 1 to len(aAgents) {
            if aAgents[i].getID() = cLeaderId {
                # إنشاء الفريق
                oCrew = new Crew(cName, aAgents[i])

                ? logger("addTeam function", "Leader set to: " + aAgents[i].getName(), :info)
                exit
            }
        }

        # إضافة الأعضاء
        cMemberIds = oServer.variable("member_ids")
        if len(cMemberIds) > 0 {
            try {
                aMemberIds = JSON2List(cMemberIds)
                if isList(aMemberIds) {
                    for cMemberId in aMemberIds {
                        for i = 1 to len(aAgents) {
                            if aAgents[i].getID() = cMemberId {
                                oCrew.addMember(aAgents[i])
                                ? logger("addTeam function", "Added member: " + aAgents[i].getName(), :info)
                                exit
                            }
                        }
                    }
                }
            catch
                ? logger("addTeam function", "Error parsing member IDs: " + cCatchError, :error)
            }
        }

        # تسجيل الفريق
        add(aTeams, oCrew)
        oMonitor.registerCrew(oCrew)
        # حفظ الفريق في قاعدة البيانات
        if saveTeams() {
            ? logger("addTeam function", "Team created and saved successfully", :info)
            oServer.setContent('{"status":"success","message":"Team created successfully","id":"' +
                              oCrew.getId() + '"}', "application/json")
        else
            ? logger("addTeam function", "Team created but not saved to database", :warning)
            oServer.setContent('{"status":"warning","message":"Team created but not saved to database","id":"' +
                              oCrew.getId() + '"}', "application/json")
        }
    catch
        ? logger("addTeam function", "Error creating team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
