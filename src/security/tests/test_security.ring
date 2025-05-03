load "openssllib.ring"
load "internetlib.ring"
load "jsonlib.ring"

load "G:\RingAIAgents\src\security\config\SecurityConfig.ring"
load "G:\RingAIAgents\src\security\Base64.ring"
load "G:\RingAIAgents\src\security\EncryptionManager.ring"
load "G:\RingAIAgents\src\security\SecurityManager.ring"
load "G:\RingAIAgents\src\security\SessionManager.ring"
load "G:\RingAIAgents\src\security\TokenManager.ring"
load "G:\RingAIAgents\src\security\InputValidator.ring"
load "G:\RingAIAgents\src\security\CSRFProtection.ring"
load "G:\RingAIAgents\src\security\XSSProtection.ring"
load "G:\RingAIAgents\src\security\MFAManager.ring"
load "G:\RingAIAgents\src\security\RBACManager.ring"


/*
    اختبار نظام الأمان
*/
func main {
    ? "=== اختبار نظام الأمان ==="
    
    # اختبار مدير الأمان
    testSecurityManager()
    
    # اختبار التشفير
    testEncryption()
    
    # اختبار المصادقة
    testAuthentication()
    
    # اختبار الجلسات
    testSessions()
    
    # اختبار التوكنات
    testTokens()
    
    # اختبار التحقق من صحة المدخلات
    testInputValidation()
    
    # اختبار الحماية من CSRF
    testCSRFProtection()
    
    # اختبار الحماية من XSS
    testXSSProtection()
    
    # اختبار منع الاختراق
    testIntrusionPrevention()
    
    ? "=== تم اكتمال الاختبارات بنجاح ==="
}

# اختبار مدير الأمان
func testSecurityManager {
    ? "اختبار مدير الأمان..."
    
    oSecurity = new SecurityManager
    
    # اختبار التشفير وفك التشفير
    cData = "بيانات سرية للاختبار"
    cEncrypted = oSecurity.encryptData(cData)
    cDecrypted = oSecurity.decryptData(cEncrypted)
    
    assert(cDecrypted = cData, "اختبار التشفير وفك التشفير")
    
    ? "  تم اختبار مدير الأمان بنجاح"
}

# اختبار التشفير
func testEncryption {
    ? "اختبار التشفير..."
    
    oEncryption = new EncryptionManager
    
    # توليد مفتاح وvector تهيئة
    cKey = oEncryption.generateKey(32)
    cIV = oEncryption.generateIV(16)
    
    assert(len(cKey) = 32, "اختبار توليد المفتاح")
    assert(len(cIV) = 16, "اختبار توليد vector التهيئة")
    
    # اختبار التشفير وفك التشفير
    cData = "بيانات سرية للاختبار"
    cEncrypted = oEncryption.encrypt(cData, cKey, cIV)
    cDecrypted = oEncryption.decrypt(cEncrypted, cKey, cIV)
    
    assert(cDecrypted = cData, "اختبار التشفير وفك التشفير")
    
    ? "  تم اختبار التشفير بنجاح"
}

# اختبار المصادقة
func testAuthentication {
    ? "اختبار المصادقة..."
    
    oAuth = new AuthenticationManager
    
    # اختبار تجزئة كلمة المرور
    cPassword = "P@ssw0rd123"
    cHashed = oAuth.hashPassword(cPassword)
    
    assert(len(cHashed) > 0, "اختبار تجزئة كلمة المرور")
    
    ? "  تم اختبار المصادقة بنجاح"
}

# اختبار الجلسات
func testSessions {
    ? "اختبار الجلسات..."
    
    oSession = new SessionManager
    
    # إنشاء جلسة
    cUserId = "user123"
    cUserRole = "admin"
    cUserIP = "192.168.1.1"
    
    cSessionToken = oSession.createSession(cUserId, cUserRole, cUserIP)
    assert(len(cSessionToken) > 0, "اختبار إنشاء الجلسة")
    
    # التحقق من صحة الجلسة
    aSessionData = oSession.validateSession(cSessionToken)
    assert(type(aSessionData) = "LIST", "اختبار التحقق من صحة الجلسة")
    assert(aSessionData[:user_id] = cUserId, "اختبار بيانات الجلسة")
    
    # تدمير الجلسة
    cSessionId = split(cSessionToken, ".")[1]
    assert(oSession.destroySession(cSessionId), "اختبار تدمير الجلسة")
    
    ? "  تم اختبار الجلسات بنجاح"
}

# اختبار التوكنات
func testTokens {
    ? "اختبار التوكنات..."
    
    oToken = new TokenManager
    
    # إنشاء توكن
    cUserId = "user123"
    cUserRole = "admin"
    aCustomClaims = [["app", "ringai"], ["device", "desktop"]]
    
    cToken = oToken.createToken(cUserId, cUserRole, aCustomClaims)
    assert(len(cToken) > 0, "اختبار إنشاء التوكن")
    
    # التحقق من صحة التوكن
    aTokenData = oToken.validateToken(cToken)
    assert(type(aTokenData) = "LIST", "اختبار التحقق من صحة التوكن")
    assert(aTokenData[:sub] = cUserId, "اختبار بيانات التوكن")
    
    # إلغاء التوكن
    assert(oToken.revokeToken(cToken), "اختبار إلغاء التوكن")
    assert(not oToken.validateToken(cToken), "اختبار التحقق من إلغاء التوكن")
    
    ? "  تم اختبار التوكنات بنجاح"
}

# اختبار التحقق من صحة المدخلات
func testInputValidation {
    ? "اختبار التحقق من صحة المدخلات..."
    
    oValidator = new InputValidator
    
    # اختبار التحقق من صحة البريد الإلكتروني
    assert(oValidator.validateEmail("user@example.com"), "اختبار بريد إلكتروني صحيح")
    assert(not oValidator.validateEmail("invalid-email"), "اختبار بريد إلكتروني غير صحيح")
    
    # اختبار التحقق من صحة كلمة المرور
    assert(oValidator.validatePassword("P@ssw0rd123"), "اختبار كلمة مرور صحيحة")
    assert(not oValidator.validatePassword("weak"), "اختبار كلمة مرور ضعيفة")
    
    # اختبار التحقق من صحة النص
    assert(oValidator.validateText("نص عادي للاختبار"), "اختبار نص عادي")
    assert(not oValidator.validateText("<script>alert('XSS')</script>"), "اختبار نص يحتوي على XSS")
    
    # اختبار تنظيف النص
    cDirtyText = "<script>alert('XSS')</script>"
    cCleanText = oValidator.sanitizeText(cDirtyText)
    assert(substr(cCleanText, "<script>") = 0, "اختبار تنظيف النص")
    
    ? "  تم اختبار التحقق من صحة المدخلات بنجاح"
}

# اختبار الحماية من CSRF
func testCSRFProtection {
    ? "اختبار الحماية من CSRF..."
    
    oCSRF = new CSRFProtection
    
    # إنشاء توكن CSRF
    cSessionId = "session123"
    cToken = oCSRF.generateToken(cSessionId)
    assert(len(cToken) > 0, "اختبار إنشاء توكن CSRF")
    
    # التحقق من صحة التوكن
    assert(oCSRF.validateToken(cToken, cSessionId), "اختبار التحقق من صحة توكن CSRF")
    
    # إنشاء حقل نموذج
    cFormField = oCSRF.createFormField(cSessionId)
    assert(substr(cFormField, "csrf_token") > 0, "اختبار إنشاء حقل نموذج")
    
    ? "  تم اختبار الحماية من CSRF بنجاح"
}

# اختبار الحماية من XSS
func testXSSProtection {
    ? "اختبار الحماية من XSS..."
    
    oXSS = new XSSProtection
    
    # اختبار تنظيف النص
    cDirtyText = "<script>alert('XSS')</script>"
    cCleanText = oXSS.sanitize(cDirtyText)
    assert(substr(cCleanText, "<script>") = 0, "اختبار تنظيف النص")
    
    ? "  تم اختبار الحماية من XSS بنجاح"
}

# اختبار منع الاختراق
func testIntrusionPrevention {
    ? "اختبار منع الاختراق..."
    
    oIntrusion = new IntrusionPreventionManager
    
    # اختبار التحقق من أنماط مشبوهة
    assert(oIntrusion.containsSuspiciousPatterns("<script>alert('XSS')</script>"), "اختبار نمط مشبوه")
    assert(not oIntrusion.containsSuspiciousPatterns("نص عادي للاختبار"), "اختبار نص عادي")
    
    # اختبار حظر عنوان IP
    cIP = "192.168.1.100"
    oIntrusion.blockIP(cIP)
    assert(oIntrusion.isIPBlocked(cIP), "اختبار حظر عنوان IP")
    
    ? "  تم اختبار منع الاختراق بنجاح"
}

# دالة مساعدة للتأكيد
func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("فشل الاختبار: " + message)
    ok
}

# تشغيل الاختبارات

