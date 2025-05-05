/*
    RingAI Agents Library - Ollama Chat Test
    This file tests the Ollama integration with the LLM class
*/

# Load required libraries
Load "G:/RingAIAgents/src/libAgentAi.ring"

# Set verbose mode for debugging
bVerbose = true

oLLM = null
# Start testing
PrintTestHeader("Ollama Chat Test")

# Initialize LLM with Ollama model
? "Initializing Ollama LLM..."
oLLM = new LLM(oLLM.OLLAMA)

# Test model initialization
? "Testing model initialization..."
if oLLM.getModel() = oLLM.OLLAMA
    PrintTestResult("Model initialization", true)
else
    PrintTestResult("Model initialization", false)
    ? "Expected: " + oLLM.OLLAMA + ", Got: " + oLLM.getModel()
ok

# Set system prompt
? "Setting system prompt..."
oLLM.setSystemPrompt("You are a helpful AI assistant that provides concise answers.")

# Test single message generation
PrintTestHeader("Testing Single Message Generation")
? "Sending prompt to Ollama..."
cPrompt = "What is artificial intelligence?"
? "Prompt: " + cPrompt

try {
    cResponse = oLLM.getResponse(cPrompt, [
        ["model", "qwen3:4b"]  # Use qwen3:4b model or any available model
    ])

    ? "Response received:"
    ? cResponse

    if cResponse != NULL and cResponse != ""
        PrintTestResult("Single message generation", true)
    else
        PrintTestResult("Single message generation", false)
        ? "Response was empty or NULL"
    ok
catch
    PrintTestResult("Single message generation", false)
    ? "Error: " + cCatchError
}

# Test conversation
PrintTestHeader("Testing Conversation")
? "Starting conversation with Ollama..."

# Clear history first
oLLM.clearHistory()

# First message
cPrompt1 = "Hello, how are you today?"
? "User: " + cPrompt1

try {
    cResponse1 = oLLM.getResponse(cPrompt1, [
        ["model", "qwen3:4b"]
    ])

    ? "Assistant: " + cResponse1

    # Second message that references the first
    cPrompt2 = "Can you tell me more about yourself?"
    ? "User: " + cPrompt2

    cResponse2 = oLLM.getResponse(cPrompt2, [
        ["model", "qwen3:4b"]
    ])

    ? "Assistant: " + cResponse2

    # Check if conversation history is working
    if len(oLLM.getHistory()) >= 4  # Should have at least 4 messages (2 user, 2 assistant)
        PrintTestResult("Conversation history", true)
    else
        PrintTestResult("Conversation history", false)
        ? "Expected at least 4 messages in history, got: " + len(oLLM.getHistory())
    ok

    # Third message to test context retention
    cPrompt3 = "What was my first question to you?"
    ? "User: " + cPrompt3

    cResponse3 = oLLM.getResponse(cPrompt3, [
        ["model", "qwen3:4b"]
    ])

    ? "Assistant: " + cResponse3

    # Check if the response contains any part of the first question
    if substr(lower(cResponse3), lower(cPrompt1)) or
       substr(lower(cResponse3), "hello") or
       substr(lower(cResponse3), "how are you")
        PrintTestResult("Context retention", true)
    else
        PrintTestResult("Context retention", false)
        ? "Response doesn't seem to reference the first question"
    ok

catch
    PrintTestResult("Conversation test", false)
    ? "Error: " + cCatchError
}

# Test with different parameters
PrintTestHeader("Testing with Different Parameters")

# Clear history
oLLM.clearHistory()

# Test with temperature parameter
? "Testing with temperature = 0.2..."
oLLM.setTemperature(0.2)

cPrompt = "Write a short poem about artificial intelligence."
? "User: " + cPrompt

try {
    cResponse = oLLM.getResponse(cPrompt, [
        ["model", "qwen3:4b"]
    ])

    ? "Assistant (temp=0.2): " + cResponse

    # Test with higher temperature
    ? "Testing with temperature = 0.9..."
    oLLM.setTemperature(0.9)

    cResponse2 = oLLM.getResponse(cPrompt, [
        ["model", "qwen3:4b"]
    ])

    ? "Assistant (temp=0.9): " + cResponse2

    # Check if responses are different (they should be with different temperatures)
    if cResponse != cResponse2
        PrintTestResult("Temperature parameter", true)
    else
        PrintTestResult("Temperature parameter", false)
        ? "Responses with different temperatures are identical"
    ok

catch
    PrintTestResult("Parameter testing", false)
    ? "Error: " + cCatchError
}

# Final summary
PrintTestHeader("Test Summary")
? "Ollama integration test completed."
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
