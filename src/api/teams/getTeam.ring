/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getTeam
الوصف: الحصول على معلومات فريق محدد
*/
func getTeam
    try {
        # محاولة الحصول على المعرف من معلمات URL
        cTeamID = ""
        try {
            cTeamID = oServer.match(1)
            ? logger("getTeam function", "Using URL match parameter: " + cTeamID, :info)
        catch
            ? logger("getTeam function", "Error getting URL match parameter", :error)
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

            # تجميع معرفات الأعضاء
            aMemberIds = []
            for oMember in oCrew.getMembers() {
                add(aMemberIds, oMember.getID())
            }

            ? logger("getTeam function", "Team retrieved successfully", :info)
            # تحضير كائن JSON للاستجابة
            aResponse = [
                :status = "success",
                :team = [
                    :id = oCrew.getId(),
                    :index = nIndex,
                    :name = oCrew.getName(),
                    :objective = oCrew.getObjective(),
                    :leader_id = oCrew.getLeader().getID(),
                    :member_ids = aMemberIds,
                    :performance = oCrew.getPerformanceScore()
                ]
            ]

            # تحويل الكائن إلى JSON
            cJSON = list2json(aResponse)

            # تسجيل JSON للتصحيح
            ? logger("getTeam function", "JSON response: " + cJSON, :info)

            # إرسال الاستجابة
            oServer.setContent(cJSON, "application/json")
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("getTeam function", "Error retrieving team: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
