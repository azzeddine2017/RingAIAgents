Load "../src/core/memory.ring"
Load "../src/utils/helpers.ring"

# Test Memory Class
func main
    ? "=== Testing Memory Class ==="
    
    # Test initialization
    oMemory = new Memory()//{bVerbose = true}
    assert(oMemory != null, "Testing memory initialization...")
    
    # Test memory storage
    assert(oMemory.store(:test_content, :short_term, 5, [:test="text"], []), "Testing basic memory storage...")
    assert(oMemory.getSize() > 0 , "Testing memory size after storage...")
    
    # Test memory retrieval
    aResults = oMemory.retrieve(:test_content, :short_term, 10)
    assert(len(aResults) = 1, "Testing memory retrieval count...")
    assert(aResults[1][:content] = :test_content, "Testing retrieved memory content...")
    assert(aResults[1][:type] = :short_term, "Testing retrieved memory type...")
    assert(aResults[1][:priority] = 5, "Testing retrieved memory priority...")
    assert(type(aResults[1][:tags]) = "LIST", "Testing retrieved memory tags type...")
    assert(aResults[1][:tags] = :test="text", "Testing retrieved memory tags content...")
    
    # Test memory types
    assert(oMemory.store("long term memory", :long_term, 8, [], []), "Testing long-term memory storage...")
    assert(oMemory.store("episodic memory", :episodic, 6, [], []), "Testing episodic memory storage...")
    assert(oMemory.store("semantic memory", :semantic, 7, [], []), "Testing semantic memory storage...")
    
    aLongTerm = oMemory.retrieve("long term", :long_term, 1)
    assert(len(aLongTerm) = 1, "Testing long-term memory retrieval...")
    
    aEpisodic = oMemory.retrieve("episodic", :episodic, 1)
    assert(len(aEpisodic) = 1, "Testing episodic memory retrieval...")
    
    aSemantic = oMemory.retrieve("semantic", :semantic, 1)
    assert(len(aSemantic) = 1, "Testing semantic memory retrieval...")
    
    # Test memory search by tags
    assert(oMemory.store("tagged memory", :short_term, 5, ["important", "test"], []), "Testing memory storage with multiple tags...")
    aTagged = oMemory.searchByTags(["important"], 10)
    ? aTagged
    assert(len(aTagged) = 1, "Testing memory search by tags...")
    
    # Test memory priority update
    assert(oMemory.updatePriority(1, 9), "Testing memory priority update...")
    aHighPriority = oMemory.retrieve("test", :short_term, 1)
    assert(aHighPriority[:priority] = 9, "Testing updated memory priority...")
    
    # Test memory consolidation
    oMemory.consolidateMemories()
    aConsolidated = oMemory.retrieve("", :long_term, 10)
    assert(len(aConsolidated) >= 1, "Testing memory consolidation...")
    
    # Test memory cleanup
    nInitialSize = oMemory.getSize()
    oMemory.clear()
    assert(oMemory.getSize() = 0, "Testing memory clear...")
    
    # Test memory capacity
    for i = 1 to 1100 {  # Try to exceed default capacity of 1000
        oMemory.store("memory " + i, :short_term, 1, [], [])
    }
    assert(oMemory.getSize() <= 1000, "Testing memory capacity limit...")
    
    # Test invalid memory operations
    assert(!oMemory.store("", "", -1, "", ""), "Testing invalid memory storage...")
    assert(!oMemory.updatePriority(-1, 100), "Testing invalid priority update...")
    assert(len(oMemory.retrieve("nonexistent", "", 10)) = 0, "Testing retrieval of non-existent memory...")
    
    # Test database cleanup
    oMemory.close()
    
    ? "All Memory tests passed successfully!"
