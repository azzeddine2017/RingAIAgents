/*
    RingAI Agents API - User Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: getUser
الوصف: الحصول على معلومات مستخدم
*/
func getUser
    try {
        nId = number(oServer.getParam(1))
        if nId > 0 and nId <= len(aUsers) {
            oUser = aUsers[nId]
            ? logger("getUser function", "User retrieved successfully", :info)
            oServer.setContent('{"status":"success","user":{' +
                '"username":"' + oUser.cUsername + '",' +
                '"email":"' + oUser.cEmail + '",' +
                '"role":"' + oUser.cRole + '"}}',
                "application/json")
        else
            oServer.setContent('{"status":"error","message":"User not found"}',
                             "application/json")
        }
    catch
        ? logger("getUser function", "Error retrieving user: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
