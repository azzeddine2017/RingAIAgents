/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: updateTeam
الوصف: تحديث معلومات فريق
*/
func updateTeam
    try {
        # محاولة الحصول على المعرف من معلمات URL
        cTeamID = ""
        try {
            cTeamID = oServer.match(1)
            ? logger("updateTeam function", "Using URL match parameter: " + cTeamID, :info)
        catch
            ? logger("updateTeam function", "Error getting URL match parameter", :error)
        }

        # التحقق من وجود معرف صالح
        if cTeamID = NULL or len(cTeamID) = 0 {
            oServer.setContent('{"status":"error","message":"No team ID provided"}', "application/json")
            return
        }

        # البحث عن الفريق بالمعرف
        oCrew = NULL

        for i = 1 to len(aTeams) {
            if aTeams[i].getId() = cTeamID {
                oCrew = aTeams[i]
                exit
            }
        }

        if oCrew != NULL {

            # تحديث المعلومات الأساسية
            cName = oServer.variable("name")
            cObjective = oServer.variable("objective")

            ? logger("updateTeam function", "Updating team name to: " + cName, :info)
            ? logger("updateTeam function", "Updating team objective to: " + cObjective, :info)

            oCrew.setName(cName)
            oCrew.setObjective(cObjective)

            # تحديث القائد
            cLeaderId = oServer.variable("leader_id")
            ? logger("updateTeam function", "Leader ID: " + cLeaderId, :info)

            # البحث عن العميل بالمعرف
            for i = 1 to len(aAgents) {
                if aAgents[i].getID() = cLeaderId {
                    oCrew.setLeader(aAgents[i])
                    ? logger("updateTeam function", "Leader set to: " + aAgents[i].getName(), :info)
                    exit
                }
            }

            # حفظ التغييرات في قاعدة البيانات
            if saveTeams() {
                ? logger("updateTeam function", "Team updated and saved successfully", :info)
                oServer.setContent('{"status":"success","message":"Team updated successfully"}',
                                  "application/json")
            else
                ? logger("updateTeam function", "Team updated but not saved to database", :warning)
                oServer.setContent('{"status":"warning","message":"Team updated but not saved to database"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("updateTeam function", "Error updating team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
