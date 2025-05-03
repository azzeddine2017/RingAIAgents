/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getTask
الوصف: الحصول على معلومات مهمة محددة
*/
func getTask
    try {
        # محاولة الحصول على المعرف من معلمات URL
        cTaskID = ""
        try {
            cTaskID = oServer.match(1)
            ? logger("getTask function", "Using URL match parameter: " + cTaskID, :info)
        catch
            ? logger("getTask function", "Error getting URL match parameter", :error)
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
            ? logger("getTask function", "Found task: " + oTask.cTitle, :info)

            # تجميع المهام الفرعية
            aSubtasks = []
            for oSubtask in oTask.aSubtasks {
                add(aSubtasks, [
                    :id = oSubtask.getID(),
                    :title = oSubtask.getTitle(),
                    :progress = oSubtask.getProgress()
                ])
            }

            ? logger("getTask function", "Task retrieved successfully", :info)

            # تحضير كائن JSON للاستجابة
            aResponse = [
                :status = "success",
                :task = [
                    :id = oTask.getId(),
                    :index = nIndex,
                    :title = oTask.getTitle(),
                    :description = oTask.getDescription(),
                    :start_time = oTask.getStartTime(),
                    :priority = oTask.getPriority(),
                    :progress = oTask.getProgress(),
                    :status = oTask.getStatus(),
                    :assigned_to = iif(oTask.getAssignedTo() != NULL, oTask.getAssignedTo().getID(), ""),
                    :subtasks = aSubtasks
                ]
            ]

            # تحويل الكائن إلى JSON
            cJSON = list2json(aResponse)

            # تسجيل JSON للتصحيح
            ? logger("getTask function", "JSON response: " + cJSON, :info)

            # إرسال الاستجابة
            oServer.setContent(cJSON, "application/json")
        else
            oServer.setContent('{"status":"error","message":"Task not found"}',
                              "application/json")
        }
    catch
        ? logger("getTask function", "Error retrieving task: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
