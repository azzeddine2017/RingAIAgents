/*
    RingAI Agents API - AI Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getAIModels
الوصف: الحصول على قائمة نماذج الذكاء الاصطناعي المتاحة
*/
func getAIModels
    try {
        aModels = oLLM.getAvailableModels()
        cJSON = '{"status":"success","models":['

        for x = 1 to len(aModels) {
            if x > 1 cJSON += "," ok
            cJSON += '"' + aModels[x] + '"'
        }

        cJSON += "]}"
        ? logger("getAIModels function", "AI models retrieved successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("getAIModels function", "Error retrieving AI models: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
