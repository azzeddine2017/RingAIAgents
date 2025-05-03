/*
    RingAI Agents API - User Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: login
الوصف: تسجيل دخول المستخدم
*/
func login
    try {
        cUsername = oServer["username"]
        cPassword = sha256(oServer["password"])

        for oUser in aUsers {
            if oUser.cUsername = cUsername and oUser.cPassword = cPassword {
                oSession = new Session {
                    nUserId = oUser.nId
                    cToken = sha256(string(random(999999)))
                }
                ? logger("login function", "User logged in successfully", :info)
                oServer.setContent('{"status":"success","token":"' + oSession.cToken + '"}',
                                 "application/json")
                return
            }
        }

        oServer.setContent('{"status":"error","message":"Invalid credentials"}',
                          "application/json")
    catch
        ? logger("login function", "Error logging in: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
