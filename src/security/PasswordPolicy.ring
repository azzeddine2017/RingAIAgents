/* load "openssllib.ring" */

/*
Class: PasswordPolicy
Description: سياسات كلمات المرور القوية
*/
class PasswordPolicy {
    
    func init {
        oConfig = new SecurityConfig
        
        # تحميل إعدادات كلمة المرور من التكوين
        nMinLength = oConfig.nMinPasswordLength
        bRequireSpecialChars = oConfig.bRequireSpecialChars
        bRequireNumbers = oConfig.bRequireNumbers
        bRequireUpperCase = oConfig.bRequireUpperCase
        
        # تعيين قائمة الأحرف الخاصة
        cSpecialChars = "!@#$%^&*()_+-=[]{}|;:,.<>?/"
    }
    
    # التحقق من قوة كلمة المرور
    func validatePassword cPassword {
        if cPassword = "" return false
        
        # التحقق من الطول
        if len(cPassword) < nMinLength {
            return [
                :valid = false,
                :message = "Password must be at least " + nMinLength + " characters long"
            ]
        }
        
        # التحقق من وجود أحرف خاصة
        if bRequireSpecialChars and not containsSpecialChars(cPassword) {
            return [
                :valid = false,
                :message = "Password must contain at least one special character"
            ]
        }
        
        # التحقق من وجود أرقام
        if bRequireNumbers and not containsNumbers(cPassword) {
            return [
                :valid = false,
                :message = "Password must contain at least one number"
            ]
        }
        
        # التحقق من وجود أحرف كبيرة
        if bRequireUpperCase and not containsUpperCase(cPassword) {
            return [
                :valid = false,
                :message = "Password must contain at least one uppercase letter"
            ]
        }
        
        return [
            :valid = true,
            :message = "Password meets all requirements"
        ]
    }
    
    # حساب قوة كلمة المرور (من 0 إلى 100)
    func calculateStrength cPassword {
        if cPassword = "" return 0
        
        nScore = 0
        
        # الطول
        nScore += min(len(cPassword) * 4, 40)
        
        # الأحرف الكبيرة
        if containsUpperCase(cPassword) {
            nUpperCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if isalpha(c) and c = upper(c) {
                    nUpperCount++
                }
            }
            nScore += min(nUpperCount * 2, 10)
        }
        
        # الأحرف الصغيرة
        if containsLowerCase(cPassword) {
            nLowerCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if isalpha(c) and c = lower(c) {
                    nLowerCount++
                }
            }
            nScore += min(nLowerCount * 2, 10)
        }
        
        # الأرقام
        if containsNumbers(cPassword) {
            nNumberCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if isdigit(c) {
                    nNumberCount++
                }
            }
            nScore += min(nNumberCount * 4, 20)
        }
        
        # الأحرف الخاصة
        if containsSpecialChars(cPassword) {
            nSpecialCount = 0
            for i = 1 to len(cPassword) {
                c = substr(cPassword, i, 1)
                if substr(cSpecialChars, c) > 0 {
                    nSpecialCount++
                }
            }
            nScore += min(nSpecialCount * 6, 30)
        }
        
        # التنوع
        nUnique = len(uniqueChars(cPassword))
        nScore += min(nUnique * 2, 10)
        
        # تقليل النقاط للتكرار
        nDeduction = calculateRepetitionDeduction(cPassword)
        nScore -= nDeduction
        
        # تقليل النقاط للأنماط المعروفة
        nDeduction = calculatePatternDeduction(cPassword)
        nScore -= nDeduction
        
        # ضمان أن النتيجة بين 0 و 100
        nScore = max(0, min(nScore, 100))
        
        return nScore
    }
    
    # تجزئة كلمة المرور باستخدام ملح عشوائي
    func hashPassword cPassword {
        # توليد ملح عشوائي
        cSalt = randbytes(16)
        cSaltHex = ""
        
        # تحويل الملح إلى سلسلة سداسية عشرية
        for i = 1 to len(cSalt) {
            byte = ascii(cSalt[i])
            cSaltHex += substr("0123456789abcdef", (byte / 16) + 1, 1)
            cSaltHex += substr("0123456789abcdef", (byte % 16) + 1, 1)
        }
        
        # حساب التجزئة
        cHash = sha256(cPassword + cSalt)
        
        # إرجاع الملح والتجزئة معًا
        return "$sha256$" + cSaltHex + "$" + cHash
    }
    
    # التحقق من صحة كلمة المرور
    func verifyPassword cPassword, cStoredHash {
        # تقسيم التجزئة المخزنة
        aParts = split(cStoredHash, "$")
        
        if len(aParts) != 4 {
            return false
        }
        
        cAlgorithm = aParts[2]
        cSaltHex = aParts[3]
        cHash = aParts[4]
        
        # تحويل الملح من سلسلة سداسية عشرية إلى بايتات
        cSalt = ""
        for i = 1 to len(cSaltHex) step 2 {
            cHexPair = substr(cSaltHex, i, 2)
            nByte = 0
            
            for j = 1 to 2 {
                c = lower(substr(cHexPair, j, 1))
                if c >= "0" and c <= "9" {
                    nByte = nByte * 16 + (ascii(c) - 48)
                }
                else if c >= "a" and c <= "f" {
                    nByte = nByte * 16 + (ascii(c) - 87)
                }
            }
            
            cSalt += char(nByte)
        }
        
        # حساب التجزئة
        cComputedHash = ""
        
        if cAlgorithm = "sha256" {
            cComputedHash = sha256(cPassword + cSalt)
        }
        else if cAlgorithm = "sha512" {
            cComputedHash = sha512(cPassword + cSalt)
        }
        else {
            return false
        }
        
        # التحقق من تطابق التجزئة
        return cComputedHash = cHash
    }
    
    private
    
    oConfig
    nMinLength
    bRequireSpecialChars
    bRequireNumbers
    bRequireUpperCase
    cSpecialChars
    
    # التحقق من وجود أحرف خاصة
    func containsSpecialChars cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if substr(cSpecialChars, c) > 0 {
                return true
            }
        }
        return false
    }
    
    # التحقق من وجود أرقام
    func containsNumbers cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isdigit(c) {
                return true
            }
        }
        return false
    }
    
    # التحقق من وجود أحرف كبيرة
    func containsUpperCase cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isalpha(c) and c = upper(c) {
                return true
            }
        }
        return false
    }
    
    # التحقق من وجود أحرف صغيرة
    func containsLowerCase cText {
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if isalpha(c) and c = lower(c) {
                return true
            }
        }
        return false
    }
    
    # الحصول على الأحرف الفريدة
    func uniqueChars cText {
        aChars = []
        for i = 1 to len(cText) {
            c = substr(cText, i, 1)
            if not find(aChars, c) {
                add(aChars, c)
            }
        }
        return aChars
    }
    
    # حساب خصم التكرار
    func calculateRepetitionDeduction cPassword {
        nDeduction = 0
        
        # البحث عن التكرارات
        for i = 1 to len(cPassword) - 1 {
            c = substr(cPassword, i, 1)
            cNext = substr(cPassword, i + 1, 1)
            
            if c = cNext {
                nDeduction += 2
            }
        }
        
        return nDeduction
    }
    
    # حساب خصم الأنماط
    func calculatePatternDeduction cPassword {
        nDeduction = 0
        
        # البحث عن أنماط معروفة
        aPatterns = [
            "123", "234", "345", "456", "567", "678", "789", "890",
            "abc", "bcd", "cde", "def", "efg", "fgh", "ghi", "hij",
            "ijk", "jkl", "klm", "lmn", "mno", "nop", "opq", "pqr",
            "qrs", "rst", "stu", "tuv", "uvw", "vwx", "wxy", "xyz"
        ]
        
        for pattern in aPatterns {
            if substr(lower(cPassword), lower(pattern)) > 0 {
                nDeduction += 5
            }
        }
        
        return nDeduction
    }
}
