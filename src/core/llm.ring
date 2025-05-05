/*
    RingAI Agents Library - LLM Management
*/

class LLM
    # Constants
    GEMINI = "gemini-1.5-flash"
    GPT4 = "gpt-4"
    CLAUDE = "claude"
    OLLAMA = "qwen3:4b"

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
    func getAvailableModels return [GEMINI, GPT4, CLAUDE, OLLAMA]

    func setModel cValue
        if  find([GEMINI, GPT4, CLAUDE, OLLAMA], cValue){
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
            ? logger(cModel, "Request params: " + aRequestParams, :info)

            # Make API call based on model
            switch cModel
                on GEMINI
                    aResponse = callGeminiAPI(aRequestParams)
                on GPT4
                    aResponse = callGPT4API(aRequestParams)
                on CLAUDE
                    aResponse = callClaudeAPI(aRequestParams)
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
        # Create base request structure based on model
        if cModel = OLLAMA {
            # For Ollama, use the chat format
            aRequest = [
                :model = OLLAMA,
                :messages = [
                    [
                        :role = "user",
                        :content = cPrompt
                    ]
                ],
                :stream = true
            ]
        else
            # For other models like Gemini
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
        }

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

        # Convert to JSON
        cJSON = list2JSON(aRequest)

        # If this is for Ollama, fix boolean values
        if cModel = OLLAMA {
            # Fix the stream parameter to be a proper boolean in JSON
            cJSON = substr(cJSON, '"stream": 0', '"stream": false')
            cJSON = substr(cJSON, '"stream": 1', '"stream": true')
        }

        return cJSON

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


    # Ollama API
    func callOllamaAPI aParams
        # Implementation for Ollama API
        if bVerbose { logger(cModel, "Calling Ollama API...", :info) }

        # Prepare request data
        aRequestData = JSON2List(aParams)

        # Debug the request data
        if bVerbose { logger(cModel, "Request data from params: " + list2json(aRequestData), :debug) }

        # Extract the prompt from the request data
        cPrompt = ""
        if isList(aRequestData) {
            if isList(aRequestData[:messages]) and len(aRequestData[:messages]) > 0 {
                # Extract from messages array
                for message in aRequestData[:messages] {
                    if isList(message) and message[:role] = "user" and isString(message[:content]) {
                        cPrompt = message[:content]
                        if bVerbose { logger(cModel, "Extracted prompt from messages: " + cPrompt, :info) }
                        exit
                    }
                }
            }
        }

        # If no model specified in request, use default model
        if !isList(aRequestData) or !isString(aRequestData[:model]) {
            aRequestData = [
                :model = OLLAMA,  # Default model
                :prompt = cPrompt
            ]
        }

        # Use chat endpoint for conversation, generate endpoint for single messages
        bUseChat = len(aConversationHistory) > 0

        # Prepare URL and HTTP client
        cUrl = iif(bUseChat,
            "http://localhost:11434/api/chat",
            "http://localhost:11434/api/generate")

        oHttp = new HttpClient()

        # Set headers
        oHttp.setHeader("Content-Type", "application/json")

        # Prepare request data based on endpoint
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
            :content = cPrompt
        ])

        # Get model name
        cModelName = "qwen3:4b"  # Default model
        if isList(aRequestData) and isString(aRequestData[:model]) {
            cModelName = aRequestData[:model]
        }

        # Create request according to Ollama API documentation
        if bUseChat
            # For chat endpoint
            aRequestData = [
                :model = cModelName,
                :messages = aMessages,
                :stream = false  # Set to false for now to debug
            ]
        else
            # For generate endpoint
            aRequestData = [
                :model = cModelName,
                :prompt = cPrompt,
                :stream = false  # Set to false for now to debug
            ]
        ok

        # Add temperature if set
        if nTemperature != 0.7 {
            # Add temperature in options object
            aRequestData[:options] = [
                :temperature = nTemperature
            ]
        }

        # Convert to JSON
        cRequestData = list2JSON(aRequestData)
        # Fix the stream parameter to be a proper boolean in JSON
        cRequestData = substr(cRequestData, '"stream": 0', '"stream": false')
        cRequestData = substr(cRequestData, '"stream": 1', '"stream": true')

        # Log the request data for debugging
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

            # Instead of raising an error, return a default message
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

        if oResponse[:code] != 200 {
            cError = "Ollama API error: " + oResponse[:body]
            if bVerbose { logger(cModel, cError, :error) }

            # Instead of raising an error, return a default message
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

        if bVerbose {
            logger(cModel, "Ollama API response received", :info)
            logger(cModel, "Response code: " + oResponse[:code], :info)
        }

        # Get the response body
        cResponseBody = oResponse[:body]

        # Log the raw response for debugging
        if bVerbose {
            logger(cModel, "Raw response body (first 200 chars): " + substr(cResponseBody, 1, 200), :debug)
        }

        # Process the response based on its content
        try {
            # First, try to extract the response directly
            cResponse = extractOllamaResponse(cResponseBody)

            # If we got a meaningful response, return it
            if cResponse != "" and cResponse != NULL {
                return cResponse
            }

            # If direct extraction failed, try other approaches
            if bVerbose { logger(cModel, "Direct extraction failed, trying alternative approaches", :info) }

            # Try to parse as JSON if it looks like JSON
            if substr(cResponseBody, 1, 1) = "{" {
                try {
                    oResponseData = JSON2List(cResponseBody)
                    cResponse = extractOllamaResponse(oResponseData)

                    if cResponse != "" and cResponse != NULL {
                        return cResponse
                    }
                catch
                    if bVerbose { logger(cModel, "Failed to parse as JSON: " + cCatchError, :warning) }
                }
            }

            # If it looks like a streaming response, process it accordingly
            if substr(cResponseBody, "{") > 1 {
                if bVerbose { logger(cModel, "Detected streaming response", :info) }
                cResponse = extractFromStreamingResponse(cResponseBody)

                if cResponse != "" and cResponse != NULL {
                    return cResponse
                }
            }

            # If all else fails, return the raw response if it's not too long
            if len(cResponseBody) < 1000 and cResponseBody != "" {
                if bVerbose { logger(cModel, "Returning raw response as fallback", :warning) }
                return cResponseBody
            }

            # If we get here, we couldn't extract a meaningful response
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        catch
            cError = "Error processing Ollama API response: " + cCatchError
            if bVerbose { logger(cModel, cError, :error) }
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

        # This code is unreachable due to the try/catch block above
        # Keeping it commented for reference
        # if bVerbose { logger(cModel, "Extracted response: " + cResponse, :info) }
        # return cResponse

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
        # First, check if the response is a string or not a list
        if !isList(aResponse) {
            # If it's a string, try to parse it as JSON
            if isString(aResponse) {
                if bVerbose { logger(cModel, "Response is a string, trying to parse as JSON", :info) }

                # Try to parse as JSON
                try {
                    oJson = JSON2List(aResponse)
                    if isList(oJson) {
                        # If successful, process the parsed JSON
                        return extractOllamaResponse(oJson)
                    }
                catch
                    # If it's a streaming response, process it accordingly
                    if substr(aResponse, "{") > 1 {
                        if bVerbose { logger(cModel, "Received streaming response, processing...", :info) }
                        return extractFromStreamingResponse(aResponse)
                    }

                    # If it's just plain text, return it directly
                    if bVerbose { logger(cModel, "Response appears to be plain text", :info) }
                    return aResponse
                }
            }

            # If we get here, we couldn't process the response
            if bVerbose { logger(cModel, "Response is not a list or valid JSON string", :warning) }
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

        try {
            # Log the response structure for debugging
            if bVerbose {
                logger(cModel, "Extracting response from Ollama API", :info)
                logger(cModel, "Response structure: " + list2json(aResponse), :debug)
            }

            # For the chat endpoint, check if message field exists
            if isList(aResponse) and aResponse[:message] != NULL {
                # Check if message is a list with content field
                if isList(aResponse[:message]) and aResponse[:message][:content] != NULL {
                    return aResponse[:message][:content]
                }

                # Check if message has direct content field
                if aResponse[:message][:content] != NULL {
                    return aResponse[:message][:content]
                }
            }

            # For the generate endpoint, check if response field exists
            if isList(aResponse) and aResponse[:response] != NULL {
                return aResponse[:response]
            }

            # Check for other common response formats
            if isList(aResponse) and aResponse[:content] != NULL {
                return aResponse[:content]
            }

            if isList(aResponse) and aResponse[:text] != NULL {
                return aResponse[:text]
            }

            # If we can't find the response in expected fields, return a default message
            if bVerbose {
                logger(cModel, "Could not find response in Ollama API response", :warning)
                logger(cModel, "Response structure: " + list2json(aResponse), :debug)
            }
            return "I apologize, but I couldn't extract a meaningful response from the API."
        catch
            if bVerbose {
                logger(cModel, "Error extracting Ollama response: " + cCatchError, :error)
                # Don't try to convert to JSON if it's not a list
                if isList(aResponse) {
                    logger(cModel, "Response structure: " + list2json(aResponse), :debug)
                else
                    logger(cModel, "Response is not a list", :debug)
                }
            }
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

    # Helper function to extract content from streaming response
    func extractFromStreamingResponse cResponse
        if !isString(cResponse) { return "" }

        cFullContent = ""
        aLines = str2list(cResponse, nl)

        # Log the number of lines received
        if bVerbose { logger(cModel, "Processing streaming response with " + len(aLines) + " lines", :info) }

        # If we received no lines or empty response, return a default message
        if len(aLines) = 0 or trim(cResponse) = "" {
            if bVerbose { logger(cModel, "Empty streaming response received", :warning) }
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

        # Process each line of the streaming response
        for cLine in aLines {
            if trim(cLine) = "" { loop }

            try {
                # Try to parse the line as JSON
                oJson = JSON2List(cLine)

                # For chat endpoint
                if isList(oJson) and isList(oJson[:message]) and isString(oJson[:message][:content]) {
                    # Add the content to our accumulated response
                    cFullContent += oJson[:message][:content]

                    # For debugging
                    if bVerbose and len(cFullContent) % 50 = 0 {
                        logger(cModel, "Accumulated " + len(cFullContent) + " characters so far", :debug)
                    }

                # For generate endpoint
                elseif isList(oJson) and isString(oJson[:response])
                    cFullContent += oJson[:response]
                }

                # Check if this is the last message in the stream
                if isList(oJson) and oJson[:done] = true {
                    if bVerbose { logger(cModel, "Found end of stream marker", :info) }
                }
            catch
                if bVerbose { logger(cModel, "Error parsing JSON line: " + cLine, :error) }
            }
        }

        # Clean up the content - remove any <think> tags that might be in the response
        cFullContent = substr(cFullContent, "<think>", "")
        cFullContent = substr(cFullContent, "</think>", "")

        # If we still have no content after processing, return a default message
        if trim(cFullContent) = "" {
            if bVerbose { logger(cModel, "No content extracted from streaming response", :warning) }
            return "I apologize, but I couldn't generate a response at this time. Please try again."
        }

        # If we have at least some content, consider it a success
        if len(cFullContent) > 0 {
            if bVerbose {
                logger(cModel, "Successfully extracted " + len(cFullContent) + " characters from streaming response", :success)
                logger(cModel, "First 100 characters: " + substr(cFullContent, 1, 100) + "...", :info)
            }
            return cFullContent
        }

        if bVerbose { logger(cModel, "Extracted content from streaming response: " + cFullContent, :info) }
        return cFullContent

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
