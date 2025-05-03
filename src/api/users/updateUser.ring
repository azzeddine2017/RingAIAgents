/*
    RingAI Agents API - User Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: updateUser
الوصف: تحديث معلومات مستخدم
*/
func updateUser
    try {
        nId = number(oServer.getParam(1))
        if nId > 0 and nId <= len(aUsers) {
            oUser = aUsers[nId]

            if oServer["username"] != NULL
                oUser.cUsername = oServer["username"]
            ok
            if oServer["password"] != NULL
                oUser.cPassword = sha256(oServer["password"])
            ok
            if oServer["email"] != NULL
                oUser.cEmail = oServer["email"]
            ok
            if oServer["role"] != NULL
                oUser.cRole = oServer["role"]
            ok

            ? logger("updateUser function", "User updated successfully", :info)
            oServer.setContent('{"status":"success","message":"User updated successfully"}',
                             "application/json")
        else
            oServer.setContent('{"status":"error","message":"User not found"}',
                             "application/json")
        }
    catch
        ? logger("updateUser function", "Error updating user: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
