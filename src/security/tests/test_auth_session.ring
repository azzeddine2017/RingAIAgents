load "openssllib.ring"
load "internetlib.ring"
load "jsonlib.ring"
load "consolecolors.ring"
load "G:/RingAIAgents/src/security/SessionManager.ring"
load "G:/RingAIAgents/src/security/TokenManager.ring"
load "G:/RingAIAgents/src/security/hmac.ring"

/*
    اختبار المصادقة والجلسات
*/
func main {
    ? "=== اختبار المصادقة والجلسات ==="
    
    # اختبار الجلسات
    testSessions()
    
    # اختبار التوكنات
    testTokens()
    
    ? "=== تم اكتمال الاختبارات بنجاح ==="
}

# اختبار الجلسات
func testSessions {
    ? "اختبار الجلسات..."
    
    oSession = new SessionManager()
    
    # إنشاء جلسة
    cUserId = "user123"
    cUserRole = "admin"
    cUserIP = "192.168.0.187"
    
    cSessionToken = oSession.createSession(cUserId, cUserRole, cUserIP)
    assert(len(cSessionToken) > 0, "اختبار إنشاء الجلسة")
    ? cSessionToken
    # التحقق من صحة الجلسة
    aSessionData = oSession.validateSession(cSessionToken)
    ? "بيانات الجلسة: "
    ? aSessionData
    
    # التحقق من نوع البيانات المرجعة
    assert(not aSessionData = false, "اختبار التحقق من صحة الجلسة")
    
    # التحقق من البيانات فقط إذا كانت قائمة
    if type(aSessionData) = "LIST" {
        assert(aSessionData["user_id"] = cUserId, "اختبار بيانات الجلسة")
    }
    
    # تدمير الجلسة
    cSessionId = split(cSessionToken, ".")[1]
    assert(oSession.destroySession(cSessionId), "اختبار تدمير الجلسة")
    
    ? "  تم اختبار الجلسات بنجاح"
}

# اختبار التوكنات
func testTokens {
    ? "اختبار التوكنات..."
    
    oToken = new TokenManager()
    
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

# دالة مساعدة للتأكيد
/*func assert condition, message {
    if condition
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("فشل الاختبار: " + message)
    ok
} */