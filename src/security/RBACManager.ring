/*
Class: RBACManager
Description: مدير التحكم في الوصول المستند إلى الأدوار
*/
class RBACManager {
    

    func init {
        oConfig = new SecurityConfig
        loadRoles()
    }

    # تحميل الأدوار من التكوين
    func loadRoles {
        for role in oConfig.aRoles {
            addRole(role[1], role[2][:permissions], role[2][:level])
        }
    }

    # إضافة دور جديد
    func addRole cRole, aPermissions, nLevel {
        aUserRoles + [cRole, nLevel]
        aRolePermissions + [cRole, aPermissions]
    }

    # إضافة صلاحية لدور
    func addPermissionToRole cRole, cPermission {
        for i = 1 to len(aRolePermissions) {
            if aRolePermissions[i][1] = cRole {
                aRolePermissions[i][2] + cPermission
                return true
            }
        }
        return false
    }

    # التحقق من صلاحية المستخدم
    func checkPermission cUser, cPermission {
        cRole = getUserRole(cUser)
        if cRole = "" return false ok
        
        for role in aRolePermissions {
            if role[1] = cRole {
                return find(role[2], cPermission) > 0
            }
        }
        return false
    }

    # الحصول على مستوى صلاحية المستخدم
    func getUserLevel cUser {
        cRole = getUserRole(cUser)
        for role in aUserRoles {
            if role[1] = cRole {
                return role[2]
            }
        }
        return 0
    }

    private
    
    oConfig
    aUserRoles = []
    aRolePermissions = []

    # الحصول على دور المستخدم
    func getUserRole cUser {
        # يجب تنفيذ الاتصال بقاعدة البيانات
            
        return "user"  # مؤقتاً
    }
    
}

/*
Class: Permission
Description: كائن الصلاحية
*/
class Permission {
    cName
    cDescription
    cResource
    cAction

    func init cN, cD, cR, cA {
        cName = cN
        cDescription = cD
        cResource = cR
        cAction = cA
    }

    func toString {
        return cName + ":" + cResource + ":" + cAction
    }
}

/*
Class: Role
Description: كائن الدور
*/
class Role {
    cName
    cDescription
    nLevel
    aPermissions

    func init cN, cD, nL {
        cName = cN
        cDescription = cD
        nLevel = nL
        aPermissions = []
    }

    func addPermission oPermission {
        aPermissions + oPermission
    }

    func hasPermission cPermission {
        for perm in aPermissions {
            if perm.toString() = cPermission {
                return true
            }
        }
        return false
    }
}
