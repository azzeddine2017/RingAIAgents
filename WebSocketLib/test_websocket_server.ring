/*
    WebSocket Test Server
    Author: Azzeddine Remmal
    Date: 2025
    Description: Test the WebSocketLib implementation
*/

load "WebSocketLib.ring"




# Create a WebSocket server
oWebSocket = new WebSocket() {
    port = 8082
    debug = true
    
    # Define callback functions
    onMessage = "handleMessage"
    onConnect = "handleConnect"
    onDisconnect = "handleDisconnect"
    onError = "handleError"
}

# Start the server
oWebSocket.start()

? "WebSocket server started on port 8082"
? "Press Ctrl+C to exit"

# Keep the application running
while true {
    sleep(1)
}

# Callback functions must be defined before they are used
func handleMessage message, clientSocket {
    ? "Received message: " + message
    ? "From client: " + clientSocket
    
    # Echo the message back to the client
    oWebSocket.send(clientSocket, "Echo: " + message)
}

func handleConnect clientSocket {
    ? "Client connected: " + clientSocket
}

func handleDisconnect clientSocket {
    ? "Client disconnected: " + clientSocket
}

func handleError errorMessage {
    ? "Error: " + errorMessage
}
