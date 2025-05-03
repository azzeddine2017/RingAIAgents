/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: listTasks
الوصف: الحصول على قائمة المهام
*/
func listTasks
    try {
        # تجميع قائمة المهام
        aTasksList = []
        
        for oTask in aTasks {
            # تجميع المهام الفرعية
            aSubtasks = []
            for oSubtask in oTask.aSubtasks {
                add(aSubtasks, [
                    :id = oSubtask.getID(),
                    :title = oSubtask.getTitle(),
                    :progress = oSubtask.getProgress()
                ])
            }
            
            # إضافة معلومات المهمة
            add(aTasksList, [
                :id = oTask.getId(),
                :title = oTask.getTitle(),
                :description = oTask.getDescription(),
                :start_time = oTask.getStartTime(),
                :priority = oTask.getPriority(),
                :progress = oTask.getProgress(),
                :status = oTask.getStatus(),
                :assigned_to = iif(oTask.getAssignedTo() != NULL, oTask.getAssignedTo().getID(), ""),
                :subtasks = aSubtasks
            ])
        }
        
        # تحضير كائن JSON للاستجابة
        aResponse = [
            :status = "success",
            :tasks = aTasksList
        ]
        
        # تحويل الكائن إلى JSON
        cJSON = list2json(aResponse)
        
        # تسجيل JSON للتصحيح
        ? logger("listTasks function", "JSON response: " + cJSON, :info)
        
        # إرسال الاستجابة
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("listTasks function", "Error retrieving tasks: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
