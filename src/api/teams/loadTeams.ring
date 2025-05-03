/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: loadTeams
الوصف: تحميل الفرق المتاحة
*/
func loadTeams
    try {
        # مسح قائمة الفرق الحالية
        aTeams = []

        # تحديد مسار قاعدة البيانات
        cDBPath = "G:/RingAIAgents/db/teams.db"

        # التحقق من وجود قاعدة بيانات للفرق
        if fexists(cDBPath) {
            ? logger("loadTeams function", "Loading teams from database: " + cDBPath, :info)
            # فتح قاعدة البيانات
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # استرجاع الفرق
            cSQL = "SELECT * FROM teams"
            aResults = sqlite_execute(oDatabase, cSQL)

            # تسجيل نتائج الاستعلام
            ? logger("loadTeams function", "SQL query executed: " + cSQL, :info)
            ? logger("loadTeams function", "Number of teams found: " + iif(type(aResults) = "LIST", len(aResults), 0), :info)

            # معالجة النتائج
            if type(aResults) = "LIST" and len(aResults) > 0 {
                # تسجيل تفاصيل كل فريق
                for nTeamIndex = 1 to len(aResults) {
                    aResult = aResults[nTeamIndex]
                    ? logger("loadTeams function", "Processing team " + nTeamIndex + " of " + len(aResults) + ": " + aResult[:name], :info)
                    # البحث عن القائد
                    oLeader = NULL
                    ? logger("loadTeams function", "Looking for leader with ID: " + aResult[:leader_id], :info)
                    for i = 1 to len(aAgents) {
                        if isObject(aAgents[i]) and methodExists(aAgents[i], "getId") {
                            if aAgents[i].getId() = aResult[:leader_id] {
                                oLeader = aAgents[i]
                                ? logger("loadTeams function", "Found leader: " + aAgents[i].getName(), :info)
                                exit
                            }
                        }
                    }

                    # إذا لم يتم العثور على القائد، استخدم العميل الأول
                    if oLeader = NULL and len(aAgents) > 0 {
                        oLeader = aAgents[1]
                    }

                    # إنشاء فريق جديد
                    if oLeader != NULL {
                        oCrew = new Crew(aResult[:name], oLeader)

                        # تعيين المعرف والهدف
                        oCrew.setId(aResult[:id])

                        # تسجيل الهدف للتصحيح
                        ? logger("loadTeams function", "Loading objective for team " + aResult[:id] + ": " + aResult[:objective], :info)

                        # تعيين الهدف
                        oCrew.setObjective(aResult[:objective])

                        # إضافة الأعضاء
                        try {
                            cMembersStr = aResult[:members]
                            ? logger("loadTeams function", "Members string: " + cMembersStr, :info)

                            # تنظيف سلسلة الأعضاء وتحويلها إلى تنسيق JSON صحيح
                            cMembersStr = trim(cMembersStr)
                            if left(cMembersStr, 1) != "[" {
                                cMembersStr = "[" + cMembersStr + "]"
                            }

                            # محاولة تحليل JSON
                            ? logger("loadTeams function", "Cleaned members JSON: " + cMembersStr, :info)
                            aMemberIds = JSON2List(cMembersStr)

                            if isList(aMemberIds) {
                                ? logger("loadTeams function", "Number of members: " + len(aMemberIds), :info)

                                for cMemberId in aMemberIds {
                                    # تجنب إضافة القائد مرة أخرى
                                    if cMemberId = oLeader.getId() {
                                        ? logger("loadTeams function", "Skipping leader: " + cMemberId, :info)
                                        loop
                                    }

                                    # البحث عن العضو وإضافته
                                    for i = 1 to len(aAgents) {
                                        if aAgents[i].getId() = cMemberId {
                                            ? logger("loadTeams function", "Adding member: " + aAgents[i].getName() + " with ID: " + cMemberId, :info)
                                            oCrew.addMember(aAgents[i])
                                            exit
                                        }
                                    }
                                }
                            else
                                ? logger("loadTeams function", "Members list is not valid", :error)
                            }
                        catch
                            ? logger("loadTeams function", "Error parsing members: " + cCatchError, :error)
                        }

                        # إضافة الفريق إلى القائمة
                        add(aTeams, oCrew)

                        # تسجيل الفريق في المراقب
                        try {
                            oMonitor.registerCrew(oCrew)
                        catch
                            ? logger("loadTeams function", "Error registering crew with monitor: " + cCatchError, :error)
                        }
                    }
                }
            }

            # إغلاق قاعدة البيانات
            sqlite_close(oDatabase)
        }

        # إذا لم يتم تحميل أي فرق، إنشاء فرق افتراضية
        if len(aTeams) = 0 and len(aAgents) > 0 {
            ? logger("loadTeams function", "No teams loaded, creating default teams", :info)

            # إنشاء فريق التطوير
            oDevTeam = new Crew("Development Team", aAgents[1])
            oDevTeam.setObjective("Build software")

            # إضافة أعضاء الفريق
            for i = 2 to min(len(aAgents), 4) {
                oDevTeam.addMember(aAgents[i])
            }

            # إضافة الفريق إلى القائمة العامة
            add(aTeams, oDevTeam)

            # تسجيل الفريق في المراقب
            try {
                oMonitor.registerCrew(oDevTeam)
            catch
                ? logger("loadTeams function", "Error registering dev team with monitor: " + cCatchError, :error)
            }

            # إنشاء فريق الدعم إذا كان هناك عملاء كافيين
            if len(aAgents) >= 5 {
                oSupportTeam = new Crew("Support Team", aAgents[5])
                oSupportTeam.setObjective("Help users")

                # إضافة أعضاء الفريق
                for i = 6 to min(len(aAgents), 8) {
                    oSupportTeam.addMember(aAgents[i])
                }

                # إضافة الفريق إلى القائمة العامة
                add(aTeams, oSupportTeam)

                # تسجيل الفريق في المراقب
                try {
                    oMonitor.registerCrew(oSupportTeam)
                catch
                    ? logger("loadTeams function", "Error registering support team with monitor: " + cCatchError, :error)
                }
            }

            # حفظ الفرق الافتراضية
            saveTeams()
        }

        ? logger("loadTeams function", "Teams loaded successfully: " + len(aTeams), :info)
        return true
    catch
        ? logger("loadTeams function", "Error loading teams: " + cCatchError, :error)
        return false
    }
