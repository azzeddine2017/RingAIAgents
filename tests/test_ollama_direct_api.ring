/*
    RingAI Agents Library - Ollama Direct API Test
    This file tests direct interaction with the Ollama API
*/

# Load required libraries
Load "../src/libAgentAi.ring"

# Constants
//OLLAMA_API_URL = "http://192.168.0.160:11434/api"
OLLAMA_API_URL = "http://localhost:11434/api"
OLLAMA_MODEL = "qwen3:4b"


# Start testing
PrintTestHeader("Ollama Direct API Test")

# Test 1: Simple Chat Request
PrintTestHeader("Test 1: Simple Chat Request")

oHttp = new HttpClient()
oHttp.setHeader("Content-Type", "application/json")

# Prepare request data according to Ollama API documentation
aRequestData = [
    :model = OLLAMA_MODEL,
    :messages = [
        [
            :role = "user",
            :content = "What is artificial intelligence?"
        ]
    ],
    :stream = true
]

# Convert to JSON
cRequestData = list2json(aRequestData)

# Log the request data
? "Request data (formatted): " + cRequestData

# Fix boolean values
cRequestData = substr(cRequestData, '"stream": 1', '"stream": true')

? "Sending request to Ollama API..."
? "URL: " + OLLAMA_API_URL + "/chat"
? "Request data: " + cRequestData

# Send request
oResponse = oHttp.postData(OLLAMA_API_URL + "/chat", cRequestData)

# Check response
if oResponse = NULL
    PrintTestResult("Simple Chat Request", false)
    ? "Error: " + oHttp.getLastError()
else
    ? "Response code: " + oResponse[:code]
    ? "Response body: " + oResponse[:body]

    if oResponse[:code] = 200
        # Parse response
        oResponseData = json2list(oResponse[:body])

        if isList(oResponseData) and isList(oResponseData[:message]) and
           isString(oResponseData[:message][:content]) and
           oResponseData[:message][:content] != ""
            PrintTestResult("Simple Chat Request", true)
            ? "Response content: " + oResponseData[:message][:content]
        else
            PrintTestResult("Simple Chat Request", false)
            ? "Invalid response format"
        ok
    else
        PrintTestResult("Simple Chat Request", false)
        ? "Error response code: " + oResponse[:code]
    ok
ok

# Test 2: Chat with System Prompt
PrintTestHeader("Test 2: Chat with System Prompt")

# Prepare request data with system prompt
aRequestData = [
    :model = OLLAMA_MODEL,
    :messages = [
        [
            :role = "system",
            :content = "You are a helpful AI assistant that provides concise answers."
        ],
        [
            :role = "user",
            :content = "What is the capital of France?"
        ]
    ],
    :stream = true
]

# Convert to JSON
cRequestData = list2json(aRequestData)
cRequestData =  substr(cRequestData, '"stream": 1', '"stream": true')

? "Sending request to Ollama API..."
? "URL: " + OLLAMA_API_URL + "/chat"
? "Request data: " + cRequestData

# Send request
oResponse = oHttp.postData(OLLAMA_API_URL + "/chat", cRequestData)

# Check response
if oResponse = NULL
    PrintTestResult("Chat with System Prompt", false)
    ? "Error: " + oHttp.getLastError()
else
    ? "Response code: " + oResponse[:code]

    if oResponse[:code] = 200
        # Parse response
        oResponseData = json2list(oResponse[:body])

        if isList(oResponseData) and isList(oResponseData[:message]) and
           isString(oResponseData[:message][:content]) and
           oResponseData[:message][:content] != ""
            PrintTestResult("Chat with System Prompt", true)
            ? "Response content: " + oResponseData[:message][:content]
        else
            PrintTestResult("Chat with System Prompt", false)
            ? "Invalid response format"
        ok
    else
        PrintTestResult("Chat with System Prompt", false)
        ? "Error response code: " + oResponse[:code]
    ok
ok

# Test 3: Chat with Conversation History
PrintTestHeader("Test 3: Chat with Conversation History")

# Prepare request data with conversation history
aRequestData = [
    :model = OLLAMA_MODEL,
    :messages = [
        [
            :role = "system",
            :content = "You are a helpful AI assistant that provides concise answers."
        ],
        [
            :role = "user",
            :content = "Hello, how are you today?"
        ],
        [
            :role = "assistant",
            :content = "I'm doing well, thank you for asking! How can I help you today?"
        ],
        [
            :role = "user",
            :content = "What was my first question to you?"
        ]
    ],
    :stream = true
]

# Convert to JSON
cRequestData = list2json(aRequestData)
cRequestData = substr(cRequestData, '"stream": 1', '"stream": true')

? "Sending request to Ollama API..."
? "URL: " + OLLAMA_API_URL + "/chat"
? "Request data: " + cRequestData

# Send request
oResponse = oHttp.postData(OLLAMA_API_URL + "/chat", cRequestData)

# Check response
if oResponse = NULL
    PrintTestResult("Chat with Conversation History", false)
    ? "Error: " + oHttp.getLastError()
else
    ? "Response code: " + oResponse[:code]

    if oResponse[:code] = 200
        # Parse response
        oResponseData = json2list(oResponse[:body])

        if isList(oResponseData) and isList(oResponseData[:message]) and
           isString(oResponseData[:message][:content]) and
           oResponseData[:message][:content] != ""
            PrintTestResult("Chat with Conversation History", true)
            ? "Response content: " + oResponseData[:message][:content]

            # Check if the response contains any part of the first question
            if substr(lower(oResponseData[:message][:content]), "hello") or
               substr(lower(oResponseData[:message][:content]), "how are you")
                PrintTestResult("Context retention", true)
            else
                PrintTestResult("Context retention", false)
                ? "Response doesn't seem to reference the first question"
            ok
        else
            PrintTestResult("Chat with Conversation History", false)
            ? "Invalid response format"
        ok
    else
        PrintTestResult("Chat with Conversation History", false)
        ? "Error response code: " + oResponse[:code]
    ok
ok

# Test 4: Chat with Temperature Parameter
PrintTestHeader("Test 4: Chat with Temperature Parameter")

# Prepare request data with temperature parameter
aRequestData = [
    :model = OLLAMA_MODEL,
    :messages = [
        [
            :role = "user",
            :content = "Write a short poem about artificial intelligence."
        ]
    ],
    :stream = true,
    :options = [
        :temperature = 0.2
    ]
]

# Convert to JSON
cRequestData = list2json(aRequestData)
cRequestData = substr(cRequestData, '"stream": 1', '"stream": true')

? "Sending request to Ollama API with temperature = 0.2..."
? "URL: " + OLLAMA_API_URL + "/chat"
? "Request data: " + cRequestData

# Send request
oResponse = oHttp.postData(OLLAMA_API_URL + "/chat", cRequestData)

# Check response
if oResponse = NULL
    PrintTestResult("Chat with Temperature Parameter (0.2)", false)
    ? "Error: " + oHttp.getLastError()
else
    ? "Response code: " + oResponse[:code]

    if oResponse[:code] = 200
        # Parse response
        oResponseData = json2list(oResponse[:body])

        if isList(oResponseData) and isList(oResponseData[:message]) and
           isString(oResponseData[:message][:content]) and
           oResponseData[:message][:content] != ""
            PrintTestResult("Chat with Temperature Parameter (0.2)", true)
            ? "Response content (temp=0.2): " + oResponseData[:message][:content]
            cResponse1 = oResponseData[:message][:content]

            # Now try with higher temperature
            aRequestData[:options][:temperature] = 0.9
            cRequestData = list2json(aRequestData)

            ? "Sending request to Ollama API with temperature = 0.9..."
            ? "URL: " + OLLAMA_API_URL + "/chat"
            ? "Request data: " + cRequestData

            # Send request
            oResponse2 = oHttp.postData(OLLAMA_API_URL + "/chat", cRequestData)

            if oResponse2 = NULL
                PrintTestResult("Chat with Temperature Parameter (0.9)", false)
                ? "Error: " + oHttp.getLastError()
            else
                ? "Response code: " + oResponse2[:code]

                if oResponse2[:code] = 200
                    # Parse response
                    oResponseData2 = json2list(oResponse2[:body])

                    if isList(oResponseData2) and isList(oResponseData2[:message]) and
                       isString(oResponseData2[:message][:content]) and
                       oResponseData2[:message][:content] != ""
                        PrintTestResult("Chat with Temperature Parameter (0.9)", true)
                        ? "Response content (temp=0.9): " + oResponseData2[:message][:content]
                        cResponse2 = oResponseData2[:message][:content]

                        # Check if responses are different
                        if cResponse1 != cResponse2
                            PrintTestResult("Temperature Effect", true)
                        else
                            PrintTestResult("Temperature Effect", false)
                            ? "Responses with different temperatures are identical"
                        ok
                    else
                        PrintTestResult("Chat with Temperature Parameter (0.9)", false)
                        ? "Invalid response format"
                    ok
                else
                    PrintTestResult("Chat with Temperature Parameter (0.9)", false)
                    ? "Error response code: " + oResponse2[:code]
                ok
            ok
        else
            PrintTestResult("Chat with Temperature Parameter (0.2)", false)
            ? "Invalid response format"
        ok
    else
        PrintTestResult("Chat with Temperature Parameter (0.2)", false)
        ? "Error response code: " + oResponse[:code]
    ok
ok

# Final summary
PrintTestHeader("Test Summary")
? "Ollama Direct API test completed."
? "Check the results above to verify functionality."

# Function to print test header
func PrintTestHeader cTitle
    ? ""
    ? "====================================="
    ? " " + cTitle
    ? "====================================="
    ? ""

# Function to print test result
func PrintTestResult cTest, bResult
    if bResult
        ? "✓ " + cTest + " - PASSED"
    else
        ? "✗ " + cTest + " - FAILED"
    ok
