load "openssllib.ring"
load "internetlib.ring"
load "jsonlib.ring"

load "G:\RingAIAgents\src\security\CSRFProtection.ring"
load "G:\RingAIAgents\src\security\XSSProtection.ring"
load "G:\RingAIAgents\src\security\InputValidator.ring"

/*
    اختبار الحماية
*/
func main {
    ? "=== اختبار الحماية ==="
    
    # اختبار التحقق من صحة المدخلات
    testInputValidation()
    
    # اختبار الحماية من CSRF
    testCSRFProtection()
    
    # اختبار الحماية من XSS
    testXSSProtection()
    
    ? "=== تم اكتمال الاختبارات بنجاح ==="
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

# دالة مساعدة للتأكيد
func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("فشل الاختبار: " + message)
    ok
} 