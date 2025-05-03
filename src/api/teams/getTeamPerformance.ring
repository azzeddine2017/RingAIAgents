/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getTeamPerformance
الوصف: الحصول على تقرير أداء الفريق
*/
func getTeamPerformance
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aTeams) {
            oCrew = aTeams[nID]

            # جمع إحصائيات الأداء
            aStats = oCrew.getPerformanceStats()

            ? logger("getTeamPerformance function", "Team performance retrieved successfully", :info)
            oServer.setContent('{
                "team_id": ' + nID + ',
                "overall_score": ' + oCrew.getPerformanceScore() + ',
                "completed_tasks": ' + aStats[:completed_tasks] + ',
                "ongoing_tasks": ' + aStats[:ongoing_tasks] + ',
                "success_rate": ' + aStats[:success_rate] + ',
                "efficiency": ' + aStats[:efficiency] + ',
                "member_stats": ' + map2json(aStats[:member_stats]) + '
            }', "application/json")
        else
            oServer.setContent('{"status":"error","message":"Team not found"}',
                              "application/json")
        }
    catch
        ? logger("getTeamPerformance function", "Error retrieving team performance: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
