load "G:/RingAIAgents/src/security/config/SecurityConfig.ring"

/*
Class: InputValidator
Description: مدقق صحة المدخلات
*/
class InputValidator {
    
    # متغيرات الكلاس
    oConfig
    nMinPasswordLength
    bRequireSpecialChars
    bRequireNumbers
    bRequireUpperCase
    aSuspiciousPatterns
    
    func init {
        oConfig = new SecurityConfig()
        
        # نسخ الإعدادات من الكائن oConfig مع التحويل الصحيح للقيم
        try {
            nMinPasswordLength = number(oConfig.nMinPasswordLength)
        catch
            nMinPasswordLength = 8  # قيمة افتراضية
        }
        
        # تحويل القيم المنطقية
        bRequireSpecialChars = isTrue(oConfig.bRequireSpecialChars)
        bRequireNumbers = isTrue(oConfig.bRequireNumbers)
        bRequireUpperCase = isTrue(oConfig.bRequireUpperCase)
        aSuspiciousPatterns = oConfig.aSuspiciousPatterns
    }
    
    # دالة مساعدة للتحويل إلى قيمة منطقية
    func isTrue value {
        if type(value) = "NUMBER" {
            return value = 1
        }
        return false
    }
    
    # التحقق من صحة البريد الإلكتروني
    func validateEmail cEmail {
        if cEmail = "" return false ok
        
        # التحقق من وجود @ و .
        if substr(cEmail, "@") = 0 return false ok
        if substr(cEmail, ".") = 0 return false ok
        
        # التحقق من عدم وجود مسافات
        if substr(cEmail, " ") > 0 return false ok
        
        # التحقق من الطول
        if len(cEmail) < 5 return false ok
        
        # التحقق من صحة التنسيق باستخدام تعبير منتظم
        # يجب تنفيذ التحقق باستخدام تعبير منتظم بشكل صحيح
        
        return true
    }
    
    # التحقق من صحة كلمة المرور
    func validatePassword cPassword {
        try {
            if cPassword = "" return false ok
            
            # التحقق من الطول
            if len(cPassword) < nMinPasswordLength return false ok
            
            # التحقق من وجود أحرف خاصة
            if bRequireSpecialChars {
                if not containsSpecialChars(cPassword) return false ok
            }
            
            # التحقق من وجود أرقام
            if bRequireNumbers {
                if not containsNumbers(cPassword) return false ok
            }
            
            # التحقق من وجود أحرف كبيرة
            if bRequireUpperCase {
                if not containsUpperCase(cPassword) return false ok
            }
            
            return true
        catch
            ? "خطأ في التحقق من كلمة المرور: " + cCatchError
            return false
        }
    }
    
    # التحقق من صحة اسم المستخدم
    func validateUsername cUsername {
        if cUsername = "" return false ok
        
        # التحقق من الطول
        if len(cUsername) < 3 return false ok
        
        # التحقق من عدم وجود مسافات
        if substr(cUsername, " ") > 0 return false ok
        
        # التحقق من صحة التنسيق (أحرف وأرقام فقط)
        for i = 1 to len(cUsername) {
            c = substr(cUsername, i, 1)
            if not (isalpha(c) or isdigit(c) or c = "_") return false ok
        }
        
        return true
    }
    
    # التحقق من صحة النص (منع حقن SQL و XSS)
    func validateText cText {
        if cText = "" return true ok
        
        # التحقق من عدم وجود أنماط مشبوهة
        for pattern in aSuspiciousPatterns {
            if substr(lower(cText), lower(pattern)) > 0 return false ok
        }
        
        return true
    }
    
    # التحقق من صحة الرقم
    func validateNumber cNumber {
        if cNumber = "" return false ok
        
        # التحقق من أن المدخل رقم
        for i = 1 to len(cNumber) {
            c = substr(cNumber, i, 1)
            if not (isdigit(c) or c = "." or c = "-") return false ok
        }
        
        return true
    }
    
    # التحقق من صحة التاريخ
    func validateDate cDate {
        if cDate = "" return false ok
        
        # التحقق من صحة تنسيق التاريخ
        # يجب تنفيذ التحقق من صحة التاريخ بشكل صحيح
        
        return true
    }
    
    # تنظيف النص (إزالة الأكواد الضارة)
    func sanitizeText cText {
        if cText = "" return "" ok      
        
        # استبدال الأكواد الضارة
        cText = replaceHtmlTags(cText)
        cText = replaceSqlInjection(cText)
        
        return cText
    }
    
    private
    
    # التحقق من وجود أحرف خاصة
    func containsSpecialChars cText {
        cSpecialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?/"
        for i = 1 to len(cSpecialChars) {
            c = substr(cSpecialChars, i, 1)
            if substr(cText, c) > 0 return true ok
        }
        return false 
    }
    
    # التحقق من وجود أرقام
    func containsNumbers cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isdigit(c) return true ok
        }
        return false 
    }
    
    # التحقق من وجود أحرف كبيرة
    func containsUpperCase cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isalpha(c) and c = upper(c) return true ok
        }
        return false 
    }
    
    # استبدال وسوم HTML
    func replaceHtmlTags cText {
        cText = substr(cText, "<", "&lt;")
        cText = substr(cText, ">", "&gt;")
        cText = substr(cText, '\"', "&quot;")
        cText = substr(cText, "'", "&#39;")
        return cText
    }
    
    # استبدال أنماط حقن SQL
    func replaceSqlInjection cText {
        cText = substr(cText, "SELECT", "")
        cText = substr(cText, "INSERT", "")
        cText = substr(cText, "UPDATE", "")
        cText = substr(cText, "DELETE", "")
        cText = substr(cText, "DROP", "")
        cText = substr(cText, "UNION", "")
        cText = substr(cText, ";", "")
        cText = substr(cText, "--", "")
        return cText
    }
}
