/*
    RingAI Agents API - Monitor Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getEvents
الوصف: الحصول على سجل الأحداث
*/
func getEvents
    try {
        nLimit = number(oServer["limit"])
        if nLimit = 0 nLimit = 10 ok

        aEvents = oMonitor.getRecentEvents(nLimit)
        cJSON = '{"status":"success","events":['

        for x = 1 to len(aEvents) {
            if x > 1 cJSON += "," ok
            cJSON += '{' +
                    '"timestamp":"' + aEvents[x].timestamp + '",' +
                    '"type":"' + aEvents[x].type + '",' +
                    '"description":"' + aEvents[x].description + '"}'
        }

        cJSON += "]}"
        ? logger("getEvents function", "Events retrieved successfully", :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("getEvents function", "Error retrieving events: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
