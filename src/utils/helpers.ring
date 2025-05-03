/*
    RingAI Agents Library - Helper Functions
*/
/*
load "stdlib.ring"
load "consolecolors.ring"

if isMainSourceFile() {
    # Example usage
    ? generateUniqueId("agent_")

    aSkills = ["JavaScript", "Python", "React"]
    ? join(aSkills, ", ")
    ? ToCode(aSkills)
}
*/

/*
الدالة: validateString
الوصف: التحقق من أن المتغير هو نص
المعاملات: cStr - المتغير المراد التحقق منه
العائد: true إذا كان المتغير نصًا، false إذا لم يكن
*/
func validateString cStr
    if type(cStr) != "STRING"{
        return false
    }
    return true

/*
الدالة: validateNumber
الوصف: التحقق من أن المتغير هو رقم
المعاملات: nNum - المتغير المراد التحقق منه
العائد: true إذا كان المتغير رقمًا، false إذا لم يكن
*/
func validateNumber nNum
    if type(nNum) != "NUMBER"{
        return false
    }
    return true

/*
الدالة: validateList
الوصف: التحقق من أن المتغير هو قائمة
المعاملات: aList - المتغير المراد التحقق منه
العائد: true إذا كان المتغير قائمة، false إذا لم يكن
*/
func validateList aList
    if type(aList) != "LIST"{
        return false
    }
    return true

/*
الدالة: isList
الوصف: التحقق من أن المتغير هو قائمة (دالة مختصرة)
المعاملات: aList - المتغير المراد التحقق منه
العائد: true إذا كان المتغير قائمة، false إذا لم يكن
*/
func isList aList
    return type(aList) = "LIST"

/*
الدالة: validateObject
الوصف: التحقق من أن المتغير هو كائن
المعاملات: oObj - المتغير المراد التحقق منه
العائد: true إذا كان المتغير كائنًا، false إذا لم يكن
*/
func validateObject oObj
    if type(oObj) != "OBJECT"{
        return false
    }
    return true

/*
الدالة: validateBoolean
الوصف: التحقق من أن المتغير هو قيمة منطقية (0 أو 1)
المعاملات: bValue - المتغير المراد التحقق منه
العائد: true إذا كان المتغير قيمة منطقية، false إذا لم يكن
*/
func validateBoolean bValue
    if type(bValue) != "NUMBER" or (bValue != 0 and bValue != 1){
        return false
    }
    return true

/*
الدالة: sanitizeSQL
الوصف: تنظيف النص قبل استخدامه في استعلامات SQL
*/
func sanitizeSQL cText
    if cText = NULL {
        return ""
    }

    # استبدال الأحرف الخاصة
    cText = replaceString(cText, "'", "''")
    cText = replaceString(cText, "\\", "\\\\")

    return cText

/*
الدالة: replaceString
الوصف: استبدال جميع حالات النص في سلسلة
*/
func replaceString cStr, cOld, cNew
    cResult = ""
    nOldLen = len(cOld)
    nPos = substr(cStr, cOld)

    while nPos > 0
        cResult += substr(cStr, 1, nPos-1) + cNew
        cStr = substr(cStr, nPos + nOldLen)
        nPos = substr(cStr, cOld)
    end

    return cResult + cStr

/*
الدالة: join
الوصف: دمج عناصر القائمة بفاصل محدد
المعاملات:
    - aList: القائمة المراد دمج عناصرها
    - cSeparator: الفاصل بين العناصر
العائد: نص يحتوي على عناصر القائمة مفصولة بالفاصل المحدد
*/
func join aList, cSeparator
    cResult = ""
    for i = 1 to len(aList) {
        cResult += aList[i]
        if i < len(aList) {
            cResult += cSeparator
        }
    }
    return cResult

/*
الدالة: iif
الوصف: دالة شرطية مختصرة (إذا-وإلا)
المعاملات:
    - condition: الشرط المراد اختباره
    - value1: القيمة المرجعة إذا كان الشرط صحيحًا
    - value2: القيمة المرجعة إذا كان الشرط خاطئًا
العائد: value1 إذا كان الشرط صحيحًا، value2 إذا كان الشرط خاطئًا
*/
func iif condition, value1, value2
    if condition return value1 else return value2 ok
    

/*
الدالة: timeDiff
الوصف: حساب الفرق الزمني بالثواني بين طابعين زمنيين
المعاملات:
    - cTime1: الطابع الزمني الأول بتنسيق "MM/DD/YYYY HH:MM:SS"
    - cTime2: الطابع الزمني الثاني بتنسيق "MM/DD/YYYY HH:MM:SS"
العائد: الفرق الزمني بالثواني بين الطابعين الزمنيين
*/
func timeDiff cTime1, cTime2
    # Split timestamps into date and time parts
    aTime1 = split(cTime1, " ")
    aTime2 = split(cTime2, " ")

    if len(aTime1) != 2 or len(aTime2) != 2 {
        return 0
    }

    # Convert dates to Julian days
    nJulian1 = gregorian2julian(aTime1[1])
    nJulian2 = gregorian2julian(aTime2[1])

    # Convert times to seconds
    aHMS1 = split(aTime1[2], ":")
    aHMS2 = split(aTime2[2], ":")

    if len(aHMS1) != 3 or len(aHMS2) != 3 {
        return 0
    }

    nSeconds1 = number(aHMS1[1]) * 3600 + number(aHMS1[2]) * 60 + number(aHMS1[3])
    nSeconds2 = number(aHMS2[1]) * 3600 + number(aHMS2[2]) * 60 + number(aHMS2[3])

    # Calculate total difference in seconds
    return (nJulian2 - nJulian1) * 86400 + (nSeconds2 - nSeconds1)

/*
الدالة: gregorian2julian
الوصف: تحويل التاريخ الميلادي إلى يوم جوليان
المعاملات:
    - cDate: التاريخ الميلادي بتنسيق "MM/DD/YYYY"
العائد: رقم اليوم الجوليان المقابل للتاريخ الميلادي
*/
func gregorian2julian cDate
    aDate = split(cDate, "/")
    if len(aDate) != 3 {
        return 0
    }

    nYear = number(aDate[3])
    nMonth = number(aDate[1])
    nDay = number(aDate[2])

    if nMonth <= 2 {
        nYear--
        nMonth += 12
    }

    nA = floor(nYear / 100)
    nB = 2 - nA + floor(nA / 4)

    return floor(365.25 * (nYear + 4716)) +
           floor(30.6001 * (nMonth + 1)) +
           nDay + nB - 1524.5

/*
الدالة: julian2gregorian
الوصف: تحويل يوم جوليان إلى تاريخ ميلادي
المعاملات:
    - nJulian: رقم اليوم الجوليان
العائد: التاريخ الميلادي بتنسيق "MM/DD/YYYY"
*/
func julian2gregorian nJulian {
    nJulian = floor(nJulian + 0.5)
    
    nA = floor((nJulian - 1867216.25) / 36524.25)
    nB = nJulian + 1 + nA - floor(nA / 4)
    nC = nB + 1524
    nD = floor((nC - 122.1) / 365.25)
    nE = floor(365.25 * nD)
    nF = floor((nC - nE) / 30.6001)
    
    nDay = nC - nE - floor(30.6001 * nF)
    nMonth = nF - 1
    if nMonth > 12 {
        nMonth = nMonth - 12
    }
    nYear = nD - 4715
    if nMonth > 2 {
        nYear--
    }
    
    # تنسيق التاريخ بالشكل MM/DD/YYYY
    return padLeft(string(nMonth), "0", 2) + "/" + 
           padLeft(string(nDay), "0", 2) + "/" + 
           string(nYear)
}

/*
الدالة: URLEncode
الوصف: ترميز النص لاستخدامه في عناوين URL
المعاملات:
    - cStr: النص المراد ترميزه
العائد: النص المرمز بتنسيق URL
*/
func URLEncode cStr
    cResult = ""
    for i = 1 to len(cStr) {
        c = substr(cStr, i, 1)
        if isalnum(c) or c = "-" or c = "_" or c = "." or c = "~"
            cResult += c
        else
            cResult += "%" + hex(ascii(c))
        ok
    }
    return cResult

/*
الدالة: assert
الوصف: التحقق من صحة شرط واظهار رسالة ملونة
المعاملات:
    - bCondition: الشرط المراد التحقق منه
    - cMessage: الرسالة المراد عرضها
العائد: لا شيء، تعرض رسالة ملونة في وحدة التحكم
*/
func assert(bCondition, cMessage)
    if not bCondition
        ? seeColored(CC_FG_RED, CC_BG_NONE,"✗ Test failed: ") + seeColored(CC_FG_YELLOW, CC_BG_NONE,cMessage)
    else
        ? seeColored(CC_FG_GREEN, CC_BG_NONE,"✓ Test passed: ") + seeColored(CC_FG_YELLOW, CC_BG_NONE,cMessage)
    ok

/*
الدالة: seeColored
الوصف: عرض نص ملون في وحدة التحكم
المعاملات:
    - CfgColor: لون النص الأمامي
    - bgColorolor: لون الخلفية
    - text: النص المراد عرضه
العائد: النص الملون
*/
func seeColored CfgColor, bgColorolor, text
    cc_print(CfgColor | bgColorolor, text)

/*
الدالة: generateUniqueId
الوصف: إنشاء معرف فريد
المعاملات:
    - cName: بادئة المعرف (مثل "agent_" أو "team_")
العائد: معرف فريد بتنسيق UUID
*/
func generateUniqueId cName
        cUUID =	"xxx_xxxx_4xxx_yxxx_xxxx"
        for cChar = 1 to len( cUUID)
                cRand16 = hex(random(15))
                cRand3 = hex(random(3))
                if cUUID[cChar] ="x"
                    cUUID[cChar]=cRand16
                elseif cUUID[cChar] ="y"
                    cUUID[cChar]= cRand3
                ok
        next
        return cName + "_" + cUUID

/*
الدالة: methodExists
الوصف: التحقق من وجود دالة في كائن
المعاملات:
    - oObject: الكائن المراد التحقق منه
    - cMethodName: اسم الدالة المراد التحقق من وجودها
العائد: true إذا كانت الدالة موجودة، false إذا لم تكن
*/
func methodExists oObject, cMethodName
    if type(oObject) != "OBJECT" or type(cMethodName) != "STRING" {
        return false
    }
    if find(methods(oObject), cMethodName) > 0 {
        return true
    }   
    return false

/*
الدالة: logger
الوصف: تسجيل رسائل في وحدة التحكم بألوان مختلفة حسب نوع الرسالة
المعاملات:
    - cComponent: اسم المكون الذي يقوم بالتسجيل
    - cMessage: الرسالة المراد تسجيلها
    - cStatus: نوع الرسالة (:error, :warning, :success, :info, :save)
العائد: لا شيء، تعرض رسالة ملونة في وحدة التحكم أو تحفظها في ملف
*/
func logger cComponent, cMessage, cStatus
    if ServerDebug = false {
        return
    }

        for Item in aDebag {

            if Item = :error and cStatus = :error{
                ? seeColored(CC_FG_DARK_RED, CC_BG_NONE,TimeList()[5]+ ' -->') +
                seeColored(CC_FG_RED, CC_BG_NONE, ' [' +cComponent+ '] : ')  +
                seeColored(CC_FG_RED, CC_BG_NONE,cMessage ) + nl

            }

            if Item  = :warning and cStatus = :warning {
                ? seeColored(CC_FG_DARK_YELLOW, CC_BG_NONE,TimeList()[5] + ' -->') +
                seeColored(CC_FG_YELLOW , CC_BG_NONE, ' [' +cComponent+ '] : ')  +
                seeColored(CC_FG_YELLOW, CC_BG_NONE,cMessage ) + nl
            }

            if Item  = :success and cStatus = :success {
                ? seeColored(CC_FG_DARK_GREEN, CC_BG_NONE,TimeList()[5]+ ' -->')  +
                seeColored(CC_FG_GREEN, CC_BG_NONE, ' [' + cComponent+ '] : ')  +
                seeColored(CC_FG_GREEN, CC_BG_NONE,cMessage ) + nl
            }

            if Item = :info and cStatus = :info {
                ? seeColored(CC_FG_DARK_CYAN, CC_BG_NONE,TimeList()[5] + ' -->')  +
                seeColored(CC_FG_CYAN, CC_BG_NONE, ' [' +cComponent+ '] : ')  +
                seeColored(CC_FG_CYAN, CC_BG_NONE,cMessage ) + nl
            }
            if Item = :save {
                # save to file
                fp = fopen("log.txt", "a")
                cStr = TimeList()[5] + ' --> [' +cComponent+ '] ' + cMessage + nl
                fwrite(fp, cStr)
                fclose(fp)
            }
        }


/*
الدالة: ToCode
الوصف: تحويل قائمة أو كائن أو أي هيكل بيانات إلى تمثيل نصي منسق بالألوان
المعاملات:
    - aInput: هيكل البيانات المراد تحويله
العائد: تمثيل نصي منسق بالألوان لهيكل البيانات
*/
func ToCode(aInput)
    cCode = cc_print(CC_FG_CYAN|CC_BG_BLACK,"[")
    lStart = True
    for item in aInput {
        if !lStart {
            cCode += cc_print(CC_FG_WHITE|CC_BG_BLACK,","+Char(32))
            else
                lStart = False
        }
        if isString(item) {
            item2 = item
            item2 = substr(item2,'"','"'+char(34)+'"')
            cCode += Char(32)+cc_print(CC_FG_GREEN|CC_BG_BLACK,'"'+item2+'"')
            elseif isnumber(item)
                cCode += Char(32)+cc_print(CC_FG_YELLOW|CC_BG_BLACK,""+item)
            elseif islist(item)
                cCode += Windowsnl()
                cCode += ToCode(item)
            elseif isobject(item)
                aAttribut = attributes(item)
                cCode += cc_print(CC_FG_MAGENTA|CC_BG_BLACK,"[")
                lStart = True
                for attribut in aAttribut {
                    if !lStart {
                        cCode += cc_print(CC_FG_WHITE|CC_BG_BLACK,",")
                        else
                            lStart = False
                    }
                    value = getattribute(item,attribut)
                    cCode += cc_print(CC_FG_BLUE|CC_BG_BLACK,":"+attribut+"=")
                    if isString(value) {
                        cCode += cc_print(CC_FG_GREEN|CC_BG_BLACK,'"'+value+'"')
                        elseif isNumber(value)
                            cCode += cc_print(CC_FG_YELLOW|CC_BG_BLACK,""+value)
                        elseif isList(value)
                            cCode += ToCode(value)
                        elseif isobject(value)
                            cCode += ToCode(value)
                    }
                }
                cCode += cc_print(CC_FG_MAGENTA|CC_BG_BLACK," ]")+Windowsnl()
        }
    }
    cCode += Char(32)+cc_print(CC_FG_CYAN|CC_BG_BLACK,"]")
    return cCode


/*
الدالة: safeJSON2List
الوصف: تحليل JSON بشكل آمن مع معالجة الأخطاء
*/
func safeJSON2List cJSON
    try {
        ? logger("safeJSON2List", "Parsing JSON: " + cJSON, :info)

        if cJSON = NULL or cJSON = "" {
            ? logger("safeJSON2List", "JSON is NULL or empty", :error)
            return NULL
        }

        # تنظيف النص من أي أحرف غير مرئية
        cJSON = trim(cJSON)

        # التحقق من أن النص يبدأ بـ { أو [
        if not (left(cJSON, 1) = "{" or left(cJSON, 1) = "[") {
            ? logger("safeJSON2List", "JSON does not start with { or [: " + left(cJSON, 10), :error)
            return NULL
        }

        # محاولة تحليل JSON
        aResult = JSON2List(cJSON)

        if isList(aResult) {
            ? logger("safeJSON2List", "JSON parsed successfully", :info)
            return aResult
        else
            ? logger("safeJSON2List", "JSON parsed but result is not a list", :error)
            return NULL
        }
    catch
        ? logger("safeJSON2List", "Error parsing JSON: " + cCatchError, :error)
        return NULL
    }



/*
الدالة: sortByTimestamp
الوصف: ترتيب قائمة حسب الطابع الزمني
*/
func sortByTimestamp aList
    # استخدام خوارزمية الفرز السريع
    if len(aList) <= 1 {
        return aList
    }

    aPivot = aList[1]
    aLess = []
    aEqual = []
    aGreater = []

    for i = 1 to len(aList) {
        if aList[i][:timestamp] < aPivot[:timestamp] {
            add(aLess, aList[i])
        elseif aList[i][:timestamp] = aPivot[:timestamp]
            add(aEqual, aList[i])
        else
            add(aGreater, aList[i])
        }
    }

    # ترتيب تنازلي (الأحدث أولاً)
    aResult = sortByTimestamp(aGreater)
    for item in aEqual { add(aResult, item) }
    aTemp = sortByTimestamp(aLess)
    for item in aTemp { add(aResult, item) }

    return aResult

