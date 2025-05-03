/*
    RingAI Agents API - API Keys Functions
    Author: Azzeddine Remmal
    Date: 2025
*/


/*
الدالة: getAPIKeys
الوصف: الحصول على مفاتيح API المخزنة
*/
func getAPIKeys
    try {
        # استرجاع مفاتيح API من قاعدة البيانات
        aKeys = []

        # تحديد مسار قاعدة البيانات
        cDBPath = "G:\RingAIAgents\db\api_keys.db"

        # التحقق من وجود ملف مفاتيح API
        if !fexists(cDBPath) {
            # إنشاء قاعدة بيانات جديدة
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # إنشاء جدول مفاتيح API
            cSQL = "CREATE TABLE IF NOT EXISTS api_keys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    provider TEXT,
                    model TEXT,
                    key TEXT,
                    status TEXT DEFAULT 'unknown',
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)

            # إغلاق قاعدة البيانات
            sqlite_close(oDatabase)
        }

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # استرجاع مفاتيح API
        cSQL = "SELECT * FROM api_keys ORDER BY provider, model"
        aResults = sqlite_execute(oDatabase, cSQL)

        # معالجة النتائج
        if type(aResults) = "LIST" {
            for aResult in aResults {
                add(aKeys, [
                    :id = aResult[:id],
                    :provider = aResult[:provider],
                    :model = aResult[:model],
                    :key = aResult[:key],
                    :status = aResult[:status],
                    :timestamp = aResult[:timestamp]
                ])
            }
        }

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        # إرجاع النتائج
        ? logger("getAPIKeys function", "API keys retrieved successfully", :info)

        # تحويل القائمة إلى JSON بشكل يدوي لضمان التنسيق الصحيح
        cJSON = '{"status":"success","keys":['
        for i = 1 to len(aKeys) {
            oKey = aKeys[i]
            cJSON += '{"id":"' + oKey[:id] +
                    '","provider":"' + oKey[:provider] +
                    '","model":"' + oKey[:model] +
                    '","key":"' + oKey[:key] +
                    '","status":"' + oKey[:status] +
                    '","timestamp":"' + oKey[:timestamp] + '"}'

            if i < len(aKeys) {
                cJSON += ","
            }
        }
        cJSON += ']}'

        ? logger("getAPIKeys function", "Final JSON: " + cJSON, :info)
        oServer.setContent(cJSON, "application/json")
    catch
        ? logger("getAPIKeys function", "Error retrieving API keys: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
الدالة: addAPIKey
الوصف: إضافة مفتاح API جديد
*/
func addAPIKey
    try {
        ? logger("addAPIKey function", "Function called", :info)

        # استخراج البيانات من الطلب
        cProvider = NULL
        cModel = NULL
        cKey = NULL

        # محاولة استخراج البيانات من معلمات الطلب
        if oServer.request().has_param("provider") {
            cProvider = oServer.request().get_param_value("provider")
            ? logger("addAPIKey function", "Provider from params: " + cProvider, :info)
        }

        if oServer.request().has_param("model") {
            cModel = oServer.request().get_param_value("model")
            ? logger("addAPIKey function", "Model from params: " + cModel, :info)
        }

        if oServer.request().has_param("key") {
            cKey = oServer.request().get_param_value("key")
            ? logger("addAPIKey function", "Key from params: ***", :info)
        }

        # طباعة معلومات الطلب للتشخيص
        ? logger("addAPIKey function", "Request received", :info)

        # إذا لم يتم العثور على البيانات، حاول استخراجها من جسم الطلب
        if cProvider = NULL or cModel = NULL or cKey = NULL {
            ? logger("addAPIKey function", "Trying to extract data from request body", :info)

            # الحصول على محتوى الطلب - استخدام طريقة بديلة
            try {
                cBody = oServer["request"]
                ? logger("addAPIKey function", "Trying to get request content", :info)
            catch
                ? logger("addAPIKey function", "Error getting request content: " + cCatchError, :error)
                cBody = ""
            }
            ? logger("addAPIKey function", "Request body length: " + len(cBody), :info)

            if len(cBody) > 0 {
                ? logger("addAPIKey function", "Request body sample: " + left(cBody, 100), :info)
            }

            if cBody != NULL and trim(cBody) != "" {
                # محاولة تحليل البيانات بطرق مختلفة

                # محاولة 1: تحليل كـ JSON
                try {
                    aBody = safeJSON2List(cBody)
                    if isList(aBody) {
                        ? logger("addAPIKey function", "Body parsed as JSON", :info)

                        if aBody[:provider] != NULL {
                            cProvider = aBody[:provider]
                            ? logger("addAPIKey function", "Provider from JSON body: " + cProvider, :info)
                        }

                        if aBody[:model] != NULL {
                            cModel = aBody[:model]
                            ? logger("addAPIKey function", "Model from JSON body: " + cModel, :info)
                        }

                        if aBody[:key] != NULL {
                            cKey = aBody[:key]
                            ? logger("addAPIKey function", "Key from JSON body: ***", :info)
                        }
                    }
                catch
                    ? logger("addAPIKey function", "Body is not valid JSON: " + cCatchError, :info)
                }

                # محاولة 2: تحليل كـ نص مفصول بـ &
                if cProvider = NULL or cModel = NULL or cKey = NULL {
                    try {
                        aParams = str2list(cBody, "&")
                        ? logger("addAPIKey function", "Parsed form data, params count: " + len(aParams), :info)

                        for cParam in aParams {
                            aKeyValue = str2list(cParam, "=")
                            if len(aKeyValue) >= 2 {
                                cParamName = aKeyValue[1]
                                cParamValue = aKeyValue[2]

                                ? logger("addAPIKey function", "Form param: " + cParamName + " = " +
                                        iif(cParamName = "key", "***", cParamValue), :info)

                                if cParamName = "provider" and cProvider = NULL {
                                    cProvider = cParamValue
                                }

                                if cParamName = "model" and cModel = NULL {
                                    cModel = cParamValue
                                }

                                if cParamName = "key" and cKey = NULL {
                                    cKey = cParamValue
                                }
                            }
                        }
                    catch
                        ? logger("addAPIKey function", "Error parsing form data: " + cCatchError, :error)
                    }
                }
            else
                ? logger("addAPIKey function", "Request body is NULL or empty", :error)
            }
        }

        # إذا لم يتم العثور على البيانات، استخدم قيم افتراضية للاختبار
        if cProvider = NULL or cModel = NULL or cKey = NULL {
            ? logger("addAPIKey function", "Using test values for missing data", :warning)

            if cProvider = NULL {
                cProvider = "openai"
                ? logger("addAPIKey function", "Using test provider: " + cProvider, :warning)
            }

            if cModel = NULL {
                cModel = "gpt-4"
                ? logger("addAPIKey function", "Using test model: " + cModel, :warning)
            }

            if cKey = NULL {
                cKey = "test_key_" + random(1000000)
                ? logger("addAPIKey function", "Using test key: ***", :warning)
            }
        }

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        ? logger("addAPIKey function", "Database initialized", :info)

        # تحديد مسار قاعدة البيانات
        cDBPath = "db/api_keys.db"

        # التحقق من وجود قاعدة البيانات وإنشائها إذا لم تكن موجودة
        if !fexists(cDBPath) {
            ? logger("addAPIKey function", "Database file not found, creating new database", :info)

            sqlite_open(oDatabase, cDBPath)

            # إنشاء جدول مفاتيح API
            cSQL = "CREATE TABLE IF NOT EXISTS api_keys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    provider TEXT,
                    model TEXT,
                    key TEXT,
                    status TEXT DEFAULT 'unknown',
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )"
            sqlite_execute(oDatabase, cSQL)
            ? logger("addAPIKey function", "Created api_keys table", :info)
        else
            sqlite_open(oDatabase, cDBPath)
        }

        ? logger("addAPIKey function", "Database opened", :info)

        # تنظيف البيانات قبل استخدامها في استعلام SQL
        cProviderSafe = sanitizeSQL(cProvider)
        cModelSafe = sanitizeSQL(cModel)
        cKeySafe = sanitizeSQL(cKey)

        # إضافة مفتاح API
        cSQL = "INSERT INTO api_keys (provider, model, key, status) VALUES ('" +
               cProviderSafe + "', '" + cModelSafe + "', '" + cKeySafe + "', 'unknown')"
        ? logger("addAPIKey function", "Executing SQL: INSERT INTO api_keys...", :info)

        sqlite_execute(oDatabase, cSQL)
        ? logger("addAPIKey function", "SQL executed successfully", :info)

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)
        ? logger("addAPIKey function", "Database closed", :info)

        # إرجاع النتائج
        ? logger("addAPIKey function", "API key added successfully", :info)
        cResponse = '{"status":"success","message":"API key added successfully"}'
        ? logger("addAPIKey function", "Response: " + cResponse, :info)

        oServer.setContent(cResponse, "application/json")
    catch
        ? logger("addAPIKey function", "Error adding API key: " + cCatchError, :error)
        cErrorMsg = replaceString(cCatchError, '"', '\\"')
        cResponse = '{"status":"error","message":"' + cErrorMsg + '"}'
        ? logger("addAPIKey function", "Error response: " + cResponse, :error)
        oServer.setContent(cResponse, "application/json")
    }

/*
الدالة: updateAPIKey
الوصف: تحديث مفتاح API
*/
func updateAPIKey
    try {
        # استخراج البيانات من الطلب
        cId = oServer["id"]
        cKey = oServer["key"]

        # إذا لم يتم العثور على البيانات، حاول استخراجها من جسم الطلب
        if cId = NULL or cKey = NULL {
            ? logger("updateAPIKey function", "Trying to extract data from request body", :info)

            # استخدام oServer["request"] بدلاً من oServer.getContent()
            cBody = oServer["request"]
            ? logger("updateAPIKey function", "Request body: " + cBody, :info)

            if cBody != NULL {
                try {
                    aBody = JSON2List(cBody)
                    if isList(aBody) {
                        if aBody[:key] != NULL {
                            cKey = aBody[:key]
                            ? logger("updateAPIKey function", "Key from body: " + cKey, :info)
                        }
                    }
                catch
                    ? logger("updateAPIKey function", "Error parsing request body: " + cCatchError, :error)
                }
            }

            # إذا لم يتم العثور على المعرف، حاول استخراجه من المسار
            if cId = NULL {
                ? logger("updateAPIKey function", "Trying to extract ID from URL path", :info)

                # استخراج المعرف من المسار
                try {
                    # استخدام دالة match بدلاً من getMatches
                    cId = oServer.match(1)
                    ? logger("updateAPIKey function", "ID from URL path: " + cId, :info)
                catch
                    ? logger("updateAPIKey function", "Error getting ID from URL path: " + cCatchError, :error)
                }
            }
        }

        # التحقق من وجود البيانات
        if cId = NULL or cKey = NULL {
            raise("Missing required data")
        }

        # تحديد مسار قاعدة البيانات
        cDBPath = "db/api_keys.db"

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # تحديث مفتاح API
        cSQL = "UPDATE api_keys SET key = '" + cKey + "', status = 'unknown' WHERE id = " + cId
        sqlite_execute(oDatabase, cSQL)

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        # إرجاع النتائج
        ? logger("updateAPIKey function", "API key updated successfully", :info)
        oServer.setContent('{"status":"success","message":"API key updated successfully"}',
                          "application/json")
    catch
        ? logger("updateAPIKey function", "Error updating API key: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
الدالة: deleteAPIKey
الوصف: حذف مفتاح API
*/
func deleteAPIKey
    try {
        # استخراج البيانات من الطلب
        cId = oServer["id"]

        # إذا لم يتم العثور على البيانات، حاول استخراجها من المسار
        if cId = NULL {
            ? logger("deleteAPIKey function", "Trying to extract ID from URL path", :info)

            # استخراج المعرف من المسار
            try {
                # استخدام دالة match بدلاً من getMatches
                cId = oServer.match(1)
                ? logger("deleteAPIKey function", "ID from URL path: " + cId, :info)
            catch
                ? logger("deleteAPIKey function", "Error getting ID from URL path: " + cCatchError, :error)
            }
        }

        # التحقق من وجود البيانات
        if cId = NULL {
            raise("Missing required data")
        }

        # تحديد مسار قاعدة البيانات
        cDBPath = "db/api_keys.db"

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # حذف مفتاح API
        cSQL = "DELETE FROM api_keys WHERE id = " + cId
        sqlite_execute(oDatabase, cSQL)

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        # إرجاع النتائج
        ? logger("deleteAPIKey function", "API key deleted successfully", :info)
        oServer.setContent('{"status":"success","message":"API key deleted successfully"}',
                          "application/json")
    catch
        ? logger("deleteAPIKey function", "Error deleting API key: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
الدالة: testAPIKey
الوصف: اختبار مفتاح API
*/
func testAPIKey
    try {
        # استخراج البيانات من الطلب
        cId = oServer["id"]

        # إذا لم يتم العثور على البيانات، حاول استخراجها من المسار
        if cId = NULL {
            ? logger("testAPIKey function", "Trying to extract ID from URL path", :info)

            # استخراج المعرف من المسار
            try {
                # استخدام دالة match بدلاً من getMatches
                cId = oServer.match(1)
                ? logger("testAPIKey function", "ID from URL path: " + cId, :info)
            catch
                ? logger("testAPIKey function", "Error getting ID from URL path: " + cCatchError, :error)
            }
        }

        # التحقق من وجود البيانات
        if cId = NULL {
            raise("Missing required data")
        }

        # تحديد مسار قاعدة البيانات
        cDBPath = "db/api_keys.db"

        # فتح قاعدة البيانات
        oDatabase = sqlite_init()
        sqlite_open(oDatabase, cDBPath)

        # استرجاع مفتاح API
        cSQL = "SELECT * FROM api_keys WHERE id = " + cId
        aResults = sqlite_execute(oDatabase, cSQL)

        if type(aResults) != "LIST" or len(aResults) = 0 {
            raise("API key not found")
        }

        aKey = aResults[1]
        cProvider = aKey[:provider]
        cModel = aKey[:model]
        cKey = aKey[:key]

        # اختبار المفتاح
        bValid = false

        if cProvider = "google" {
            bValid = testGoogleAPIKey(cKey, cModel)
        elseif cProvider = "openai"
            bValid = testOpenAIAPIKey(cKey, cModel)
        elseif cProvider = "anthropic"
            bValid = testAnthropicAPIKey(cKey, cModel)
        elseif cProvider = "mistral"
            bValid = testMistralAPIKey(cKey, cModel)
        elseif cProvider = "cohere"
            bValid = testCohereAPIKey(cKey, cModel)
        }

        # تحديث حالة المفتاح
        cStatus = bValid ? "active" : "expired"
        cSQL = "UPDATE api_keys SET status = '" + cStatus + "' WHERE id = " + cId
        sqlite_execute(oDatabase, cSQL)

        # إغلاق قاعدة البيانات
        sqlite_close(oDatabase)

        # إرجاع النتائج
        if bValid {
            ? logger("testAPIKey function", "API key is valid", :info)
            oServer.setContent('{"status":"success","message":"API key is valid"}',
                              "application/json")
        else
            ? logger("testAPIKey function", "API key is invalid", :error)
            oServer.setContent('{"status":"error","message":"API key is invalid"}',
                              "application/json")
        }
    catch
        ? logger("testAPIKey function", "Error testing API key: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                          "application/json")
    }

/*
الدالة: testGoogleAPIKey
الوصف: اختبار مفتاح API من Google
*/
func testGoogleAPIKey cKey, cModel
    try {
        ? logger("testGoogleAPIKey", "Testing Google API key for model: " + cModel, :info)

        # محاولة اختبار المفتاح بطريقة آمنة
        try {
            # التحقق من وجود كائن LLM
            if isNull(oLLM) {
                ? logger("testGoogleAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testGoogleAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # تعيين مفتاح API
            oTestLLM.setApiKey(cKey)

            # اختبار المفتاح بإرسال طلب بسيط
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # التحقق من الاستجابة
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testGoogleAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testGoogleAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testGoogleAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testGoogleAPIKey", "Error in testGoogleAPIKey function: " + cCatchError, :error)
        return false
    }

/*
الدالة: testOpenAIAPIKey
الوصف: اختبار مفتاح API من OpenAI
*/
func testOpenAIAPIKey cKey, cModel
    try {
        ? logger("testOpenAIAPIKey", "Testing OpenAI API key for model: " + cModel, :info)

        # محاولة اختبار المفتاح بطريقة آمنة
        try {
            # التحقق من وجود كائن LLM
            if isNull(oLLM) {
                ? logger("testOpenAIAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testOpenAIAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # تعيين مفتاح API
            oTestLLM.setApiKey(cKey)

            # اختبار المفتاح بإرسال طلب بسيط
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # التحقق من الاستجابة
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testOpenAIAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testOpenAIAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testOpenAIAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testOpenAIAPIKey", "Error in testOpenAIAPIKey function: " + cCatchError, :error)
        return false
    }

/*
الدالة: testAnthropicAPIKey
الوصف: اختبار مفتاح API من Anthropic
*/
func testAnthropicAPIKey cKey, cModel
    try {
        ? logger("testAnthropicAPIKey", "Testing Anthropic API key for model: " + cModel, :info)

        # محاولة اختبار المفتاح بطريقة آمنة
        try {
            # التحقق من وجود كائن LLM
            if isNull(oLLM) {
                ? logger("testAnthropicAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testAnthropicAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # تعيين مفتاح API
            oTestLLM.setApiKey(cKey)

            # اختبار المفتاح بإرسال طلب بسيط
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # التحقق من الاستجابة
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testAnthropicAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testAnthropicAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testAnthropicAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testAnthropicAPIKey", "Error in testAnthropicAPIKey function: " + cCatchError, :error)
        return false
    }

/*
الدالة: testMistralAPIKey
الوصف: اختبار مفتاح API من Mistral
*/
func testMistralAPIKey cKey, cModel
    try {
        ? logger("testMistralAPIKey", "Testing Mistral API key for model: " + cModel, :info)

        # محاولة اختبار المفتاح بطريقة آمنة
        try {
            # التحقق من وجود كائن LLM
            if isNull(oLLM) {
                ? logger("testMistralAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testMistralAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # تعيين مفتاح API
            oTestLLM.setApiKey(cKey)

            # اختبار المفتاح بإرسال طلب بسيط
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # التحقق من الاستجابة
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testMistralAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testMistralAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testMistralAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testMistralAPIKey", "Error in testMistralAPIKey function: " + cCatchError, :error)
        return false
    }

/*
الدالة: testCohereAPIKey
الوصف: اختبار مفتاح API من Cohere
*/
func testCohereAPIKey cKey, cModel
    try {
        ? logger("testCohereAPIKey", "Testing Cohere API key for model: " + cModel, :info)

        # محاولة اختبار المفتاح بطريقة آمنة
        try {
            # التحقق من وجود كائن LLM
            if isNull(oLLM) {
                ? logger("testCohereAPIKey", "Creating new LLM object", :info)
                oTestLLM = new LLM(cModel)
            else
                ? logger("testCohereAPIKey", "Using existing LLM object", :info)
                oTestLLM = oLLM
            }

            # تعيين مفتاح API
            oTestLLM.setApiKey(cKey)

            # اختبار المفتاح بإرسال طلب بسيط
            cResponse = oTestLLM.getResponse("Hello, this is a test.", [])

            # التحقق من الاستجابة
            if cResponse != NULL and len(cResponse) > 0 {
                ? logger("testCohereAPIKey", "API key test successful", :info)
                return true
            }
        catch
            ? logger("testCohereAPIKey", "Error testing API key: " + cCatchError, :error)
        }

        ? logger("testCohereAPIKey", "API key test failed", :error)
        return false
    catch
        ? logger("testCohereAPIKey", "Error in testCohereAPIKey function: " + cCatchError, :error)
        return false
    }
