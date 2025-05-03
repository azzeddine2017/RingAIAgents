/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: removeTeamMember
الوصف: إزالة عضو من الفريق
*/
func removeTeamMember
    try {
        nTeamId = number(oServer.aParameters[1])
        nMemberId = number(oServer.aParameters[2])

        if nTeamId > 0 and nTeamId <= len(aTeams) {
            oCrew = aTeams[nTeamId]

            if nMemberId > 0 and nMemberId <= len(aAgents) {
                # إزالة العضو
                oCrew.removeMember(aAgents[nMemberId])

                ? logger("removeTeamMember function", "Member removed successfully", :info)
                oServer.setContent('{"status":"success","message":"Member removed successfully"}',
                                  "application/json")
            else
                oServer.setContent('{"status":"error","message":"Member not found"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("removeTeamMember function", "Error removing team member: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
