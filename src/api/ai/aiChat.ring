/*
    RingAI Agents API - AI Functions
    Author: Azzeddine Remmal
    Date: 2025
*/


/*
الدالة: aiChat
الوصف: التفاعل مع نموذج اللغة
*/
func aiChat
    try {
        # استخراج البيانات من الطلب
        cPrompt = NULL
        cBody = NULL

        # محاولة استخراج البيانات من معلمات الطلب
        cPrompt = oServer["prompt"]
        ? logger("aiChat function", "Trying to get prompt from params: " + cPrompt, :info)

        # إذا لم يتم العثور على البيانات في المعلمات، حاول استخراجها من جسم الطلب
        if cPrompt = NULL {
            ? logger("aiChat function", "Trying to extract data from request body", :info)

            # الحصول على محتوى الطلب
            try {
                cBody = oServer["request"]
                ? logger("aiChat function", "Request body length: " + len(cBody), :info)
                ? logger("aiChat function", "Request body: " + cBody, :info)

                if cBody != NULL and trim(cBody) != "" {
                    # محاولة تحليل البيانات كـ JSON
                    try {
                        # تنظيف النص من أي أحرف غير مرئية
                        cBody = trim(cBody)

                        # التحقق من أن النص يبدأ بـ { أو [
                        if left(cBody, 1) = "{" or left(cBody, 1) = "[" {
                            aBody = JSON2List(cBody)
                            ? logger("aiChat function", "Body parsed as JSON", :info)

                            if isList(aBody) {
                                if aBody[:prompt] != NULL {
                                    cPrompt = aBody[:prompt]
                                    ? logger("aiChat function", "Prompt from JSON body: " + cPrompt, :info)
                                else
                                    ? logger("aiChat function", "JSON body does not contain prompt field", :warning)
                                    ? logger("aiChat function", "JSON body keys: " + list2str(aBody), :info)
                                }
                            else
                                ? logger("aiChat function", "JSON parsed but result is not a list", :error)
                            }
                        else
                            ? logger("aiChat function", "Body does not start with { or [: " + left(cBody, 10), :error)
                        }
                    catch
                        ? logger("aiChat function", "Error parsing JSON body: " + cCatchError, :error)
                    }
                else
                    ? logger("aiChat function", "Request body is empty or NULL", :warning)
                }
            catch
                ? logger("aiChat function", "Error getting request content: " + cCatchError, :error)
            }
        }

        # إذا لم يتم العثور على البيانات، ارفع خطأ
        if cPrompt = NULL {
            raise("Missing prompt data")
        }

        # استخراج معلمات الطلب
        aParams = []

        # التحقق من معرف العميل
        nAgentId = 0
        cAgentId = ""

        # محاولة استخراج معرف العميل من معلمات الطلب
        cAgentId = oServer["agent_id"]
        ? logger("aiChat function", "Agent ID from params: " + cAgentId, :info)

        # إذا لم يتم العثور على معرف العميل في المعلمات، حاول استخراجه من جسم الطلب
        if cAgentId = NULL or cAgentId = "" {
            ? logger("aiChat function", "Trying to extract agent_id from request body", :info)

            # استخدام aBody الذي تم تحليله سابقًا إذا كان موجودًا
            if isList(aBody) {
                if aBody[:agent_id] != NULL {
                    cAgentId = aBody[:agent_id]
                    ? logger("aiChat function", "Agent ID from JSON body: " + cAgentId, :info)
                else
                    ? logger("aiChat function", "JSON body does not contain agent_id field", :info)
                }
            else
                ? logger("aiChat function", "No valid JSON body available for agent_id extraction", :info)
            }
        }

        # إذا كان معرف العميل موجودًا، حاول تحويله إلى رقم
        if cAgentId != NULL and cAgentId != "" {
            try {
                # تحويل معرف العميل إلى رقم
                if isNumber(cAgentId) {
                    nAgentId = number(cAgentId)
                else
                    # إذا كان معرف العميل نصًا، ابحث عن العميل بالمعرف
                    for i = 1 to len(aAgents) {
                        if isObject(aAgents[i]) and methodExists(aAgents[i], "getid") {
                            if aAgents[i].getid() = cAgentId {
                                nAgentId = i
                                ? logger("aiChat function", "Found agent with ID " + cAgentId + " at index " + i, :info)
                                exit
                            }
                        }
                    }
                }
                ? logger("aiChat function", "Agent ID converted to number: " + nAgentId, :info)
            catch
                ? logger("aiChat function", "Error converting agent ID: " + cCatchError, :error)
            }
        }

        # إذا لم يتم العثور على معرف العميل، استخدم العميل الافتراضي
        if nAgentId = 0 {
            ? logger("aiChat function", "Using default agent", :info)
        }

        # التعامل مع العميل المحدد
        cResponse = ""

        # التحقق من معرفات الوكلاء الافتراضيين
        if left(cAgentId, 13) = "agent_default" {
            ? logger("aiChat function", "Using default agent with ID: " + cAgentId, :info)

            # استخدام نموذج اللغة مباشرة مع سياق العميل الافتراضي
            # مفتاح API تم تعيينه بالفعل في initialize.ring

            if cAgentId = "agent_default_1" {
                cContext = "You are Default Assistant. A helpful AI assistant that can answer questions and provide information."
                oLLM.setSystemPrompt(cContext)

            elseif cAgentId = "agent_default_2"
                cContext = "You are Code Assistant. A specialized AI assistant for programming and software development."
                oLLM.setSystemPrompt(cContext)

            elseif cAgentId = "agent_default_3"
                cContext = "You are Education Assistant. An AI assistant specialized in teaching and explaining complex concepts."
                oLLM.setSystemPrompt(cContext)

            else
                cContext = "You are an AI assistant. Be helpful, concise, and accurate."
                oLLM.setSystemPrompt(cContext)
            }

            cResponse = oLLM.getResponse(cPrompt, aParams)

        elseif nAgentId > 0 and nAgentId <= len(aAgents)
            # استخدام العميل المحدد للرد على الرسالة
            oAgent = aAgents[nAgentId]

            # التحقق من وجود دالة receiveMessage في العميل
            if method_exists(oAgent, "receiveMessage") {
                aResult = oAgent.receiveMessage(cPrompt)

                if aResult[:success] {
                    if isList(aResult[:results]) and len(aResult[:results]) > 0 {
                        cResponse = aResult[:results][1]
                    else
                        cResponse = "Agent processed your message successfully."
                    }
                else
                    cResponse = "Error: " + aResult[:error]
                }
            else
                # استخدام نموذج اللغة مباشرة مع سياق العميل
                oLLM.setApiKey(sysget("GEMINI_API_KEY"))
                cContext = "You are " + oAgent.getname() + ". " + oAgent.getgoal()
                oLLM.setSystemPrompt(cContext)
                cResponse = oLLM.getResponse(cPrompt, aParams)
            }

        else
            # استخدام نموذج اللغة الافتراضي
            oLLM.setApiKey(sysget("GEMINI_API_KEY"))
            oLLM.setSystemPrompt("You are an AI assistant. Be helpful, concise, and accurate.")
            cResponse = oLLM.getResponse(cPrompt, aParams)
        }

        # تخزين المحادثة في الذاكرة
        aMetadata = [
            :prompt = cPrompt,
            :response = cResponse,
            :agent_id = nAgentId
        ]

        oMemory.store([
            :content = "Chat: " + cPrompt,
            :type = oMemory.SHORT_TERM,
            :priority = 5,
            :tags = ["chat", "interaction", "agent_" + nAgentId],
            :metadata = aMetadata
        ])

        # إنشاء كائن JSON للاستجابة
        aResponseObj = [
            :status = "success",
            :response = cResponse
        ]

        # تحويل الكائن إلى سلسلة JSON
        cResponseJson = list2JSON(aResponseObj)

        ? logger("aiChat function", "Chat processed successfully", :info)
        oServer.setContent(cResponseJson, "application/json")
    catch
        ? logger("aiChat function", "Error processing chat: " + cCatchError, :error)

        # إنشاء كائن JSON للخطأ
        aErrorObj = [
            :status = "error",
            :message = cCatchError
        ]

        # تحويل الكائن إلى سلسلة JSON
        cErrorJson = list2JSON(aErrorObj)

        oServer.setContent(cErrorJson, "application/json")
    }







