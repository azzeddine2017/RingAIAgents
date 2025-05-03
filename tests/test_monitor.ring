Load "../src/core/monitor.ring"

# Test Monitor Class
func main
    ? "=== Testing Monitor Class ==="
    
    # Test initialization
    oMonitor = new PerformanceMonitor()//{bVerbose = true}
    assert(oMonitor != null, "Testing monitor initialization...")
    assert(!oMonitor.bIsRunning, "Testing initial monitoring state...")
    
    # Test monitoring control
    oMonitor.startMonitoring()
    assert(oMonitor.bIsRunning, "Testing monitoring start...")
    assert(oMonitor.nStartTime > 0, "Testing start time initialization...")
    
    oMonitor.stopMonitoring()
    assert(!oMonitor.bIsRunning, "Testing monitoring stop...")
    
    # Test metric recording
    oMonitor.startMonitoring()
    
    # Test recording with valid data
    assert(oMonitor.recordMetric("TestComponent", "cpu_usage", 45.5, []) != null, "Testing valid metric recording...")
    assert(oMonitor.recordMetric("TestComponent", "memory_usage", 1024.0, []) != null, "Testing another valid metric recording...")
    
    # Test recording with invalid data
    assert(oMonitor.recordMetric("", "", -1, "") != null, "Testing invalid metric recording...")
    
    # Test metric retrieval
    aMetrics = oMonitor.getMetricHistory("TestComponent", "cpu_usage")
    assert(type(aMetrics) = "LIST", "Testing metric history type...")
    assert(len(aMetrics) > 0, "Testing metric history count...")
    if len(aMetrics) > 0 {
        assert(aMetrics[1][:value] = 45.5, "Testing recorded metric value...")
        assert(type(aMetrics[1][:timestamp]) = "STRING", "Testing metric timestamp type...")
        assert(type(aMetrics[1][:metadata]) = "LIST", "Testing metric metadata type...")
    }
    
    # Test event recording
    # Test recording with valid data
    assert(oMonitor.recordEvent("TestComponent", "startup", "System started", []) != null, "Testing valid event recording...")
    assert(oMonitor.recordEvent("TestComponent", "error", "Test error occurred", []) != null, "Testing another valid event recording...")
    
    # Test recording with invalid data
    assert(oMonitor.recordEvent("", "", "", "") != null, "Testing invalid event recording...")
    
    # Test event retrieval
    aEvents = oMonitor.getEventHistory("TestComponent", "startup")
    assert(type(aEvents) = "LIST", "Testing event history type...")
    assert(len(aEvents) > 0, "Testing event history count...")
    if len(aEvents) > 0 {
        assert(type(aEvents[1][:timestamp]) = "STRING", "Testing event timestamp type...")
        assert(aEvents[1][:description] = "System started", "Testing event description...")
        assert(type(aEvents[1][:metadata]) = "LIST", "Testing event metadata type...")
    }
    
    # Test recording without monitoring
    oMonitor.stopMonitoring()
    assert(oMonitor.recordMetric("TestComponent", "test", 1.0, []) != null, "Testing metric recording when stopped...")
    assert(oMonitor.recordEvent("TestComponent", "test", "test", []) != null, "Testing event recording when stopped...")
    
    # Test cleanup
    oMonitor.destroy()
    
    ? "All Monitor tests passed successfully!"
