/*
    RingAI Agents API - Agent Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: deleteAgent
الوصف: حذف عميل
*/
func deleteAgent
    try {
        # التحقق من وجود معرف في المعلمات
        cAgentID = ""

        # طباعة معلومات الطلب للتصحيح
        ? "Request method: " + oServer.getRequestMethod()

        # محاولة الحصول على المعرف من معلمات URL
        try {
            cAgentID = oServer.match(1)
            ? logger("deleteAgent function", "Using URL match parameter: " + cAgentID, :info)
        catch
            ? logger("deleteAgent function", "Error getting URL match parameter", :error)
        }

        # إذا كان المعرف فارغًا، حاول الحصول عليه من معلمات الاستعلام
        if cAgentID = NULL or len(cAgentID) = 0 {
            try {
                cAgentID = oServer.variable("agent_id")
                if cAgentID != NULL and len(cAgentID) > 0 {
                    ? logger("deleteAgent function", "Using variable agent_id: " + cAgentID, :info)
                }
            catch
                ? logger("deleteAgent function", "Error getting variable", :error)
            }
        }

        # إذا كان المعرف لا يزال فارغًا، أرجع خطأ
        if cAgentID = NULL or len(cAgentID) = 0 {
            ? logger("deleteAgent function", "No agent_id found in any parameter", :error)
            oServer.setContent('{"status":"error","message":"No agent ID provided"}', "application/json")
            return
        }

        # التحقق من وجود معرف صالح
        if cAgentID = NULL or len(cAgentID) = 0 {
            oServer.setContent('{"status":"error","message":"Empty agent ID provided"}', "application/json")
            return
        }

        ? logger("deleteAgent function", "Deleting agent with ID: " + cAgentID, :info)

        # البحث عن العميل بالمعرف
        nIndex = 0
        oAgentToDelete = NULL

        # تحويل المعرف إلى نص للمقارنة
        cAgentID = string(cAgentID)

        for i = 1 to len(aAgents) {
            cCurrentID = string(aAgents[i].getID())

            if cCurrentID = cAgentID {
                nIndex = i
                oAgentToDelete = aAgents[i]
                ? logger("deleteAgent function", "Found agent for deletion: " + oAgentToDelete.getName(), :info)
                exit
            }
        }

        if isObject(oAgentToDelete) {
            # إزالة العميل من المراقب
            try {
                if isObject(oMonitor) {
                    oMonitor.unregisterAgent(oAgentToDelete)
                }
            catch
                # تجاهل الأخطاء
            }

            # حذف العميل
            del(aAgents, nIndex)

            # حفظ العملاء في قاعدة البيانات
            saveAgents()

            ? logger("deleteAgent function", "Agent deleted successfully", :info)
            oServer.setContent('{"status":"success","message":"Agent deleted successfully"}',
                              "application/json")
        else
            oServer.setContent('{"status":"error","message":"Agent not found with ID: ' + cAgentID + '"}',
                              "application/json")
        }
    catch
        ? logger("deleteAgent function", "Error deleting agent: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
