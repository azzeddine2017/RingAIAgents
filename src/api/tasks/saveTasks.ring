/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: saveTasks
الوصف: حفظ المهام في قاعدة البيانات
*/
func saveTasks
    try {
        # التحقق من وجود مهام
        if len(aTasks) = 0 {
            return false
        }

        # تحديد مسار قاعدة البيانات
        cDBPath = "G:\RingAIAgents\db\tasks.db"

        # إنشاء قاعدة بيانات للمهام إذا لم تكن موجودة
        if !fexists(cDBPath) {
            ? logger("saveTasks function", "Creating new database at: " + cDBPath, :info)
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # إنشاء جدول المهام
            cSQL = "CREATE TABLE IF NOT EXISTS tasks (
                    id TEXT PRIMARY KEY,
                    title TEXT,
                    description TEXT,
                    status TEXT,
                    priority INTEGER,
                    assigned_to TEXT,
                    start_time TEXT,
                    due_time TEXT,
                    context TEXT,
                    progress INTEGER,
                    subtasks TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # إغلاق قاعدة البيانات
            sqlite_close(oDatabase)
        }

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # حفظ المهام الحالية - استخدام REPLACE INTO بدلاً من حذف ثم إضافة
        ? logger("saveTasks function", "Saving " + len(aTasks) + " tasks to database", :info)
        for i = 1 to len(aTasks) {
            oTask = aTasks[i]

            # تجميع المهام الفرعية
            aSubtasks = []
            for oSubtask in oTask.getSubtasks() {
                add(aSubtasks, [
                    :id = oSubtask.getId(),
                    :description = oSubtask.getDescription(),
                    :status = oSubtask.getStatus()
                ])
            }

            # تحويل المهام الفرعية إلى JSON
            cSubtasks = list2json(aSubtasks)

            # تنظيف النصوص من علامات الاقتباس المزدوجة
            cTitle = substr(oTask.getTitle(), '"', '""')
            cDescription = substr(oTask.getDescription(), '"', '""')
            cContext = substr(oTask.getContext(), '"', '""')

            # الحصول على معرف العميل المسند إليه المهمة
            cAssignedTo = ""
            if oTask.getAssignedTo() != NULL {
                cAssignedTo = oTask.getAssignedTo().getID()
            }

            # تسجيل البيانات للتصحيح
            ? logger("saveTasks function", "Saving task: " + oTask.getId(), :info)
            ? logger("saveTasks function", "Title: " + cTitle, :info)
            ? logger("saveTasks function", "Status: " + oTask.getStatus(), :info)

            # إضافة المهمة إلى قاعدة البيانات أو تحديثها إذا كانت موجودة
            cSQL = "REPLACE INTO tasks (id, title, description, status, priority, assigned_to, start_time, due_time, context, progress, subtasks) VALUES (
                    '" + oTask.getId() + "',
                    '" + cTitle + "',
                    '" + cDescription + "',
                    '" + oTask.getStatus() + "',
                    " + oTask.getPriority() + ",
                    '" + cAssignedTo + "',
                    '" + oTask.getStartTime() + "',
                    '" + oTask.getDueTime() + "',
                    '" + cContext + "',
                    " + oTask.getProgress() + ",
                    '" + cSubtasks + "'
                )"
            sqlite_execute(oDatabase, cSQL)
        }

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        ? logger("saveTasks function", "Tasks saved successfully", :info)
        return true
    catch
        ? logger("saveTasks function", "Error saving tasks: " + cCatchError, :error)
        return false
    }
