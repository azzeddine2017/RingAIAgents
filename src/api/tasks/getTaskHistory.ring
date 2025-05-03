/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getTaskHistory
الوصف: الحصول على سجل المهمة
*/
func getTaskHistory
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aTasks) {
            oTask = aTasks[nID]

            # استرجاع السجل من الذاكرة
            aHistory = oMemory.retrieve(
                "task_" + nID,
                Memory.LONG_TERM,
                ["task", "history"]
            )

            ? logger("getTaskHistory function", "Task history retrieved successfully", :info)
            oServer.setContent('{
                "task_id": ' + nID + ',
                "history": ' + list2json(aHistory) + '
            }', "application/json")
        else
            oServer.setContent('{"status":"error","message":"Task not found"}',
                              "application/json")
        }
    catch
        ? logger("getTaskHistory function", "Error retrieving task history: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
