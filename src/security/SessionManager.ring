load "openssllib.ring"
load "jsonlib.ring"
load "G:/RingAIAgents/src/security/EncryptionManager.ring"
//load "G:/RingAIAgents/src/utils/helpers.ring"
/*
Class: SessionManager
Description: مدير جلسات المستخدمين
*/
class SessionManager {
     oConfig
    oEncryption
    cSessionKey
    cSessionIV
    aActiveSessions
    nSessionExpiry
    oBase64
    func init {
        oConfig = new SecurityConfig
        oEncryption = new EncryptionManager()
        oBase64 = new Base64()
        # توليد مفتاح التشفير وvector التهيئة
        cSessionKey = this.oEncryption.generateKey(32)
        cSessionIV = this.oEncryption.generateIV(16)
        
        # تهيئة مخزن الجلسات
        aActiveSessions = []
        
        # تحديد مدة صلاحية الجلسة (بالثواني)
        nSessionExpiry = oConfig.nSessionExpiry
        
    }
    
    # إنشاء جلسة جديدة
    func createSession(cUserId, cUserRole, cUserIP) {
        try {
            # توليد معرف فريد للجلسة
            cSessionId = generateSessionId()
            
            # الحصول على الوقت الحالي بالتنسيق الصحيح
            aTimeList = timelist()
            cCurrentDateTime = aTimeList[6] + "/" + aTimeList[8] + "/" + aTimeList[19] + " " +
                             padLeft(string(aTimeList[7]), "0", 2) + ":" +
                             padLeft(string(aTimeList[11]), "0", 2) + ":" +
                             padLeft(string(aTimeList[13]), "0", 2)
            
            # إنشاء بيانات الجلسة كقائمة ترابطية
            aSessionData = [
                :user_id = cUserId,
                :role = cUserRole,
                :ip = cUserIP,
                :created_at = cCurrentDateTime,
                :expires_at = calculateExpiry(),
                :last_activity = cCurrentDateTime
            ]
            
            # تحويل البيانات إلى JSON
            cJsonData = list2json(aSessionData)
            
            # تشفير البيانات
            cEncryptedData = this.oEncryption.encrypte(cJsonData, cSessionKey, cSessionIV)
            
            # تخزين الجلسة
            add(aActiveSessions, [cSessionId, cEncryptedData])
            
            # إنشاء توكن الجلسة
            cSessionToken = cSessionId + "." + oBase64.encode(cEncryptedData)
            
            return cSessionToken
        catch
            ? "خطأ في إنشاء الجلسة: " + cCatchError
            return ""
        }
    }
    
    # التحقق من صحة الجلسة
    func validateSession cSessionToken {
        try {
            if cSessionToken = "" return false ok
            
            # تقسيم التوكن إلى معرف وبيانات
            aTokenParts = split(cSessionToken, ".")
            if len(aTokenParts) != 2 return false ok
            
            cSessionId = aTokenParts[1]
            cEncryptedData = oBase64.decode(aTokenParts[2])
            
            # البحث عن الجلسة
            for session in aActiveSessions {
                if session[1] = cSessionId {
                    # فك تشفير بيانات الجلسة
                    cDecryptedData = this.oEncryption.decrypte(cEncryptedData, cSessionKey, cSessionIV)
                    
                    # تحويل البيانات من JSON إلى قائمة
                    aSessionData = json2list(cDecryptedData)
                    
                    # التحقق من انتهاء صلاحية الجلسة
                    if isSessionExpired(aSessionData[:expires_at]) {
                        destroySession(cSessionId)
                        return false
                    }
                    
                    # تحديث وقت آخر نشاط
                    updateSessionActivity(cSessionId)
                    
                    return aSessionData
                }
            }
            
            return false
        catch
            ? "خطأ في التحقق من صحة الجلسة: " + cCatchError
            return false
        }
    }
    
    # تدمير الجلسة
    func destroySession cSessionId {
        for i = 1 to len(aActiveSessions) {
            if aActiveSessions[i][1] = cSessionId {
                del(aActiveSessions, i)
                return true
            }
        }
        return false
    }
    
    # تنظيف الجلسات منتهية الصلاحية
    func cleanExpiredSessions {
        for i = len(aActiveSessions) to 1 step -1 {
            cSessionId = aActiveSessions[i][1]
            cEncryptedData = aActiveSessions[i][2]
            
            # فك تشفير بيانات الجلسة
            cDecryptedData = this.oEncryption.decrypte(cEncryptedData, cSessionKey, cSessionIV)
            aSessionData = json2list(cDecryptedData)
            
            # التحقق من انتهاء صلاحية الجلسة
            if isSessionExpired(aSessionData[:expires_at]) {
                del(aActiveSessions, i)
            }
        }
    }
    
    # حساب وقت انتهاء صلاحية الجلسة
    func calculateExpiry {
        # الحصول على التاريخ والوقت الحالي
        aTimeList = timelist()
        
        # تحويل التاريخ إلى التنسيق الكامل (MM/DD/YYYY)
        cYear = aTimeList[19]  # Full year (YYYY)
        cMonth = aTimeList[6]  # Month (MM)
        cDay = aTimeList[8]    # Day (DD)
        cCurrentDate = cMonth + "/" + cDay + "/" + cYear
        
        # الحصول على الوقت الحالي
        nCurrentHours = number(aTimeList[7])      # Hours
        nCurrentMinutes = number(aTimeList[11])   # Minutes
        nCurrentSeconds = number(aTimeList[13])   # Seconds
        
        # حساب إجمالي الثواني
        nTotalSeconds = nCurrentHours * 3600 + nCurrentMinutes * 60 + nCurrentSeconds + nSessionExpiry
        
        # تحويل الثواني إلى ساعات ودقائق وثواني
        nHours = floor(nTotalSeconds / 3600)
        nMinutes = floor((nTotalSeconds % 3600) / 60)
        nSeconds = nTotalSeconds % 60
        
        # معالجة تغيير اليوم إذا تجاوزت الساعات 24
        nDaysToAdd = floor(nHours / 24)
        nHours = nHours % 24
        
        # تنسيق الوقت
        cExpiryTime = padLeft(string(nHours), "0", 2) + ":" + 
                  padLeft(string(nMinutes), "0", 2) + ":" + 
                  padLeft(string(nSeconds), "0", 2)
        
        # إضافة الأيام إلى التاريخ إذا لزم الأمر
        if nDaysToAdd > 0 {
            # تحويل التاريخ الحالي إلى يوم جوليان
            nJulianDate = gregorian2julian(cCurrentDate)
            # إضافة الأيام
            nNewJulianDate = nJulianDate + nDaysToAdd
            # تحويل التاريخ الجديد إلى تاريخ ميلادي
            cNewDate = julian2gregorian(nNewJulianDate)
            return cNewDate + " " + cExpiryTime
        }
        
        return cCurrentDate + " " + cExpiryTime
    }
    
    # التحقق من انتهاء صلاحية الجلسة
    func isSessionExpired cExpiry {
        cCurrentDateTime = date() + " " + time()
        nDiff = timeDiff(cExpiry, cCurrentDateTime)
        return nDiff <= 0
    }
    
    private
    
    # توليد معرف فريد للجلسة
    func generateSessionId {
        cRandom = randbytes (32)
        cTimestamp = timelist()[5]
        return sha256(cRandom + cTimestamp)
    }
    
    # تحديث وقت آخر نشاط للجلسة
    func updateSessionActivity cSessionId {
        try {
            for i = 1 to len(aActiveSessions) {
                if aActiveSessions[i][1] = cSessionId {
                    # فك تشفير بيانات الجلسة
                    cEncryptedData = aActiveSessions[i][2]
                    cDecryptedData = this.oEncryption.decrypte(cEncryptedData, cSessionKey, cSessionIV)
                    aSessionData = json2list(cDecryptedData)
                    
                    # تحديث وقت آخر نشاط
                    aTimeList = timelist()
                    cCurrentDateTime = aTimeList[6] + "/" + aTimeList[8] + "/" + aTimeList[19] + " " +
                                    padLeft(string(aTimeList[7]), "0", 2) + ":" +
                                    padLeft(string(aTimeList[11]), "0", 2) + ":" +
                                    padLeft(string(aTimeList[13]), "0", 2)
                    
                    aSessionData[:last_activity] = cCurrentDateTime
                    
                    # إعادة تشفير البيانات
                    cEncryptedData = this.oEncryption.encrypte(list2json(aSessionData), cSessionKey, cSessionIV)
                    aActiveSessions[i][2] = cEncryptedData
                    
                    return true
                }
            }
            return false
        catch
            ? "خطأ في تحديث نشاط الجلسة: " + cCatchError
            return false
        }
    }
    
    # دالة مساعدة لإضافة أصفار في بداية النص
    func padLeft cStr, cPadChar, nWidth {
        while len(cStr) < nWidth {
            cStr = cPadChar + cStr
        }
        return cStr
    }
    
    # تحويل يوم جوليان إلى تاريخ ميلادي
    func julian2gregorian nJulian {
        nJulian = floor(nJulian + 0.5)
        
        nA = floor((nJulian - 1867216.25) / 36524.25)
        nB = nJulian + 1 + nA - floor(nA / 4)
        nC = nB + 1524
        nD = floor((nC - 122.1) / 365.25)
        nE = floor(365.25 * nD)
        nF = floor((nC - nE) / 30.6001)
        
        nDay = nC - nE - floor(30.6001 * nF)
        nMonth = nF - 1
        if nMonth > 12 {
            nMonth = nMonth - 12
        }
        nYear = nD - 4715
        if nMonth > 2 {
            nYear--
        }
        
        # تنسيق التاريخ بالشكل MM/DD/YYYY
        return padLeft(string(nMonth), "0", 2) + "/" + 
               padLeft(string(nDay), "0", 2) + "/" + 
               string(nYear)
    }
}
