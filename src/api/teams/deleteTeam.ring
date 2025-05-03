/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: deleteTeam
الوصف: حذف فريق
*/
func deleteTeam
    try {
        # محاولة الحصول على المعرف من معلمات URL
        cTeamID = ""
        try {
            cTeamID = oServer.match(1)
            ? logger("deleteTeam function", "Using URL match parameter: " + cTeamID, :info)
        catch
            ? logger("deleteTeam function", "Error getting URL match parameter", :error)
        }

        # التحقق من وجود معرف صالح
        if cTeamID = NULL or len(cTeamID) = 0 {
            oServer.setContent('{"status":"error","message":"No team ID provided"}', "application/json")
            return
        }

        # البحث عن الفريق بالمعرف
        oCrew = NULL
        nIndex = 0

        for i = 1 to len(aTeams) {
            if aTeams[i].getId() = cTeamID {
                oCrew = aTeams[i]
                nIndex = i
                exit
            }
        }

        if oCrew != NULL {
            # إزالة الفريق من المراقب
            try {
                oMonitor.unregisterCrew(oCrew)
                ? logger("deleteTeam function", "Team unregistered from monitor", :info)
            catch
                ? logger("deleteTeam function", "Error unregistering team: " + cCatchError, :error)
            }

            # حذف الفريق
            del(aTeams, nIndex)
            ? logger("deleteTeam function", "Team deleted", :info)

            # حفظ التغييرات في قاعدة البيانات
            if saveTeams() {
                ? logger("deleteTeam function", "Team deleted and database updated", :info)
                oServer.setContent('{"status":"success","message":"Team deleted successfully"}',
                                  "application/json")
            else
                ? logger("deleteTeam function", "Team deleted but database not updated", :warning)
                oServer.setContent('{"status":"warning","message":"Team deleted but database not updated"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("deleteTeam function", "Error deleting team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
