Load "../src/libAgentAi.ring"


# Test Tools Class
func main
    ? "=== Testing Tools Class ==="
    
    # Test initialization
    oTools = new ToolRegistry
    //oTools.bVerbose = true
    assert(oTools != null, "Testing initialization...")
    
    # Test tool registration
    oTestTool = new Tool("TestTool", "A test tool"){
        addParameter("param1", "string", true, "")
        addPermission("read")
        addMetadata("author", "Test Author")
        setVersion("1.0.0")
    }
    assert(oTools.registerTool(oTestTool), "Testing tool registration...")
    assert(len(oTools.getAllTools()) = 1, "Testing tools count...")
   
    # Test tool retrieval
    oRetrievedTool = oTools.getTool("TestTool")
    assert(oRetrievedTool != null, "Testing tool retrieval...")
    assert(oRetrievedTool.getName() = "TestTool", "Testing tool name...")
    assert(oRetrievedTool.getVersion() = "1.0.0", "Testing tool version...")
    assert(len(oRetrievedTool.getParameters()) = 1, "Testing tool parameters...")
    assert(len(oRetrievedTool.getPermissions()) = 1, "Testing tool permissions...")
    assert(len(oRetrievedTool.getMetadata()) = 1, "Testing tool metadata...")
    
    # Test tool parameter validation
    assert(!oTestTool.validateParameters([]), "Testing parameter validation...")  # Missing required param1
    assert(oTestTool.validateParameters([[:name = "param1", :value = "test"]]), "Testing parameter validation...")
    ? "✓ Parameter validation tests passed"
    
    # Test tool permissions
    assert(!oTestTool.checkPermissions([]), "Testing permissions...")  # Missing read permission
    assert(oTestTool.checkPermissions(["read"]), "Testing permissions...")
    assert(oTestTool.checkPermissions(["read", "write"]), "Testing permissions...")
    
    # Test tool enable/disable
    assert(oTestTool.isEnabled(), "Testing initial tool state...")
    oTestTool.disable()
    assert(!oTestTool.isEnabled(), "Testing disable...")
    oTestTool.enable()
    assert(oTestTool.isEnabled(), "Testing enable...")

    # Test tool execution history
    oTestTool.logExecution("test input", "test output", :success)
    assert(len(oTestTool.getHistory()) = 1, "Testing execution history...")
   
    # Test tool unregistration
    assert(oTools.unregisterTool("TestTool"), "Testing tool unregistration...")
    assert(len(oTools.getAllTools()) = 0, "Testing unregistered tools count...")
    
    # Test category management
    assert(oTools.addCategory("TestCategory", "Test category description"), "Testing category management...")
    
    oTestTool2 = new Tool("TestTool2", "Another test tool"){
        addParameter("param1", "string", true, "")
        setVersion("2.0.0")
    }
    
    oTools.registerTool(oTestTool2)
    assert(oTools.addToolToCategory("TestTool2", "TestCategory"), "Testing tool category assignment...")
    
    aToolsInCategory = oTools.getToolsByCategory("TestCategory")
    assert(len(aToolsInCategory) = 1, "Testing tools in category...")
    assert(aToolsInCategory[1].getName() = "TestTool2", "Testing tool name...")
    ? "✓ Category management tests passed"
    
    # Test tool search
    aSearchResults = oTools.searchTools("test")
    assert(len(aSearchResults) = 1, "Testing search results...")
    assert(aSearchResults[1].getName() = "TestTool2", "Testing tool name...")

    
   
    
    oExecutableTool = new ExecutableTool("ExecutableTool", "A tool that can be executed")
    oExecutableTool.addParameter("input", "string", true, "")
    
    oTools.registerTool(oExecutableTool)
    cResult = oExecutableTool.execute([[:name = "input", :value = "test"]])
    assert(cResult = "Executed with input: test", "Testing tool execution...")
    
    # Test serialization
    cJSON = oTools.toJSON()
    assert(type(cJSON) = "STRING", "Testing JSON serialization type...")
    oNewTools = new ToolRegistry
    oNewTools.fromJSON(cJSON)
    assert(len(oNewTools.getAllTools()) = len(oTools.getAllTools()), "Testing tools count...")
    
    # Test enabled tools
    aEnabledTools = oTools.getEnabledTools()
    assert(len(aEnabledTools) = 2, "Testing enabled tools count...")  # ExecutableTool and TestTool2
    
    ? "All Tools tests passed successfully!"


 # Test tool execution
    class ExecutableTool from Tool
        func executeImpl aParams
            for param in aParams {
                if param[:name] = "input" {
                    return "Executed with input: " + param[:value]
                }
            }
            return "Executed successfully"
