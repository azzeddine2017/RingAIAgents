load "src/security/SessionManager.ring"

? "=== Testing Session Expiry Calculations ==="

oSession = new SessionManager()

# Test different expiry durations
aTestDurations = [
    300,        # 5 minutes
    3600,       # 1 hour
    7200,       # 2 hours
    86400,      # 1 day
    172800      # 2 days
]

for nDuration in aTestDurations {
    ? nl + "Testing duration: " + nDuration + " seconds"
    
    # Set the session expiry
    oSession.nSessionExpiry = nDuration
    
    # Calculate expiry
    cExpiry = oSession.calculateExpiry()
    ? "Current time: " + date() + " " + time()
    ? "Expiry time:  " + cExpiry
    
    # Test if session is expired
    ? "Session expired: " + oSession.isSessionExpired(cExpiry)
    ? "----------------------------------------"
}