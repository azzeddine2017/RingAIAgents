/*
    RingAI Agents Library - Tools Management
*/


class Tool
    
    # Constructor
    func init cToolName, cToolDescription
        cName = cToolName
        cDescription = cToolDescription
        return self

    # Getters
    func getName return cName
    func getDescription return cDescription
    func getParameters return aParameters
    func getPermissions return aRequiredPermissions
    func getVersion return cVersion
    func isEnabled return bEnabled
    func getMetadata return aMetadata
    func getHistory return aExecutionHistory

    # Setters
    func setName cValue
        cName = cValue
        return self

    func setDescription cValue
        cDescription = cValue
        return self

    func setVersion cValue
        cVersion = cValue
        return self

    func enable
        bEnabled = true
        return self

    func disable
        bEnabled = false
        return self

    # Parameter management
    func addParameter cName, cType, bRequired, cDefaultValue
        add(aParameters, [
            :name = cName,
            :type = cType,
            :required = bRequired,
            :default = cDefaultValue
        ])
        return self

    func validateParameters aInputParams
        for aParam in aParameters {
            if aParam[:required] and !hasParameter(aInputParams, aParam[:name]) {
                return false
            }
        }
        return true

    # Permission management
    func addPermission cPermission
        add(aRequiredPermissions, cPermission)
        return self

    func checkPermissions aUserPermissions
        for cPermission in aRequiredPermissions {
            if find(aUserPermissions, cPermission) = 0 {
                return false
            }
        }
        return true

    # Metadata management
    func addMetadata cKey, cValue
        add(aMetadata, [:key = cKey, :value = cValue])
        return self

    # Execution history
    func logExecution cInput, cOutput, cStatus
        if len(aExecutionHistory) >= nMaxHistorySize {
            del(aExecutionHistory, 1)
        }
        add(aExecutionHistory, [
            :timestamp = TimeList()[5],
            :input = cInput,
            :output = cOutput,
            :status = cStatus
        ])

    # Tool execution
    func execute aParams
        if !bEnabled {
            return [:error = "Tool is disabled"]
        }

        if !validateParameters(aParams) {
            return [:error = "Invalid parameters"]
        }

        try {
            cResult = executeImpl(aParams)
            logExecution(aParams, cResult, :success)
            return cResult
        catch
            cError = "Error executing tool: " + cCatchError
            logExecution(aParams, cError, :error)
            return [:error = cError]
        }

    # To be overridden by specific tools
    func executeImpl aParams
        return [:error = "executeImpl not implemented"]

    # Serialization
    func toJSON
        return listToJSON([
            :name = cName,
            :description = cDescription,
            :parameters = aParameters,
            :permissions = aRequiredPermissions,
            :version = cVersion,
            :enabled = bEnabled,
            :metadata = aMetadata
        ], 0)

    func fromJSON cJSON
        aData = JSON2List(cJSON)
        if type(aData) = "LIST" {
            cName = aData[:name]
            cDescription = aData[:description]
            aParameters = aData[:parameters]
            aRequiredPermissions = aData[:permissions]
            cVersion = aData[:version]
            bEnabled = aData[:enabled]
            aMetadata = aData[:metadata]
        }
        return self

    private 

        cName = ""
        cDescription = ""
        aParameters = []
        aRequiredPermissions = []
        cVersion = "1.0"
        bEnabled = true
        aMetadata = []
        aExecutionHistory = []
        nMaxHistorySize = 100

    func hasParameter aParams, cParamName
        for param in aParams {
            if param[:name] = cParamName {
                return true
            }
        }
        return false


class ToolRegistry

    bVerbose = false

    # Tool management
    func registerTool oTool
        if !isToolRegistered(oTool.getName()) {
            add(aTools, oTool)
            
            if bVerbose { logger("ToolRegistry", "Tool registered successfully: " + oTool.getName(), :success) }
            return true
        }
        if bVerbose { logger("ToolRegistry", "Tool already registered: " + oTool.getName(), :warning) }
        return false

    func unregisterTool cToolName
        for i = 1 to len(aTools) {
            if aTools[i].getName() = cToolName {
                del(aTools, i)
                if bVerbose { logger("ToolRegistry", "Tool unregistered successfully: " + cToolName, :success) }
                return true
            }
        }
        if bVerbose { logger("ToolRegistry", "Tool not found: " + cToolName, :warning) }
        return false

    func getTool cToolName
        for tool in aTools {
            if tool.getName() = cToolName {
                if bVerbose { logger("ToolRegistry", "Tool found: " + cToolName, :success) }
                return tool
            }
        }
        if bVerbose { logger("ToolRegistry", "Tool not found: " + cToolName, :warning) }
        return null

    func getAllTools
        if bVerbose { logger("ToolRegistry", "Retrieving all tools", :info) }
        return aTools

    func getEnabledTools
        aEnabled = []
        for tool in aTools {
            if tool.isEnabled() {
                add(aEnabled, tool)
            }
        }
        if bVerbose { logger("ToolRegistry", "Retrieved enabled tools", :success) }
        return aEnabled

    # Category management
    func addCategory cName, cDescription
        if !isCategoryExists(cName) {
            add(aCategories, [
                :name = cName,
                :description = cDescription,
                :tools = []
            ])
            if bVerbose { logger("ToolRegistry", "Category added successfully: " + cName, :success) }
            return true
        }
        if bVerbose { logger("ToolRegistry", "Category already exists: " + cName, :warning) }
        return false

    func addToolToCategory cToolName, cCategoryName
        oTool = getTool(cToolName)
        if oTool = null { 
            if bVerbose { logger("ToolRegistry", "Tool not found: " + cToolName, :warning) }
            return false 
        }

        for category in aCategories {
            if category[:name] = cCategoryName {
                add(category[:tools], oTool)
                if bVerbose { logger("ToolRegistry", "Tool added to category successfully: " + cToolName + " -> " + cCategoryName, :success) }
                return true
            }
        }
        if bVerbose { logger("ToolRegistry", "Category not found: " + cCategoryName, :warning) }
        return false

    func getToolsByCategory cCategoryName
        for category in aCategories {
            if category[:name] = cCategoryName {
                if bVerbose { logger("ToolRegistry", "Retrieved tools for category: " + cCategoryName, :success) }
                return category[:tools]
            }
        }
        if bVerbose { logger("ToolRegistry", "Category not found: " + cCategoryName, :warning) }
        return []

    # Search and discovery
    func searchTools cQuery
        aResults = []
        for tool in aTools {
            if substr(lower(tool.getName()), lower(cQuery)) or
               substr(lower(tool.getDescription()), lower(cQuery)) {
                add(aResults, tool)
            }
        }
        if bVerbose { logger("ToolRegistry", "Search results: " + len(aResults) + " tools found", :success) }
        return aResults

    # Serialization
    func toJSON
        if bVerbose { logger("ToolRegistry", "Serializing to JSON", :info) }
        return ListToJSON([
            :tools = aTools,
            :categories = aCategories
        ], 0)

    func fromJSON cJSON
        if bVerbose { logger("ToolRegistry", "Deserializing from JSON", :info) }
        aData = JSON2List(cJSON)
        if type(aData) = "LIST" {
            # Reconstruct tools
            for oToolData in aData[:tools] {
                oTool = new Tool("", "")
                oTool.fromJSON(List2JSON(oToolData))
                registerTool(oTool)
            }
            aCategories = aData[:categories]
        }
        if bVerbose { logger("ToolRegistry", "Loaded from JSON successfully", :success) }
        return self

    private 

        aTools = []
        aCategories = []
        
    
    func isToolRegistered cToolName
        for tool in aTools {
            if tool.getName() = cToolName {
                if bVerbose { logger("ToolRegistry", "Tool is registered: " + cToolName, :success) }
                return true
            }
        }
        if bVerbose { logger("ToolRegistry", "Tool is not registered: " + cToolName, :warning) }
        return false

    func isCategoryExists cName
        for category in aCategories {
            if category[:name] = cName {
                if bVerbose { logger("ToolRegistry", "Category exists: " + cName, :success) }
                return true
            }
        }
        if bVerbose { logger("ToolRegistry", "Category does not exist: " + cName, :warning) }
        return false
    