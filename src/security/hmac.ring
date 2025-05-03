//load "openssllib.ring"

/*
Class: HMAC
Description: توفير وظائف HMAC للتحقق من سلامة البيانات
*/
class HMAC {
    
    func init {
        # لا شيء للتهيئة
    }
    
    # حساب HMAC-SHA256
    func hmac_sha256 cData, cKey {
        # تحضير المفتاح
        if len(cKey) > 64 {
            cKey = sha256(cKey)
        }
        
        if len(cKey) < 64 {
            cKey = cKey + copy(char(0), 64 - len(cKey))
        }
        
        # حساب المفاتيح الداخلية والخارجية
        cInnerKey = ""
        cOuterKey = ""
        
        for i = 1 to 64 {
            cInnerKey += char(ascii(cKey[i]) ^ 0x36)
            cOuterKey += char(ascii(cKey[i]) ^ 0x5C)
        }
        
        # حساب HMAC
        cInnerHash = sha256(cInnerKey + cData)
        cOuterHash = sha256(cOuterKey + cInnerHash)
        
        return cOuterHash
    }
    
    # حساب HMAC-SHA1
    func hmac_sha1 cData, cKey {
        # تحضير المفتاح
        if len(cKey) > 64 {
            cKey = sha1(cKey)
        }
        
        if len(cKey) < 64 {
            cKey = cKey + copy(char(0), 64 - len(cKey))
        }
        
        # حساب المفاتيح الداخلية والخارجية
        cInnerKey = ""
        cOuterKey = ""
        
        for i = 1 to 64 {
            cInnerKey += char(ascii(cKey[i]) ^ 0x36)
            cOuterKey += char(ascii(cKey[i]) ^ 0x5C)
        }
        
        # حساب HMAC
        cInnerHash = sha1(cInnerKey + cData)
        cOuterHash = sha1(cOuterKey + cInnerHash)
        
        return cOuterHash
    }
    
    # حساب HMAC-MD5
    func hmac_md5 cData, cKey {
        # تحضير المفتاح
        if len(cKey) > 64 {
            cKey = md5(cKey)
        }
        
        if len(cKey) < 64 {
            cKey = cKey + copy(char(0), 64 - len(cKey))
        }
        
        # حساب المفاتيح الداخلية والخارجية
        cInnerKey = ""
        cOuterKey = ""
        
        for i = 1 to 64 {
            cInnerKey += char(ascii(cKey[i]) ^ 0x36)
            cOuterKey += char(ascii(cKey[i]) ^ 0x5C)
        }
        
        # حساب HMAC
        cInnerHash = md5(cInnerKey + cData)
        cOuterHash = md5(cOuterKey + cInnerHash)
        
        return cOuterHash
    }
    
    # التحقق من صحة HMAC
    func verify cData, cHMAC, cKey, cAlgorithm {
        cComputedHMAC = ""
        
        switch cAlgorithm {
            case "sha256"
                cComputedHMAC = hmac_sha256(cData, cKey)
            case "sha1"
                cComputedHMAC = hmac_sha1(cData, cKey)
            case "md5"
                cComputedHMAC = hmac_md5(cData, cKey)
            other
                raise("Unsupported HMAC algorithm: " + cAlgorithm)
        }
        
        return cComputedHMAC = cHMAC
    }
    
    # توليد توكن مصادقة
    func generateAuthToken cUserId, cUserRole, cSecret, nExpiry {
        cTimestamp = string(time())
        cExpiry = string(time() + nExpiry)
        
        cData = cUserId + "|" + cUserRole + "|" + cTimestamp + "|" + cExpiry
        cHMAC = hmac_sha256(cData, cSecret)
        
        return cData + "|" + cHMAC
    }
    
    # التحقق من صحة توكن المصادقة
    func verifyAuthToken cToken, cSecret {
        aParts = split(cToken, "|")
        
        if len(aParts) != 5 {
            return false
        }
        
        cUserId = aParts[1]
        cUserRole = aParts[2]
        cTimestamp = aParts[3]
        cExpiry = aParts[4]
        cHMAC = aParts[5]
        
        # التحقق من انتهاء صلاحية التوكن
        if number(cExpiry) < time() {
            return false
        }
        
        # التحقق من صحة HMAC
        cData = cUserId + "|" + cUserRole + "|" + cTimestamp + "|" + cExpiry
        cComputedHMAC = hmac_sha256(cData, cSecret)
        
        if cComputedHMAC != cHMAC {
            return false
        }
        
        return [
            :user_id = cUserId,
            :role = cUserRole,
            :timestamp = cTimestamp,
            :expiry = cExpiry
        ]
    }
}
