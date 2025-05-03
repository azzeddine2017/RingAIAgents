/* load "openssllib.ring"
load "jsonlib.ring" */

/*
Class: TokenManager
Description: مدير توكنات JWT
*/
class TokenManager {
    
    func init {
        oConfig = new SecurityConfig
        oBase64 = new Base64()
        oHmac = new Hmac()

        # تحديد مفتاح التوقيع
        cSigningKey = oConfig.cJWTSigningKey
        if cSigningKey = "" {
            cSigningKey = randbytes(32)
        }
        
        # تحديد مدة صلاحية التوكن (بالثواني)
        nTokenExpiry = oConfig.nJWTExpiry
        
        # تهيئة قائمة التوكنات الملغاة
        aRevokedTokens = []
    }
    
    # إنشاء توكن JWT
    func createToken cUserId, cUserRole, aCustomClaims {
        # إنشاء الرأس (Header)
        aHeader = [
            :alg = "HS256",
            :typ = "JWT"
        ]
        
        # إنشاء البيانات (Payload)
        aPayload = [
            :sub = cUserId,
            :role = cUserRole,
            :iat = timestamp(),
            :exp = timestamp() + nTokenExpiry
        ]
        
        # إضافة البيانات المخصصة
        if type(aCustomClaims) = "LIST" {
            for claim in aCustomClaims {
                aPayload[claim[1]] = claim[2]
            }
        }
        
        # تشفير الرأس والبيانات
        cEncodedHeader = this.oBase64.encode(list2json(aHeader))
        cEncodedPayload = this.oBase64.encode(list2json(aPayload))
        cEncodedSignature = this.oBase64.encode(this.oHmac.hmac_sha256(cEncodedHeader + "." + cEncodedPayload, cSigningKey))
        # إنشاء التوقيع
        cSignature = createSignature(cEncodedHeader + "." + cEncodedPayload)
        
        # إنشاء التوكن
        cToken = cEncodedHeader + "." + cEncodedPayload + "." + cEncodedSignature
        
        return cToken
    }
    
    # التحقق من صحة التوكن
    func validateToken cToken {
        if cToken = "" return false ok
        
        # تقسيم التوكن إلى أجزاء
        aTokenParts = split(cToken, ".")
        if len(aTokenParts) != 3 return false ok
        
        cEncodedHeader = aTokenParts[1]
        cEncodedPayload = aTokenParts[2]
        cSignature = aTokenParts[3]
        
        # التحقق من التوقيع
        cExpectedSignature = createSignature(cEncodedHeader + "." + cEncodedPayload)
        if cSignature != cExpectedSignature return false ok
        
        # فك تشفير البيانات
        cDecodedPayload = this.oBase64.decode(cEncodedPayload)
        aPayload = json2list(cDecodedPayload)
        
        # التحقق من انتهاء صلاحية التوكن
        if ComperTimeTemp(aPayload[:exp], "<", timestamp()) return false ok
        
        # التحقق من عدم إلغاء التوكن
        if isTokenRevoked(cToken) return false ok
        
        return aPayload
    }
    
    # إلغاء التوكن
    func revokeToken cToken {
        if not isTokenRevoked(cToken) {
            aRevokedTokens + cToken
            return true
        }
        return false
    }
    
    # التحقق من إلغاء التوكن
    func isTokenRevoked cToken {
        return find(aRevokedTokens, cToken) > 0
    }
    
    # تنظيف التوكنات منتهية الصلاحية
    func cleanExpiredTokens {
        for i = len(aRevokedTokens) to 1 step -1 {
            cToken = aRevokedTokens[i]
            
            # تقسيم التوكن إلى أجزاء
            aTokenParts = split(cToken, ".")
            if len(aTokenParts) != 3 {
                del(aRevokedTokens, i)
                loop
            }
            
            # فك تشفير البيانات
            cDecodedPayload = this.oBase64.decode(aTokenParts[2])
            aPayload = json2list(cDecodedPayload)
            
            # التحقق من انتهاء صلاحية التوكن
            if aPayload[:exp] < timestamp() {
                del(aRevokedTokens, i)
            }
        }
    }
    
    private
    
    oConfig
    cSigningKey
    nTokenExpiry
    aRevokedTokens
    oBase64
    oHmac
    # إنشاء التوقيع
    func createSignature cData {
        return this.oBase64.encode(this.oHmac.hmac_sha256(cData, cSigningKey))
    }
    
    # الحصول على الطابع الزمني الحالي
    func timestamp {
        aTimeList = timelist()
        cDate = aTimeList[6] + "/" + aTimeList[8] + "/" + aTimeList[19]  # MM/DD/YYYY
        cTime = padLeft(string(aTimeList[7]), "0", 2) + ":" +  # HH
                padLeft(string(aTimeList[11]), "0", 2) + ":" +  # MM
                padLeft(string(aTimeList[13]), "0", 2)  # SS
        return cDate + " " + cTime
    }

    # المقارنة بين الأوقات
    func ComperTimeTemp cTime1, operation, cTime2 {
        nSeconds1 = Time2Seconds(cTime1)
        nSeconds2 = Time2Seconds(cTime2)
        
        switch operation {
            on ">" return nSeconds1 > nSeconds2
            on "<" return nSeconds1 < nSeconds2
            on "=" return nSeconds1 = nSeconds2
            on ">=" return nSeconds1 >= nSeconds2
            on "<=" return nSeconds1 <= nSeconds2
            other return false
        }
    }

    # تحويل الوقت إلى ثواني
    func Time2Seconds cTime {
        try {
            if cTime = NULL return 0 ok
            
            # تقسيم التاريخ والوقت
            aDateTime = split(cTime, " ")
            if len(aDateTime) != 2 return 0 ok
            
            # تحويل التاريخ إلى يوم جوليان
            nJulianDate = gregorian2julian(aDateTime[1])
            
            # تحويل الوقت إلى ثواني
            aTime = split(aDateTime[2], ":")
            if len(aTime) != 3 return 0 ok
            
            nSeconds = number(aTime[1]) * 3600 +  # ساعات
                      number(aTime[2]) * 60 +     # دقائق
                      number(aTime[3])            # ثواني
            
            return (nJulianDate * 86400) + nSeconds
        catch
            return 0
        }
    }

    # دالة مساعدة لإضافة أصفار في بداية النص
    func padLeft cStr, cPadChar, nWidth {
        while len(cStr) < nWidth {
            cStr = cPadChar + cStr
        }
        return cStr
    }
}
