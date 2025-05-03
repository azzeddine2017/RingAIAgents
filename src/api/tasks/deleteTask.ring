/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: deleteTask
الوصف: حذف مهمة
*/
func deleteTask
    try {
        # محاولة الحصول على المعرف من معلمات URL
        cTaskID = ""
        try {
            cTaskID = oServer.match(1)
            ? logger("deleteTask function", "Using URL match parameter: " + cTaskID, :info)
        catch
            ? logger("deleteTask function", "Error getting URL match parameter", :error)
        }

        # التحقق من وجود معرف صالح
        if cTaskID = NULL or len(cTaskID) = 0 {
            oServer.setContent('{"status":"error","message":"No task ID provided"}', "application/json")
            return
        }

        # البحث عن المهمة بالمعرف
        oTask = NULL
        nIndex = 0

        for i = 1 to len(aTasks) {
            if aTasks[i].getId() = cTaskID {
                oTask = aTasks[i]
                nIndex = i
                exit
            }
        }

        if oTask != NULL {
            ? logger("deleteTask function", "Deleting task: " + oTask.getTitle(), :info)

            # حذف المهمة
            del(aTasks, nIndex)

            # حفظ التغييرات في قاعدة البيانات
            if saveTasks() {
                ? logger("deleteTask function", "Task deleted and database updated", :info)
                oServer.setContent('{"status":"success","message":"Task deleted successfully"}',
                                  "application/json")
            else
                ? logger("deleteTask function", "Task deleted but database not updated", :warning)
                oServer.setContent('{"status":"warning","message":"Task deleted but database not updated"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Task not found"}',
                              "application/json")
        }
    catch
        ? logger("deleteTask function", "Error deleting task: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
