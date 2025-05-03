/*
    RingAI Agents Library - Memory Management
*/

class Memory

    # Memory types
    SHORT_TERM = :short_term
    LONG_TERM = :long_term
    EPISODIC = :episodic
    SEMANTIC = :semantic
    bVerbose = true

    func init cDbPath
        if bVerbose { logger("Memory", "Initializing memory system", :info) }
        try {
            initDatabase(cDbPath)
            if bVerbose { logger("Memory", "Memory system initialized successfully", :success) }
        catch
            if bVerbose { logger("Memory", "Failed to initialize memory: " + cCatchError, :error) }
        }
        return self

    func store aMemoryData
        if bVerbose { logger("Memory", "Storing new memory entry", :info) }
        try {
            # Handle different call patterns
            if type(aMemoryData) = "LIST" {
                # Called with a memory data map
                cContent = aMemoryData[:content]
                if aMemoryData[:type] != NULL {
                    cType = aMemoryData[:type]
                else
                    cType = SHORT_TERM
                }

                if aMemoryData[:priority] != NULL {
                    nPriority = aMemoryData[:priority]
                else
                    nPriority = 1
                }

                if aMemoryData[:tags] != NULL {
                    aTags = aMemoryData[:tags]
                else
                    aTags = []
                }

                if aMemoryData[:metadata] != NULL {
                    aMetadata = aMemoryData[:metadata]
                else
                    aMetadata = []
                }
            else
                # Called with content only
                cContent = aMemoryData
                cType = SHORT_TERM
                nPriority = 1
                aTags = []
                aMetadata = []
            }

            if !isValidType(cType) { cType = SHORT_TERM }
            if !isValidPriority(nPriority) { nPriority = 1 }

            cTagsJson = listToJSON(aTags, 0)
            cMetadataJson = listToJSON(aMetadata, 0)

            cSQL = "INSERT INTO memories (content, type, priority, tags, metadata)
                    VALUES ('" + cContent + "', '" + cType + "', " + nPriority + ", '" + cTagsJson + "', '" + cMetadataJson + "')"

            sqlite_execute(oDatabase, cSQL)

            if bVerbose { logger("Memory", "Memory stored successfully", :success) }
            # Cleanup old memories if capacity exceeded
            cleanupOldMemories()
            return true
        catch
            if bVerbose { logger("Memory", "Failed to store memory: " + cCatchError, :error) }
            return false
        }

    func retrieve cQuery, cType, nLimit
        if cType = NULL { cType = "" }
        if nLimit = NULL { nLimit = 10 }

        if bVerbose { logger("Memory", "Retrieving memories for query: " + cQuery, :info) }
        try {
            cSQL = "SELECT * FROM memories WHERE content LIKE " + "'%" + cQuery + "%'"

            if cType != "" {
                cSQL += " AND type = '" + cType + "'"
            }

            cSQL += " ORDER BY priority DESC, timestamp DESC LIMIT " + nLimit

            aResults = []
            aResult = sqlite_execute(oDatabase, cSQL)
            if type(aResult) = "LIST" {
                for item in aResult {
                    add(aResults, [
                    :id = item[:id],
                    :content = item[:content],
                    :type = item[:type],
                    :priority = number(item[:priority]),
                    :timestamp = item[:timestamp],
                    :tags = JSON2List(item[:tags]),
                    :metadata = JSON2List(item[:metadata])
                    ])
                }
            }

            if bVerbose { logger("Memory", "Found " + len(aResults) + " matching memories", :success) }
            return aResults
        catch
            if bVerbose { logger("Memory", "Error retrieving memories: " + cCatchError, :error) }
            return []
        }

    func searchByTags aTags, nLimit
        if bVerbose { logger("Memory", "Searching memories by tags", :info) }
        try {
            cTagsJson = JSON2List(aTags)
            
            cSQL = "SELECT * FROM memories WHERE tags LIKE " + "'%" + cTagsJson + "%'" +
                    " ORDER BY priority DESC, timestamp DESC LIMIT " + nLimit
            aResults = sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Memory", "Found " + len(aResults) + " matching memories", :success) }
            return aResults
        catch
            if bVerbose { logger("Memory", "Error searching memories: " + cCatchError, :error) }
            return []
        }

    func updatePriority nId, nNewPriority
        if bVerbose { logger("Memory", "Updating memory priority", :info) }
        try {
            if !isValidPriority(nNewPriority) { return false }
            cSQL = "UPDATE memories SET priority = " + nNewPriority + " WHERE id = " + nId
            sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Memory", "Memory priority updated successfully", :success) }
            return true
        catch
            if bVerbose { logger("Memory", "Failed to update memory priority: " + cCatchError, :error) }
            return false
        }

    func consolidateMemories
        if bVerbose { logger("Memory", "Consolidating memories", :info) }
        try {
            # Move important short-term memories to long-term storage
            cSQL = "UPDATE memories
                    SET type = '" + LONG_TERM + "'
                    WHERE type = '" + SHORT_TERM + "'
                    AND priority >= 8
                    AND datetime('now') > datetime(timestamp, '+1 day')"
            sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Memory", "Memories consolidated successfully", :success) }
        catch
            if bVerbose { logger("Memory", "Error consolidating memories: " + cCatchError, :error) }
        }

    func clear
        if bVerbose { logger("Memory", "Clearing memories", :warning) }
        try {
            sqlite_execute(oDatabase, "DELETE FROM memories")
            if bVerbose { logger("Memory", "Memories cleared successfully", :success) }
        catch
            if bVerbose { logger("Memory", "Error clearing memories: " + cCatchError, :error) }
        }

    func getSize
        if bVerbose { logger("Memory", "Calculating memory size", :info) }
        try {
            aResult = sqlite_execute(oDatabase, "SELECT COUNT(*) FROM memories")
            if type(aResult) = "LIST" and len(aResult) > 0{
                count = 0 + aResult[1][1][2]
                if bVerbose { logger("Memory", "Current memory size: " + count + " entries", :info) }
                return count
            }
        catch
            if bVerbose { logger("Memory", "Error getting memory size: " + cCatchError, :error) }
            return 0
        }

    func retrieveById nId
        if bVerbose { logger("Memory", "Retrieving memory by ID: " + nId, :info) }
        try {
            cSQL = "SELECT * FROM memories WHERE id = " + nId

            aResult = sqlite_execute(oDatabase, cSQL)
            if type(aResult) = "LIST" and len(aResult) > 0 {
                item = aResult[1]
                aMemory = [
                    :id = item[:id],
                    :content = item[:content],
                    :type = item[:type],
                    :priority = number(item[:priority]),
                    :timestamp = item[:timestamp],
                    :tags = JSON2List(item[:tags]),
                    :metadata = JSON2List(item[:metadata])
                ]

                if bVerbose { logger("Memory", "Memory retrieved successfully", :success) }
                return aMemory
            }

            if bVerbose { logger("Memory", "Memory not found", :warning) }
            return NULL
        catch
            if bVerbose { logger("Memory", "Error retrieving memory: " + cCatchError, :error) }
            return NULL
        }

    func retrieveByTag cTag, nLimit
        if nLimit = NULL { nLimit = 10 }

        if bVerbose { logger("Memory", "Retrieving memories by tag: " + cTag, :info) }
        try {
            cSQL = "SELECT * FROM memories WHERE tags LIKE '%" + cTag + "%' ORDER BY priority DESC, timestamp DESC LIMIT " + nLimit

            aResults = []
            aResult = sqlite_execute(oDatabase, cSQL)
            if type(aResult) = "LIST" {
                for item in aResult {
                    add(aResults, [
                        :id = item[:id],
                        :content = item[:content],
                        :type = item[:type],
                        :priority = number(item[:priority]),
                        :timestamp = item[:timestamp],
                        :tags = JSON2List(item[:tags]),
                        :metadata = JSON2List(item[:metadata])
                    ])
                }
            }

            if bVerbose { logger("Memory", "Found " + len(aResults) + " matching memories", :success) }
            return aResults
        catch
            if bVerbose { logger("Memory", "Error retrieving memories: " + cCatchError, :error) }
            return []
        }

    func deleteById nId
        if bVerbose { logger("Memory", "Deleting memory by ID: " + nId, :info) }
        try {
            cSQL = "DELETE FROM memories WHERE id = " + nId
            sqlite_execute(oDatabase, cSQL)

            if bVerbose { logger("Memory", "Memory deleted successfully", :success) }
            return true
        catch
            if bVerbose { logger("Memory", "Error deleting memory: " + cCatchError, :error) }
            return false
        }

    func getDatabase
        return oDatabase

    func close
        if bVerbose { logger("Memory", "Closing memory system", :info) }
        try {
            sqlite_close(oDatabase)
            if bVerbose { logger("Memory", "Memory system closed successfully", :success) }
       catch
            if bVerbose { logger("Memory", "Error closing memory system: " + cCatchError, :error) }
        }

    private

    # Properties
        oDatabase = null
        nCapacity = 1000

    func initDatabase cDatabasePath
        if bVerbose { logger("Memory", "Initializing database", :info) }
        try {
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDatabasePath)

            # Create memories table if not exists
            cSQL = "CREATE TABLE IF NOT EXISTS memories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    content TEXT,
                    type TEXT,
                    priority INTEGER,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    tags TEXT,
                    metadata TEXT
                )"
            sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Memory", "Database initialized successfully", :success) }
       catch
            if bVerbose { logger("Memory", "Database initialization failed: " + cCatchError, :error) }
        }

    func cleanupOldMemories
        if bVerbose { logger("Memory", "Cleaning up old memories", :info) }
        try {
            cSQL = "DELETE FROM memories WHERE id NOT IN (
                    SELECT id FROM memories
                    ORDER BY priority DESC, timestamp DESC
                    LIMIT " + nCapacity + ")"
            sqlite_execute(oDatabase, cSQL)
            if bVerbose { logger("Memory", "Old memories cleaned up successfully", :success) }
       catch
            if bVerbose { logger("Memory", "Error cleaning up old memories: " + cCatchError, :error) }
        }

    func isValidType cType
        if find([SHORT_TERM, LONG_TERM, EPISODIC, SEMANTIC], cType) {
            if bVerbose { logger("Memory", "Validating memory type", :info) }
            return true
        }
        if bVerbose { logger("Memory", "Invalid memory type", :error) }
        return false

    func isValidPriority nPriority
        if type(nPriority) = "NUMBER" and nPriority >= 1 and nPriority <= 10 {
            if bVerbose { logger("Memory", "Validating memory priority", :info) }
            return true
        }
        if bVerbose { logger("Memory", "Invalid memory priority", :error) }
        return false
