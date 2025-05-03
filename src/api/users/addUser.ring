/*
    RingAI Agents API - User Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: addUser
الوصف: إضافة مستخدم جديد
*/
func addUser
    try {
        oUser = new User {
            cUsername = oServer["username"]
            cPassword = sha256(oServer["password"])
            cEmail = oServer["email"]
            cRole = oServer["role"]
        }
        ? logger("addUser function", "User created successfully", :info)
        add(aUsers, oUser)

        oServer.setContent('{"status":"success","message":"User created successfully","id":' +
                          len(aUsers) + '}', "application/json")
    catch
        ? logger("addUser function", "Error creating user: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }
