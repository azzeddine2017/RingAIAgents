Load "G:/RingAIAgents/src/libAgantAi.ring"

func main
    ? "=== Testing LLM Class ==="
    
    # Test 1: Initialize with Gemini model
    ? nl + "Test 1: Initializing with Gemini model"
    oLLM = new LLM("gemini-1.5-flash")
    assert(oLLM.getModel() = "gemini-1.5-flash", "Default model should be gemini-1.5-flash")
    ? "✓ Model initialization successful"
    
    # Test 2: Set API Key
    ? nl + "Test 2: Setting API Key"
    cTestApiKey = sysget("GEMINI_API_KEY")
    if cTestApiKey = "" {
        ? "✗ GEMINI_API_KEY environment variable not set"
        return
    }
    oLLM.setApiKey(cTestApiKey)
    ? "✓ API Key set successfully"
    
    # Test 3: Model Parameters
    ? nl + "Test 3: Setting Model Parameters"
    oLLM.setTemperature(0.7)
    oLLM.setMaxTokens(100)
    oLLM.setTopP(0.9)
    ? "✓ Parameters set successfully"
    
    # Test 4: Simple Prompt
    ? nl + "Test 4: Testing Simple Prompt"
    cPrompt = "Say Hello in Arabic"
    aParams = []
    
    try {
        cResponse = oLLM.getResponse(cPrompt, aParams)
        if cResponse != NULL {
            ? "✓ Response received successfully"
            ? "Response: " + cResponse
        else
            ? "✗ Failed to get response"
            ? "Error: " + oLLM.getLastError()
        }
    catch
        ? "✗ Error: " + cCatchError
    }
    
    # Test 5: Conversation History
    ? nl + "Test 5: Testing Conversation History"
    oLLM.clearHistory()
    oLLM.addToHistory("user", "What is your name?")
    oLLM.addToHistory("assistant", "I am an AI assistant.")
    ? "✓ Conversation history managed successfully"
    
    ? nl + "=== LLM Tests Complete ==="
