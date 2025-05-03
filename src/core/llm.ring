/*
    RingAI Agents Library - LLM Management
*/

class LLM
    # Constants
    GEMINI = "gemini-1.5-flash"
    GPT4 = "gpt-4"
    CLAUDE = "claude"
    LLAMA = "llama"
    OLLAMA = "ollama"

    # Constructor
    func init cModelName
        setModel(cModelName)
        if bVerbose { logger(cModel, "LLM initialized with model: " + cModelName, :info) }
        return self

    # Basic getters and setters
    func getModel return cModel
    func getTemperature return nTemperature
    func getMaxTokens return nMaxTokens
    func getTopP return nTopP
    func getPresencePenalty return nPresencePenalty
    func getFrequencyPenalty return nFrequencyPenalty
    func getSystemPrompt return cSystemPrompt
    func getLastError return cLastError
    func isStreaming return bStreaming
    func getTimeout return nTimeout
    func getMetadata return aMetadata
    func getApiKey return cApiKey
    func getHistory return aConversationHistory
    func getAvailableModels return [GEMINI, GPT4, CLAUDE, LLAMA, OLLAMA]

    func setModel cValue
        if  find([GEMINI, GPT4, CLAUDE, LLAMA, OLLAMA], cValue){
            cModel = cValue
            if bVerbose { logger(cModel, "Model set to: " + cValue, :info) }
        }
        return self

    func setApiKey cValue
        cApiKey = cValue
        if bVerbose { logger(cModel, "API key updated successfully", :success) }
        return self

    func setTemperature nValue
        if type(nValue) = :NUMBER and nValue >= 0 and nValue <= 1{
            nTemperature = nValue
            if bVerbose { logger(cModel, "Temperature set to: " + nValue, :info) }
        }
        return self

    func setMaxTokens nValue
        if type(nValue) = :NUMBER and nValue > 0{
            nMaxTokens = nValue
            if bVerbose { logger(cModel, "Max tokens set to: " + nValue, :info) }
        }
        return self

    func setTopP nValue
        if type(nValue) = :NUMBER and nValue >= 0 and nValue <= 1{
            nTopP = nValue
            if bVerbose { logger(cModel, "Top P set to: " + nValue, :info) }
        }
        return self

    func setPenalties nPresence, nFrequency
        if type(nPresence) = :NUMBER{
            nPresencePenalty = nPresence
            if bVerbose { logger(cModel, "Presence penalty set to: " + nPresence, :info) }
        }
        if type(nFrequency) = :NUMBER{
            nFrequencyPenalty = nFrequency
            if bVerbose { logger(cModel, "Frequency penalty set to: " + nFrequency, :info) }
        }
        return self

    func setSystemPrompt cValue
        cSystemPrompt = cValue
        if bVerbose { logger(cModel, "System prompt set to: " + cValue, :info) }
        return self

    func setTimeout nValue
        if type(nValue) = :NUMBER and nValue > 0{
            nTimeout = nValue
            if bVerbose { logger(cModel, "Timeout set to: " + nValue, :info) }
        }
        return self

    # Conversation Management
    func addToHistory cRole, cContent
        if len(aConversationHistory) >= nMaxHistorySize {
            del(aConversationHistory, 1)
        }
        add(aConversationHistory, [
            :role = cRole,
            :content = cContent,
            :timestamp = TimeList()[5]
        ])
        if bVerbose { logger(cModel, "Added to conversation history: " + cContent, :info) }
        return self

    func clearHistory
        aConversationHistory = []
        if bVerbose { logger(cModel, "Conversation history cleared", :info) }
        return self

    # الوصف: تحليل البيانات باستخدام الذكاء الاصطناعي
    func analyze(cData, cType)
        # ارسل الداتا الى النموذج للتحليل
        cPrompt = "Analyze the following " + cType + ": " + cData
        if bVerbose { logger(cModel, "Analyzing " + cType + ": " + cData, :info) }
        return getResponse(cPrompt, [])

    # الوصف: تدريب النموذج على البيانات
    func train(cData, cLabels, nEpochs)
        # Training not implemented
        if bVerbose { logger(cModel, "Training not implemented", :warning) }
        return "Training not implemented"



    # Response Generation
    func getResponse cPrompt, aParams
        if bVerbose {
            logger(cModel, "Generating response for prompt: " + left(cPrompt, 50) + "...", :info)
        }

        # Check cache first
        cCachedResponse = checkCache(cPrompt)
        if cCachedResponse != NULL {
            if bVerbose {
                logger(cModel, "Using cached response", :info)
            }
            return cCachedResponse
        }

        try {
            # Prepare request parameters
            aRequestParams = prepareRequestParams(cPrompt, aParams)

            # Make API call based on model
            switch cModel
                on GEMINI
                    aResponse = callGeminiAPI(aRequestParams)
                on GPT4
                    aResponse = callGPT4API(aRequestParams)
                on CLAUDE
                    aResponse = callClaudeAPI(aRequestParams)
                on LLAMA
                    aResponse = callLlamaAPI(aRequestParams)
                on OLLAMA
                    aResponse = callOllamaAPI(aRequestParams)
                other
                    raise("Unsupported model: " + cModel)
            off

            # Cache the response
            cacheResponse(cPrompt, aResponse)

            # Add to conversation history
            addToHistory("user", cPrompt)
            addToHistory("assistant", aResponse)

            if bVerbose {
                logger(cModel, "Response generated successfully", :success)
            }
            return aResponse
        catch
            cLastError = cCatchError
            if bVerbose {
                logger(cModel, "Error generating response: " + cLastError, :error)
            }
            return NULL
        }

    /*
        Function: prepareRequestParams
        Description: Prepares request parameters for API call
        Parameters: cPrompt - The prompt text
                   aParams - Additional parameters list
        Returns: JSON string of the request parameters
    */
    func prepareRequestParams cPrompt, aParams
        # Create base request structure
        aRequest = [
            :contents = [
                [
                    :parts = [
                        [
                            :text = cPrompt
                        ]
                    ]
                ]
            ]
        ]

        # Add generation config for Gemini
        /*if cModel = GEMINI {
            aRequest+:generationConfig= [
                        :maxOutputTokens = nMaxTokens,
                        :temperature = nTemperature,
                        :topP = nTopP
                ]
        }*/

        # Add additional parameters
        for aParam in aParams {
            aRequest[aParam[1]] = aParam[2]
        }

        if bVerbose {
            logger(cModel, "Request parameters prepared", :info)
        }
        return list2JSON(aRequest)

    # Serialization
    func toJSON
        return listToJSON([
            :model = cModel,
            :temperature = nTemperature,
            :max_tokens = nMaxTokens,
            :top_p = nTopP,
            :presence_penalty = nPresencePenalty,
            :frequency_penalty = nFrequencyPenalty,
            :system_prompt = cSystemPrompt,
            :streaming = bStreaming,
            :timeout = nTimeout,
            :metadata = aMetadata
        ], 0)

    func fromJSON cJSON
        aData = JSON2List(cJSON)
        if type(aData) = "LIST" {
            setModel(aData[:model])
            setTemperature(aData[:temperature])
            setMaxTokens(aData[:max_tokens])
            setTopP(aData[:top_p])
            setPenalties(aData[:presence_penalty], aData[:frequency_penalty])
            setSystemPrompt(aData[:system_prompt])
            setTimeout(aData[:timeout])
            aMetadata = aData[:metadata]
        }
        if bVerbose { logger(cModel, "Loaded from JSON successfully", :success) }
        return self

    private
    # Private Properties
        cModel = GEMINI
        cApiKey = ""
        nTemperature = 0.7
        nMaxTokens = 4096
        nTopP = 1.0
        nPresencePenalty = 0.0
        nFrequencyPenalty = 0.0
        aConversationHistory = []
        nMaxHistorySize = 10
        cSystemPrompt = ""
        cLastError = ""
        bStreaming = false
        nTimeout = 30
        aCachedResponses = []
        nMaxCacheSize = 1000
        bVerbose = 1
        aMetadata = []

    # Private Functions

    # API Calls
    func callGeminiAPI aParams
        if cApiKey = "" {
            ? logger(cModel, "API key not set for Gemini", :error)
            raise("API key not set for Gemini")
        }

        ? logger(cModel, "API key: " + cApiKey, :info)

        # Prepare URL and HTTP client
        cUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + cApiKey
        ? logger(cModel, "URL: " + cUrl, :info)
        ? logger(cModel, "Request params: " + aParams, :info)

        oHttp = new HttpClient()

        # Set headers
        oHttp.setHeader("Content-Type", "application/json")

        # Send request
        ? logger(cModel, "Sending request to Gemini API...", :info)
        oResponse = oHttp.postData(cUrl, aParams)

        # Handle errors
        if oResponse = NULL {
            cError = "Gemini API error: " + oHttp.getLastError()
            ? logger(cModel, cError, :error)
            raise(cError)
        }

        ? logger(cModel, "Response code: " + oResponse[:code], :info)

        if oResponse[:code] != 200 {
            cError = "Gemini API error: " + oResponse[:body]
            ? logger(cModel, cError, :error)
            raise(cError)
        }

        ? logger(cModel, "Response body: " + oResponse[:body], :info)

        # Parse response
        oResponseData = JSON2List(oResponse[:body])

        if !isList(oResponseData) {
            cError = "Invalid response format from Gemini API"
            ? logger(cModel, cError, :error)
            raise(cError)
        }

        if bVerbose {
            logger(cModel, "Gemini API response received", :info)
        }

        cResponse = extractGeminiResponse(oResponseData)
        ? logger(cModel, "Extracted response: " + cResponse, :info)

        return cResponse

    func callGPT4API aParams
        if cApiKey = "" { raise("API key not set for GPT-4") }

        cUrl = "https://api.openai.com/v1/chat/completions"
        oHttp = new HttpClient()

        # إضافة الهيدرز
        oHttp.setHeader("Content-Type", "application/json")
        oHttp.setHeader("Authorization", "Bearer " + cApiKey)

        # إرسال الطلب
        oResponse = oHttp.postData(cUrl, aParams)
        if oResponse = NULL {
            raise("GPT-4 API error: " + oHttp.getLastError())
        }

        if oResponse[:code] != 200 {
            raise("GPT-4 API error: " + oResponse[:body])
        }

        oResponseData = JSON2List(oResponse[:body])
        if bVerbose { logger(cModel, "GPT-4 API response received", :info) }
        return extractGPT4Response(oResponseData)

    func callClaudeAPI aParams
        if cApiKey = "" { raise("API key not set for Claude") }

        cUrl = "https://api.anthropic.com/v1/messages"
        oHttp = new HttpClient()

        # إضافة الهيدرز
        oHttp.setHeader("Content-Type", "application/json")
        oHttp.setHeader("x-api-key", cApiKey)

        # إرسال الطلب
        oResponse = oHttp.postData(cUrl, aParams)
        if oResponse = NULL {
            raise("Claude API error: " + oHttp.getLastError())
        }

        if oResponse[:code] != 200 {
            raise("Claude API error: " + oResponse[:body])
        }

        oResponseData = JSON2List(oResponse[:body])
        if bVerbose { logger(cModel, "Claude API response received", :info) }
        return extractClaudeResponse(oResponseData)

    func callLlamaAPI aParams
        # Implementation for local Llama model
        if bVerbose { logger(cModel, "Llama API not implemented yet", :warning) }
        return "Llama API not implemented yet"

    func callOllamaAPI aParams
        # Implementation for Ollama API
        if bVerbose { logger(cModel, "Calling Ollama API...", :info) }

        # Prepare request data
        aRequestData = JSON2List(aParams)

        # If no model specified in request, use default model
        if !isList(aRequestData) or !isString(aRequestData[:model]) {
            aRequestData = [
                :model = "llama3",  # Default model
                :prompt = aRequestData[:prompt]
            ]
        }

        # Determine if we should use chat or generate endpoint based on conversation history
        bUseChat = len(aConversationHistory) > 0

        # Prepare URL and HTTP client
        cUrl = bUseChat ?
            "http://localhost:11434/api/chat" :
            "http://localhost:11434/api/generate"

        oHttp = new HttpClient()

        # Set headers
        oHttp.setHeader("Content-Type", "application/json")

        # Prepare request data based on endpoint
        if bUseChat {
            # For chat endpoint, we need to format the conversation history
            aMessages = []

            # Add system message if available
            if cSystemPrompt != "" {
                add(aMessages, [
                    :role = "system",
                    :content = cSystemPrompt
                ])
            }

            # Add conversation history
            for message in aConversationHistory {
                add(aMessages, [
                    :role = message[:role],
                    :content = message[:content]
                ])
            }

            # Add current prompt as user message
            add(aMessages, [
                :role = "user",
                :content = aRequestData[:prompt]
            ])

            # Create chat request
            aRequestData = [
                :model = aRequestData[:model],
                :messages = aMessages,
                :stream = false
            ]

            # Add temperature if set
            if nTemperature != 0.7 {
                aRequestData[:temperature] = nTemperature
            }
        } else {
            # For generate endpoint, we use the prompt directly
            # Add stream parameter if not present
            if !isNumber(aRequestData[:stream]) {
                aRequestData[:stream] = false
            }

            # Add temperature if set
            if nTemperature != 0.7 {
                aRequestData[:temperature] = nTemperature
            }
        }

        # Convert to JSON
        cRequestData = list2JSON(aRequestData)

        if bVerbose {
            logger(cModel, "Ollama API URL: " + cUrl, :info)
            logger(cModel, "Ollama API Request: " + cRequestData, :info)
        }

        # Send request
        oResponse = oHttp.postData(cUrl, cRequestData)

        # Handle errors
        if oResponse = NULL {
            cError = "Ollama API error: " + oHttp.getLastError()
            if bVerbose { logger(cModel, cError, :error) }
            raise(cError)
        }

        if oResponse[:code] != 200 {
            cError = "Ollama API error: " + oResponse[:body]
            if bVerbose { logger(cModel, cError, :error) }
            raise(cError)
        }

        if bVerbose {
            logger(cModel, "Ollama API response received", :info)
            logger(cModel, "Response code: " + oResponse[:code], :info)
        }

        # Parse response
        oResponseData = JSON2List(oResponse[:body])

        if !isList(oResponseData) {
            cError = "Invalid response format from Ollama API"
            if bVerbose { logger(cModel, cError, :error) }
            raise(cError)
        }

        cResponse = extractOllamaResponse(oResponseData)

        if bVerbose { logger(cModel, "Extracted response: " + cResponse, :info) }

        return cResponse

    # Response Extraction
    func extractGeminiResponse aResponse
        if !isList(aResponse) {
            ? logger(cModel, "Response is not a list", :error)
            return ""
        }

        try {
            ? logger(cModel, "Extracting response from Gemini API", :info)

            # طباعة بنية الاستجابة للتشخيص
            ? logger(cModel, "Response structure: " + list2str(aResponse), :info)

            # التحقق من وجود المفاتيح المطلوبة
            if !isList(aResponse[:candidates]) {
                ? logger(cModel, "No candidates in response", :error)
                return ""
            }

            if len(aResponse[:candidates]) < 1 {
                ? logger(cModel, "Empty candidates list", :error)
                return ""
            }

            if !isList(aResponse[:candidates][1][:content]) {
                ? logger(cModel, "No content in first candidate", :error)
                return ""
            }

            if !isList(aResponse[:candidates][1][:content][:parts]) {
                ? logger(cModel, "No parts in content", :error)
                return ""
            }

            if len(aResponse[:candidates][1][:content][:parts]) < 1 {
                ? logger(cModel, "Empty parts list", :error)
                return ""
            }

            cText = aResponse[:candidates][1][:content][:parts][1][:text]
            ? logger(cModel, "Extracted text: " + cText, :info)
            return cText
        catch
            cError = "Error extracting Gemini response: " + cCatchError
            ? logger(cModel, cError, :error)
            return ""
        }

    func extractGPT4Response aResponse
        if !isList(aResponse) { return "" }
        try {
            return aResponse[:choices][1][:message][:content]
        catch
            if bVerbose { logger(cModel, "Error extracting GPT-4 response", :error) }
            return ""
        }

    func extractClaudeResponse aResponse
        if !isList(aResponse) { return "" }
        try {
            return aResponse[:content][1][:text]
        catch
            if bVerbose { logger(cModel, "Error extracting Claude response", :error) }
            return ""
        }

    func extractOllamaResponse aResponse
        if !isList(aResponse) { return "" }
        try {
            # For the generate endpoint, the response is in the 'response' field
            if isString(aResponse[:response]) {
                return aResponse[:response]
            }

            # For the chat endpoint, the response might be in a different format
            if isList(aResponse[:message]) and isString(aResponse[:message][:content]) {
                return aResponse[:message][:content]
            }

            # If we can't find the response in expected fields, return empty string
            if bVerbose { logger(cModel, "Could not find response in Ollama API response", :warning) }
            return ""
        catch
            if bVerbose { logger(cModel, "Error extracting Ollama response: " + cCatchError, :error) }
            return ""
        }

    # Caching
    func checkCache cPrompt
        cPromptHash = sha256(cPrompt)
        # ? "cPromptHash: " + cPromptHash
        for response in aCachedResponses {
            if response[:hash] = cPromptHash {
                if bVerbose { logger(cModel, "Cache hit found", :success) }
                return response[:content]
            }
        }
        if bVerbose { logger(cModel, "No cache entry found", :info) }
        return null

    func cacheResponse cPrompt, cResponse
        if len(aCachedResponses) >= nMaxCacheSize {
            del(aCachedResponses, 1)
        }
        add(aCachedResponses,[
            :hash = sha256(cPrompt),
            :content = cResponse,
            :timestamp = TimeList()[5]
        ])
        if bVerbose { logger(cModel, "Response cached successfully", :success) }
