/* load "openssllib.ring"
load "G:\RingAIAgents\src\security\Base64.ring"
load "G:\RingAIAgents\src\security\config\SecurityConfig.ring" */

/*
Class: CSRFProtection
Description: الحماية من هجمات تزوير طلبات المواقع المتقاطعة
*/
class CSRFProtection {

    func init {
        oConfig = new SecurityConfig

        # تحديد مدة صلاحية التوكن (بالثواني)
        nTokenExpiry = oConfig.nCSRFTokenExpiry

        # تهيئة مخزن التوكنات
        aTokens = []

        # إنشاء كائن Base64
        oBase64 = new Base64()
    }

    # إنشاء توكن CSRF
    func generateToken cSessionId {
        # توليد توكن عشوائي باستخدام randbytes
        cToken = oBase64.encode(randbytes(32))

        # تخزين التوكن مع معرف الجلسة
        aTokens + [cToken, cSessionId, date() + " " + time()]

        return cToken
    }

    # التحقق من صحة التوكن
    func validateToken cToken, cSessionId {
        if cToken = "" or cSessionId = "" { return false }

        # البحث عن التوكن
        for i = 1 to len(aTokens) {
            if aTokens[i][1] = cToken and aTokens[i][2] = cSessionId {
                # التحقق من انتهاء صلاحية التوكن
                if not isTokenExpired(aTokens[i][3]) {
                    # حذف التوكن بعد الاستخدام
                    del(aTokens, i)
                    return true
                else
                    # حذف التوكن منتهي الصلاحية
                    del(aTokens, i)
                    return false
                }
            }
        }

        return false
    }

    # إنشاء حقل مخفي للنموذج
    func createFormField cSessionId {
        cToken = generateToken(cSessionId)
        return "<input type='hidden' name='csrf_token' value='" + cToken + "'>"
    }

    # إنشاء توكن CSRF مع توقيع HMAC
    func generateSignedToken cSessionId, cSecret {
        # توليد توكن عشوائي
        cRandom = oBase64.encode(randbytes(32))

        # إنشاء البيانات للتوقيع
        cData = cSessionId + "|" + cRandom + "|" + date() + " " + time()

        # حساب توقيع HMAC
        cSignature = hmac_sha256(cData, cSecret)

        # تخزين التوكن مع معرف الجلسة
        aTokens + [cRandom, cSessionId, date() + " " + time()]

        # إرجاع التوكن والتوقيع معًا
        return cRandom + "." + oBase64.encode(cSignature)
    }

    # التحقق من صحة التوكن الموقع
    func validateSignedToken cToken, cSessionId, cSecret {
        if cToken = "" or cSessionId = "" { return false }

        # تقسيم التوكن إلى جزأين
        aTokenParts = split(cToken, ".")
        if len(aTokenParts) != 2 { return false }

        cRandom = aTokenParts[1]
        cSignature = oBase64.decode(aTokenParts[2])

        # البحث عن التوكن
        for i = 1 to len(aTokens) {
            if aTokens[i][1] = cRandom and aTokens[i][2] = cSessionId {
                # التحقق من انتهاء صلاحية التوكن
                if not isTokenExpired(aTokens[i][3]) {
                    # إنشاء البيانات للتحقق من التوقيع
                    cData = cSessionId + "|" + cRandom + "|" + aTokens[i][3]

                    # حساب توقيع HMAC المتوقع
                    cExpectedSignature = hmac_sha256(cData, cSecret)

                    # التحقق من تطابق التوقيع
                    if cSignature = cExpectedSignature {
                        # حذف التوكن بعد الاستخدام
                        del(aTokens, i)
                        return true
                    }
                else
                    # حذف التوكن منتهي الصلاحية
                    del(aTokens, i)
                }

                return false
            }
        }

        return false
    }

    # تنظيف التوكنات منتهية الصلاحية
    func cleanExpiredTokens {
        for i = len(aTokens) to 1 step -1 {
            if isTokenExpired(aTokens[i][3]) {
                del(aTokens, i)
            }
        }
    }

    # إضافة رأس CSRF إلى الاستجابة
    func addCSRFHeader oServer, cSessionId {
        cToken = generateToken(cSessionId)
        oServer.setHeader("X-CSRF-Token", cToken)
    }

    # تشفير البيانات بترميز Base64
    func base64encode cData {
        if cData = "" { return "" }

        # جدول ترميز Base64
        cBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

        # تحويل البيانات إلى مصفوفة من البايتات
        aBytes = []
        for i = 1 to len(cData) {
            add(aBytes, ascii(substr(cData, i, 1)))
        }

        # حساب عدد البايتات المتبقية وعدد علامات = المطلوبة
        nRemainder = len(aBytes) % 3
        nPadding = 0

        if nRemainder = 1 {
            nPadding = 2
        elseif nRemainder = 2
            nPadding = 1
        }

        # إضافة بايتات صفرية للتكملة إذا لم يكن عدد البايتات من مضاعفات 3
        if nRemainder != 0 {
            for i = 1 to 3 - nRemainder {
                add(aBytes, 0)
            }
        }

        # تشفير البيانات
        cResult = ""
        for i = 1 to len(aBytes) step 3 {
            # تجميع 3 بايتات في قيمة 24 بت
            nValue = aBytes[i] * 65536 + aBytes[i+1] * 256 + aBytes[i+2]

            # تقسيم القيمة إلى 4 قيم 6 بت
            nVal1 = floor(nValue / 262144) % 64
            nVal2 = floor(nValue / 4096) % 64
            nVal3 = floor(nValue / 64) % 64
            nVal4 = nValue % 64

            # إضافة الأحرف المقابلة إلى النتيجة
            cResult += substr(cBase64Chars, nVal1 + 1, 1)
            cResult += substr(cBase64Chars, nVal2 + 1, 1)
            cResult += substr(cBase64Chars, nVal3 + 1, 1)
            cResult += substr(cBase64Chars, nVal4 + 1, 1)
        }

        # استبدال البايتات الصفرية بعلامة =
        if nPadding > 0 {
            cResult = left(cResult, len(cResult) - nPadding) + copy("=", nPadding)
        }

        return cResult
    }

    # فك تشفير البيانات من ترميز Base64
    func base64decode cData {
        if cData = "" { return "" }

        # جدول ترميز Base64
        cBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

        # حساب عدد علامات = في نهاية السلسلة
        nPadding = 0
        for i = len(cData) to 1 step -1 {
            if substr(cData, i, 1) = "=" {
                nPadding++
            else
                exit
            }
        }

        # إزالة علامات = من نهاية السلسلة
        cData = substr(cData, 1, len(cData) - nPadding)

        # تحويل الأحرف إلى قيم
        aValues = []
        for i = 1 to len(cData) {
            cChar = substr(cData, i, 1)
            nPos = 0

            # البحث عن موقع الحرف في جدول الترميز
            for j = 1 to len(cBase64Chars) {
                if substr(cBase64Chars, j, 1) = cChar {
                    nPos = j - 1
                    exit
                }
            }

            add(aValues, nPos)
        }

        # إضافة قيم صفرية للتكملة
        for i = 1 to (4 - (len(aValues) % 4)) % 4 {
            add(aValues, 0)
        }

        # فك تشفير البيانات
        cResult = ""
        nGroups = floor(len(aValues) / 4)

        for i = 1 to nGroups {
            # الحصول على 4 قيم 6 بت
            nIdx = (i - 1) * 4 + 1
            nVal1 = aValues[nIdx]
            nVal2 = aValues[nIdx + 1]
            nVal3 = aValues[nIdx + 2]
            nVal4 = aValues[nIdx + 3]

            # تجميع القيم في قيمة 24 بت
            nValue = nVal1 * 262144 + nVal2 * 4096 + nVal3 * 64 + nVal4

            # استخراج 3 بايتات من القيمة
            nByte1 = floor(nValue / 65536) % 256
            nByte2 = floor(nValue / 256) % 256
            nByte3 = nValue % 256

            # إضافة البايتات إلى النتيجة
            cResult += char(nByte1)

            # إضافة البايت الثاني إلا إذا كان هناك علامتي = في نهاية السلسلة
            if nPadding < 2 {
                cResult += char(nByte2)
            }

            # إضافة البايت الثالث إلا إذا كان هناك علامة = واحدة على الأقل في نهاية السلسلة
            if nPadding < 1 {
                cResult += char(nByte3)
            }
        }

        return cResult
    }

    private

    oConfig
    nTokenExpiry
    aTokens
    oBase64

    # التحقق من انتهاء صلاحية التوكن
    func isTokenExpired cCreatedAt {
        # حساب الفرق بين الوقت الحالي ووقت إنشاء التوكن
        # يجب تنفيذ حساب الفرق بشكل صحيح
        return timeDiff(cCreatedAt, date() + " " + time()) > nTokenExpiry
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
            cInnerKey += char(ascii(substr(cKey, i, 1)) ^ 0x36)
            cOuterKey += char(ascii(substr(cKey, i, 1)) ^ 0x5C)
        }

        # حساب HMAC
        cInnerHash = SHA256(cInnerKey + cData)
        cOuterHash = SHA256(cOuterKey + cInnerHash)

        return cOuterHash
    }

    
}