/*
    RingAI Agents API - Monitor Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getPerformance
الوصف: الحصول على بيانات الأداء
*/
func getPerformance
    try {
        aMetrics = oMonitor.getAllMetrics()
        cJSON = '{"status":"success","metrics":{'

        for x = 1 to len(aMetrics) {
            if x > 1 cJSON += "," ok
            cJSON += '"' + aMetrics[x][1] + '":"' + aMetrics[x][2] + '"'
        }

        cJSON += "}}"
        ? logger("getPerformance function", "Performance metrics retrieved successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("getPerformance function", "Error retrieving performance metrics: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
