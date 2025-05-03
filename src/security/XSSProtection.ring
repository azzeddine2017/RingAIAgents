//load "openssllib.ring"

/*
Class: XSSProtection
Description: الحماية من هجمات البرمجة النصية عبر المواقع
*/
class XSSProtection {
    
    func init {
        oConfig = new SecurityConfig
        
        # تحميل قائمة الأنماط المشبوهة من التكوين
        aSuspiciousPatterns = oConfig.aSuspiciousPatterns
        
        # إضافة أنماط إضافية
        aAdditionalPatterns = [
            "javascript:",
            "eval(",
            "document.cookie",
            "document.write",
            "document.location",
            "window.location",
            "onerror=",
            "onload=",
            "onclick=",
            "onmouseover=",
            "onfocus=",
            "onblur=",
            "onsubmit=",
            "onchange=",
            "onkeypress=",
            "onkeydown=",
            "onkeyup=",
            "ondblclick=",
            "oncontextmenu=",
            "onmousedown=",
            "onmouseup=",
            "onmousemove=",
            "onmouseout=",
            "onmouseover=",
            "ondrag=",
            "ondrop=",
            "onunload="
        ]
        
        # دمج القوائم
        for pattern in aAdditionalPatterns {
            if not find(aSuspiciousPatterns, pattern) {
                add(aSuspiciousPatterns, pattern)
            }
        }
    }
    
    # تنظيف النص من أكواد XSS
    func sanitize cText {
        if cText = "" return "" ok
        
        # استبدال الوسوم الخطرة
        cText = replaceHtmlTags(cText)
        
        # استبدال أكواد JavaScript الخطرة
        cText = replaceJavaScriptCode(cText)
        
        # تشفير النص باستخدام SHA256 للتحقق من عدم تغييره
        cHash = sha256(cText)
        
        return cText
    }
    
    # التحقق من صحة النص
    func validateText cText {
        if cText = "" return true ok
        
        # التحقق من عدم وجود أنماط مشبوهة
        for pattern in aSuspiciousPatterns {
            if substr(lower(cText), lower(pattern)) > 0 {
                return false
            }
        }
        
        return true
    }
    
    # إضافة رأس Content-Security-Policy
    func addCSPHeader oServer {
        cCSP = "default-src 'self'; " +
               "script-src 'self' https://cdnjs.cloudflare.com https://code.jquery.com; " +
               "style-src 'self' https://cdnjs.cloudflare.com; " +
               "img-src 'self' data:; " +
               "font-src 'self' https://cdnjs.cloudflare.com; " +
               "connect-src 'self';"
        
        oServer.setHeader("Content-Security-Policy", cCSP)
    }
    
    # إضافة رأس X-XSS-Protection
    func addXSSProtectionHeader oServer {
        oServer.setHeader("X-XSS-Protection", "1; mode=block")
    }
    
    # إضافة رأس X-Content-Type-Options
    func addContentTypeOptionsHeader oServer {
        oServer.setHeader("X-Content-Type-Options", "nosniff")
    }
    
    # إضافة رأس Strict-Transport-Security
    func addHSTSHeader oServer {
        oServer.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload")
    }
    
    # إضافة رأس X-Frame-Options
    func addFrameOptionsHeader oServer {
        oServer.setHeader("X-Frame-Options", "SAMEORIGIN")
    }
    
    # إضافة رأس Referrer-Policy
    func addReferrerPolicyHeader oServer {
        oServer.setHeader("Referrer-Policy", "strict-origin-when-cross-origin")
    }
    
    # إضافة رأس Permissions-Policy
    func addPermissionsPolicyHeader oServer {
        oServer.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=(), payment=()")
    }
    
    # إضافة جميع رؤوس الحماية
    func addSecurityHeaders oServer {
        addCSPHeader(oServer)
        addXSSProtectionHeader(oServer)
        addContentTypeOptionsHeader(oServer)
        addHSTSHeader(oServer)
        addFrameOptionsHeader(oServer)
        addReferrerPolicyHeader(oServer)
        addPermissionsPolicyHeader(oServer)
    }
    
    # توليد توكن CSRF
    func generateCSRFToken {
        # استخدام وظيفة Randbytes لتوليد بايتات عشوائية آمنة
        cRandom = randbytes(32)
        # تشفير البايتات العشوائية باستخدام SHA256
        return sha256(cRandom + date() + time())
    }
    
    # تشفير البيانات الحساسة
    func encryptSensitiveData cData, cKey, cIV {
        try {
            return encrypt(cData, cKey, cIV, "aes256")
        catch
            return ""
        }
    }
    
    # فك تشفير البيانات الحساسة
    func decryptSensitiveData cEncryptedData, cKey, cIV {
        try {
            return decrypt(cEncryptedData, cKey, cIV, "aes256")
        catch
            return ""
        }
    }
    
    private
    
    oConfig
    aSuspiciousPatterns = []
    
    # استبدال وسوم HTML
    func replaceHtmlTags cText {
        cText = substr(cText, "<", "&lt;")
        cText = substr(cText, ">", "&gt;")
        cText = substr(cText, '"', "&quot;")
        cText = substr(cText, "'", "&#39;")
        cText = substr(cText, "&", "&amp;")
        return cText
    }
    
    # استبدال أكواد JavaScript الخطرة
    func replaceJavaScriptCode cText {
        # استبدال أنماط JavaScript الخطرة
        for pattern in aSuspiciousPatterns {
            if substr(lower(cText), lower(pattern)) > 0 {
                cText = substr(cText, pattern, "")
            }
        }
        
        return cText
    }
    
    # التحقق من صحة البيانات المشفرة
    func validateEncryptedData cEncryptedData, cHash {
        # التحقق من تطابق البصمة
        return sha256(cEncryptedData) = cHash
    }
}
