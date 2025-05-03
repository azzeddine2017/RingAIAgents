/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: listTeams
الوصف: الحصول على قائمة الفرق
*/
func listTeams
    try {
        ? logger("listTeams function", "listTeams function called", :info)
        ? logger("listTeams function", "Number of teams: " + len(aTeams), :info)

        aTeamsList = []

        # تجميع معلومات الفرق من المتغير العام aTeams
        for i = 1 to len(aTeams) {
            oCrew = aTeams[i]

            # تجميع المعلومات الأساسية
            aTeamInfo = [
                :id = i,
                :name = oCrew.getName(),
                :objective = oCrew.getObjective()
            ]

            ? logger("listTeams function", "Team " + i + ": " + oCrew.getName(), :info)
            add(aTeamsList, aTeamInfo)
        }

        # إذا لم يكن هناك فرق، إنشاء فرق افتراضية
        if len(aTeamsList) = 0 and len(aAgents) > 0 {
            ? logger("listTeams function", "No teams found, creating default teams", :info)

            # إنشاء فريق التطوير
            oDevTeam = new Crew("Development Team", "Build software")

            # تعيين قائد الفريق (العميل الأول)
            oDevTeam.setLeader(aAgents[1])

            # إضافة أعضاء الفريق
            for i = 2 to len(aAgents) {
                oDevTeam.addMember(aAgents[i])
            }

            # إضافة الفريق إلى القائمة العامة
            add(aTeams, oDevTeam)

            # إضافة الفريق إلى قائمة الاستجابة
            add(aTeamsList, [
                :id = 1,
                :name = oDevTeam.getName(),
                :objective = oDevTeam.getObjective()
            ])

            # إنشاء فريق الدعم
            oSupportTeam = new Crew("Support Team", "Help users")

            # تعيين قائد الفريق (العميل الأول)
            if len(aAgents) >= 1 {
                oSupportTeam.setLeader(aAgents[1])
            }

            # إضافة الفريق إلى القائمة العامة
            add(aTeams, oSupportTeam)

            # إضافة الفريق إلى قائمة الاستجابة
            add(aTeamsList, [
                :id = 2,
                :name = oSupportTeam.getName(),
                :objective = oSupportTeam.getObjective()
            ])
        }

        # تحويل القائمة إلى JSON
        cJSON = '{"teams":' + list2json(aTeamsList) + '}'

        ? logger("listTeams function", "Teams list retrieved successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("listTeams function", "Error retrieving teams list: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
