/*
    RingAI Agents API - Team Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: saveTeams
الوصف: حفظ الفرق في قاعدة البيانات
*/
func saveTeams
    try {
        # التحقق من وجود فرق
        if len(aTeams) = 0 {
            return false
        }

        # تحديد مسار قاعدة البيانات
        cDBPath = "G:\RingAIAgents\db\teams.db"

        # إنشاء قاعدة بيانات للفرق إذا لم تكن موجودة
        if !fexists(cDBPath) {
            ? logger("saveTeams function", "Creating new database at: " + cDBPath, :info)
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # إنشاء جدول الفرق
            cSQL = "CREATE TABLE IF NOT EXISTS teams (
                    id TEXT PRIMARY KEY,
                    name TEXT,
                    objective TEXT,
                    leader_id TEXT,
                    members TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # إغلاق قاعدة البيانات
            sqlite_close(oDatabase)
        }

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # حفظ الفرق الحالية - استخدام REPLACE INTO بدلاً من حذف ثم إضافة
        ? logger("saveTeams function", "Saving " + len(aTeams) + " teams to database", :info)
        for i = 1 to len(aTeams) {
            oCrew = aTeams[i]

            # تجميع معرفات الأعضاء
            aMemberIds = []
            for oMember in oCrew.getMembers() {
                add(aMemberIds, oMember.getID())
            }

            # تحويل معرفات الأعضاء إلى JSON
            cMembers = list2json(aMemberIds)

            # تنظيف النصوص من علامات الاقتباس المزدوجة
            cName = substr(oCrew.getName(), '"', '""')
            cObjective = substr(oCrew.getObjective(), '"', '""')

            # تسجيل البيانات للتصحيح
            ? logger("saveTeams function", "Saving team: " + oCrew.getId(), :info)
            ? logger("saveTeams function", "Name: " + cName, :info)
            ? logger("saveTeams function", "Objective: " + cObjective, :info)

            # إضافة الفريق إلى قاعدة البيانات أو تحديثه إذا كان موجودًا
            cSQL = "REPLACE INTO teams (id, name, objective, leader_id, members) VALUES (
                    '" + oCrew.getId() + "',
                    '" + cName + "',
                    '" + cObjective + "',
                    '" + oCrew.getLeader().getID() + "',
                    '" + cMembers + "'
                )"
            sqlite_execute(oDatabase, cSQL)
        }

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        ? logger("saveTeams function", "Teams saved successfully", :info)
        return true
    catch
        ? logger("saveTeams function", "Error saving teams: " + cCatchError, :error)
        return false
    }
