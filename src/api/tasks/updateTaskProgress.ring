/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: updateTaskProgress
الوصف: تحديث تقدم المهمة
*/
func updateTaskProgress
    try {
        nID = number(oServer.aParameters[1])
        if nID > 0 and nID <= len(aTasks) {
            oTask = aTasks[nID]

            # تحديث التقدم
            nProgress = number(oServer["progress"])
            if nProgress >= 0 and nProgress <= 100 {
                oTask.setProgress(nProgress)

                # تحديث الحالة تلقائياً
                if nProgress = 100
                    oTask.setStatus("Completed")
                elseif nProgress > 0
                    oTask.setStatus("In Progress")
                ok

                ? logger("updateTaskProgress function", "Progress updated successfully", :info)
                oServer.setContent('{"status":"success","message":"Progress updated successfully"}',
                                  "application/json")
            else
                oServer.setContent('{"status":"error","message":"Invalid progress value"}',
                                  "application/json")
            }
        else
            oServer.setContent('{"status":"error","message":"Task not found"}',
                              "application/json")
        }
    catch
        ? logger("updateTaskProgress function", "Error updating progress: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
