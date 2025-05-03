load "G:\RingAIAgents\src\security\Base64.ring"

/*
    اختبار دوال Base64
*/
func main {
    ? "=== اختبار دوال Base64 ==="

    # إنشاء كائن Base64
    oBase64 = new Base64()

    # اختبار تشفير وفك تشفير نص عادي
    testBase64(oBase64, "Hello, World!")

    # اختبار تشفير وفك تشفير نص عربي
    testBase64(oBase64, "مرحباً بالعالم!")

    # اختبار تشفير وفك تشفير بيانات ثنائية
    testBase64Binary(oBase64)

    # اختبار حالات خاصة
    testBase64SpecialCases(oBase64)

    ? "=== تم اكتمال الاختبارات بنجاح ==="
}

# اختبار تشفير وفك تشفير نص
func testBase64 oBase64, cText {
    ? "اختبار تشفير وفك تشفير: " + cText

    # تشفير النص
    cEncoded = oBase64.encode(cText)
    ? "  النص المشفر: " + cEncoded

    # فك تشفير النص
    cDecoded = oBase64.decode(cEncoded)
    ? "  النص بعد فك التشفير: " + cDecoded

    # التحقق من صحة فك التشفير
    assert(cDecoded = cText, "اختبار تشفير وفك تشفير النص")
}

# اختبار تشفير وفك تشفير بيانات ثنائية
func testBase64Binary oBase64 {
    ? "اختبار تشفير وفك تشفير بيانات ثنائية"

    # إنشاء بيانات ثنائية
    cBinary = ""
    for i = 0 to 255
        cBinary += char(i)
    next

    # تشفير البيانات
    cEncoded = oBase64.encode(cBinary)
    ? "  طول البيانات المشفرة: " + len(cEncoded)

    # فك تشفير البيانات
    cDecoded = oBase64.decode(cEncoded)
    ? "  طول البيانات بعد فك التشفير: " + len(cDecoded)

    # التحقق من صحة فك التشفير
    bEqual = true
    if len(cBinary) != len(cDecoded)
        bEqual = false
    else
        for i = 1 to len(cBinary)
            if substr(cBinary, i, 1) != substr(cDecoded, i, 1)
                bEqual = false
                exit
            ok
        next
    ok

    assert(bEqual, "اختبار تشفير وفك تشفير البيانات الثنائية")
}

# اختبار حالات خاصة
func testBase64SpecialCases oBase64 {
    ? "اختبار حالات خاصة"

    # اختبار سلسلة فارغة
    cEncoded = oBase64.encode("")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "", "اختبار سلسلة فارغة")

    # اختبار سلسلة بطول 1
    cEncoded = oBase64.encode("A")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "A", "اختبار سلسلة بطول 1")

    # اختبار سلسلة بطول 2
    cEncoded = oBase64.encode("AB")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "AB", "اختبار سلسلة بطول 2")

    # اختبار سلسلة بطول 3
    cEncoded = oBase64.encode("ABC")
    cDecoded = oBase64.decode(cEncoded)
    assert(cDecoded = "ABC", "اختبار سلسلة بطول 3")
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

