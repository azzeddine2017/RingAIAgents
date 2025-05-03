/*
    RingAI Agents API - AI Functions
    Author: Azzeddine Remmal
    Date: 2025
*/


/*
الدالة: getChatHistory
الوصف: استرجاع تاريخ المحادثات من الذاكرة
*/
func getChatHistory
    try {
        # استخراج البيانات من الطلب
        nAgentId = 0
        cConversationId = NULL

        # محاولة استخراج البيانات من معلمات الطلب
        cAgentId = oServer["agent_id"]
        if cAgentId != NULL and cAgentId != "" {
            nAgentId = number(cAgentId)
        }
        ? logger("getChatHistory function", "Agent ID from params: " + nAgentId, :info)

        cConversationId = oServer["conversation_id"]
        ? logger("getChatHistory function", "Conversation ID from params: " + cConversationId, :info)

        # إذا لم يتم العثور على البيانات في المعلمات، حاول استخراجها من جسم الطلب
        try {
            cBody = oServer["request"]
            ? logger("getChatHistory function", "Trying to get request content", :info)

            if cBody != NULL and trim(cBody) != "" {
                ? logger("getChatHistory function", "Request body length: " + len(cBody), :info)
                ? logger("getChatHistory function", "Request body: " + cBody, :info)

                # محاولة تحليل البيانات كـ JSON
                try {
                    # تنظيف النص من أي أحرف غير مرئية
                    cBody = trim(cBody)

                    # التحقق من أن النص يبدأ بـ { أو [
                    if left(cBody, 1) = "{" or left(cBody, 1) = "[" {
                        aBody = JSON2List(cBody)
                        ? logger("getChatHistory function", "Body parsed as JSON", :info)

                        if isList(aBody) {
                            ? logger("getChatHistory function", "JSON body keys: " + list2str(aBody), :info)

                            if aBody[:agent_id] != NULL {
                                cAgentId = aBody[:agent_id]
                                if cAgentId != NULL and cAgentId != "" {
                                    nAgentId = number(cAgentId)
                                }
                                ? logger("getChatHistory function", "Agent ID from JSON body: " + nAgentId, :info)
                            }

                            if aBody[:conversation_id] != NULL {
                                cConversationId = aBody[:conversation_id]
                                ? logger("getChatHistory function", "Conversation ID from JSON body: " + cConversationId, :info)
                            }
                        else
                            ? logger("getChatHistory function", "JSON parsed but result is not a list", :error)
                        }
                    else
                        ? logger("getChatHistory function", "Body does not start with { or [: " + left(cBody, 10), :error)
                    }
                catch
                    ? logger("getChatHistory function", "Error parsing JSON body: " + cCatchError, :error)
                }
            else
                ? logger("getChatHistory function", "Request body is empty or NULL", :warning)
            }
        catch
            ? logger("getChatHistory function", "Error getting request content: " + cCatchError, :error)
        }

        # استرجاع المحادثات من الذاكرة
        aConversations = []

        # استرجاع محادثة محددة بواسطة معرفها
        if cConversationId != NULL {
            # استخدام دالة retrieveById للحصول على المحادثة
            aResult = oMemory.retrieveById(cConversationId)

            if aResult != NULL {
                aMetadata = aResult[:metadata]
                add(aConversations, [
                    :id = aResult[:id],
                    :timestamp = aResult[:timestamp],
                    :agent_id = aMetadata[:agent_id],
                    :prompt = aMetadata[:prompt],
                    :response = aMetadata[:response]
                ])
            }
        # استرجاع المحادثات لعميل محدد أو جميع المحادثات
        else
            # استخدام دالة retrieve للحصول على المحادثات
            # نستخدم دالة retrieve بدلاً من retrieveByTag لأن الأخيرة تتطلب معلمتين
            aResults = oMemory.retrieve("chat", "", 50)
            ? logger("getChatHistory function", "Retrieved " + len(aResults) + " chat entries", :info)

            # معالجة النتائج
            for aResult in aResults {
                aMetadata = aResult[:metadata]

                # التحقق من معرف العميل إذا كان محدداً
                if nAgentId > 0 {
                    if aMetadata[:agent_id] = nAgentId {
                        add(aConversations, [
                            :id = aResult[:id],
                            :timestamp = aResult[:timestamp],
                            :agent_id = aMetadata[:agent_id],
                            :prompt = aMetadata[:prompt],
                            :response = aMetadata[:response]
                        ])
                    }
                else
                    add(aConversations, [
                        :id = aResult[:id],
                        :timestamp = aResult[:timestamp],
                        :agent_id = aMetadata[:agent_id],
                        :prompt = aMetadata[:prompt],
                        :response = aMetadata[:response]
                    ])
                }
            }
        }

        # ترتيب المحادثات حسب التاريخ (الأحدث أولاً)
        aConversations = sortByTimestamp(aConversations)

        # إنشاء كائن JSON للاستجابة
        aResponseObj = [
            :status = "success",
            :conversations = aConversations
        ]

        # تحويل الكائن إلى سلسلة JSON
        cResponseJson = list2JSON(aResponseObj)

        # إرجاع النتائج
        ? logger("getChatHistory function", "Chat history retrieved successfully", :info)
        oServer.setContent(cResponseJson, "application/json")
    catch
        ? logger("getChatHistory function", "Error retrieving chat history: " + cCatchError, :error)

        # إنشاء كائن JSON للخطأ
        aErrorObj = [
            :status = "error",
            :message = cCatchError
        ]

        # تحويل الكائن إلى سلسلة JSON
        cErrorJson = list2JSON(aErrorObj)

        oServer.setContent(cErrorJson, "application/json")
    }
