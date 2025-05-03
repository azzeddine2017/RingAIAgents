/*
    WebSocket Client Test
    Author: Azzeddine Remmal
    Date: 2025
    Description: Test client for the WebSocketLib implementation
*/

load "sockets.ring"

# Create a socket
sock = socket(AF_INET, SOCK_STREAM, 0)
if sock <= 0 {
    ? "Error: Failed to create socket"
    exit
}

# Connect to the server
if connect(sock, "127.0.0.1", 8082) < 0 {
    ? "Error: Failed to connect to server"
    exit
}

? "Connected to WebSocket server"

# Send a message
message = "Hello from WebSocket client!"
? "Sending: " + message
send(sock, message)

# Receive response
response = recv(sock, 1024)
? "Received: " + response

# Close the socket
close(sock)
? "Connection closed"
