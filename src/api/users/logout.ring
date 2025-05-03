/*
    RingAI Agents API - User Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: logout
الوصف: تسجيل خروج المستخدم
*/
func logout
    try {
        cToken = oServer["token"]
        if oSession = findSession(cToken) {
            removeSession(oSession)
            ? logger("logout function", "User logged out successfully", :info)
            oServer.setContent('{"status":"success","message":"Logged out successfully"}',
                             "application/json")
        else
            oServer.setContent('{"status":"error","message":"Invalid session"}',
                             "application/json")
        }
    catch
        ? logger("logout function", "Error logging out: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
