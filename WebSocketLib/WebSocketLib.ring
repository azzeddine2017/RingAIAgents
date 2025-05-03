/*
    WebSocketLib.ring
    Author: Azzeddine Remmal
    Date: 2025
    Description: Professional WebSocket implementation for Ring language
*/
load "stdlibCore.ring"
load "sockets.ring"
load "threads.ring"


func id2object oID {
    objects = getobjects()
    for o in objects {
        if objectid(o) = oID {
            return o
        }
    }
    return NULL
}

/*
    Function: WebSocketAcceptThread
    Description: Thread function to accept new connections
*/
func WebSocketAcceptThread oWebSocketID {
    # Get WebSocket object from ID
    oWebSocket = id2object(oWebSocketID)
    
    while oWebSocket.isRunning {
        # Accept new connection
        clientSocket = accept(oWebSocket.socket)
        
        if clientSocket > 0 {
            # Handle new client
            oWebSocket.handleNewClient(clientSocket)
        }
        
        # Small delay to prevent CPU hogging
        sleep(0.01)
    }
}

/*
    Function: WebSocketWorkerThread
    Description: Thread function for worker threads
*/
func WebSocketWorkerThread nThreadID, oWebSocketID {
    # Get WebSocket object from ID
    oWebSocket = id2object(oWebSocketID)
    
    if oWebSocket.debug {
        ? "Worker thread " + nThreadID + " started"
    }
    
    while oWebSocket.isRunning {
        mtx_lock(oWebSocket.mutexQueue)
        
        # Wait for tasks
        while oWebSocket.nTaskCount = 1 {
            cnd_wait(oWebSocket.condQueue, oWebSocket.mutexQueue)
        }
        
        # Get task from queue
        oTask = oWebSocket.aTaskQueue[1]
        
        # Shift queue
        for i = 1 to oWebSocket.nTaskCount - 1 {
            oWebSocket.aTaskQueue[i] = oWebSocket.aTaskQueue[i + 1]
        }
        oWebSocket.nTaskCount--
        
        mtx_unlock(oWebSocket.mutexQueue)
        
        # Check if termination task
        if oTask.taskType = :terminate {
            if oWebSocket.debug {
                ? "Worker thread " + nThreadID + " terminating"
            }
            exit
        }
        
        # Execute task
        oTask.execute()
    }
    
    if oWebSocket.debug {
        ? "Worker thread " + nThreadID + " ended"
    }
}

/*
    Class: WebSocket
    Description: Professional WebSocket server implementation
*/
class WebSocket {
    # Socket properties
    socket
    port = 8081
    host = "127.0.0.1"
    backlog = 5
    buffer = 4096
    
    # Callback functions
    onMessage 
    onConnect 
    onDisconnect 
    onError 
    
    # Server state
    isRunning = false
    clients = []
    
    # Debug mode
    debug = false
    
    # Thread pool properties
    THREAD_NUM = 4
    aThreads
    
    # Task queue
    nTaskCount = 1
    aTaskQueue
    mutexQueue
    condQueue
    
   

    /*
        Method: init
        Description: Initialize the WebSocket server
    */
    func init {
        # Initialize socket
        socket = socket(AF_INET, SOCK_STREAM, 0)
        if socket = null {
            if isMethod(onError) {
                kall onError("Failed to create socket")
            }
            if debug {
                ? "Error: Failed to create socket"
            }
            return
        }
        
        # Set socket options for reuse
        # This allows the server to restart quickly without "Address already in use" errors
        setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, 1)
        
        # Initialize thread pool
        aThreads = list(THREAD_NUM)
        aTaskQueue = list(1024)
        mutexQueue = new_mtx_t()
        condQueue = new_cnd_t()
        
        mtx_init(mutexQueue, false)
        cnd_init(condQueue)
        
        return self
    }
    
    /*
        Method: start
        Description: Start the WebSocket server
    */
    func start {
        # Bind socket to host and port
        if bind(socket, host, port) < 0 {
            if isMethod(onError) {
                kall onError("Failed to bind socket to " + host + ":" + port)
            }
            if debug {
                ? "Error: Failed to bind socket to " + host + ":" + port
            }
            return false
        }
        
        # Start listening for connections
        if listen(socket, backlog) < 0 {
            if isMethod(onError) {
                kall onError("Failed to listen on socket")
            }
            if debug {
                ? "Error: Failed to listen on socket"
            }
            return false
        }
        
        # Set server as running
        isRunning = true
        
        if debug {
            ? "WebSocket server started on " + host + ":" + port
        }
        
        # Start thread pool
        startThreadPool()
        
        # Start accept thread
        startAcceptThread()
        
        return true
    }
    
    /*
        Method: startThreadPool
        Description: Start the thread pool
    */
    func startThreadPool {
        for i = 1 to THREAD_NUM {
            aThreads[i] = new_thrd_t()
            selfid = objectid(self)
            if thrd_create(aThreads[i], "WebSocketWorkerThread(" + i + "," + selfid + ")") != 1 {
                if debug {
                    ? "Failed to create worker thread " + i
                }
            else
                if debug {
                    ? "Created worker thread " + i
                }
                thrd_detach(aThreads[i])
            }
        }
    }
    
    /*
        Method: startAcceptThread
        Description: Start a thread to accept new connections
    */
    func startAcceptThread {
        acceptThread = new_thrd_t()
        selfid = objectid(self)
        if thrd_create(acceptThread, "WebSocketAcceptThread(" + selfid  + ")") != 1 {
            if debug {
                ? "Failed to create accept thread"
            }
        else
            if debug {
                ? "Created accept thread"
            }
            thrd_detach(acceptThread)
        }
    }
    
    /*
        Method: submitTask
        Description: Submit a task to the thread pool
    */
    func submitTask oTask {
        mtx_lock(mutexQueue)
        aTaskQueue[nTaskCount] = oTask
        nTaskCount++
        mtx_unlock(mutexQueue)
        cnd_signal(condQueue)
    }
    
    /*
        Method: handleNewClient
        Description: Handle a new client connection
    */
    func handleNewClient clientSocket {
        # Add client to list
        add(clients, clientSocket)
        
        if debug {
            ? "New client connected: " + clientSocket
        }
        
        # Call onConnect callback if defined
        if isMethod(onConnect) {
            kall onConnect(clientSocket)
        }
        
        # Create a task to handle client messages
        oTask = new WebSocketTask {
            taskType = :handleClient
            clientSocket = clientSocket
            webSocket = self
        }
        
        # Submit the task to the thread pool
        submitTask(oTask)
    }
    
    /*
        Method: handleClientMessage
        Description: Handle a message from a client
    */
    func handleClientMessage clientSocket {
        # Receive data from client
        message = recv(clientSocket, buffer)
        
        # Check if client disconnected
        if len(message) <= 0 {
            # Remove client from list
            pos = find(clients, clientSocket)
            if pos > 0 {
                del(clients, pos)
            }
            
            # Close socket
            close(clientSocket)
            
            if debug {
                ? "Client disconnected: " + clientSocket
            }
            
            # Call onDisconnect callback if defined
            if isMethod(onDisconnect) {
                kall onDisconnect(clientSocket)
            }
            
            return false
        }
        
        # Process WebSocket frame
        processedMessage = processWebSocketFrame(message)
        
        if debug {
            ? "Received message from client " + clientSocket + ": " + processedMessage
        }
        
        # Call onMessage callback if defined
        if isMethod(onMessage) {
            kall onMessage(processedMessage, clientSocket)
        }
        
        # Create a task to handle the next message
        oTask = new WebSocketTask {
            taskType = :handleClient
            clientSocket = clientSocket
            webSocket = self
        }
        
        # Submit the task to the thread pool
        submitTask(oTask)
        
        return true
    }
    
    /*
        Method: processWebSocketFrame
        Description: Process a WebSocket frame and extract the message
    */
    func processWebSocketFrame message {
        # This is a simplified implementation
        # A full implementation would handle WebSocket protocol framing
        # including masking, opcodes, etc.
        
        # For now, we'll just return the raw message
        return message
    }
    
    /*
        Method: createWebSocketFrame
        Description: Create a WebSocket frame from a message
    */
    func createWebSocketFrame message {
        # This is a simplified implementation
        # A full implementation would create proper WebSocket frames
        # including masking, opcodes, etc.
        
        # For now, we'll just return the raw message
        return message
    }
    
    /*
        Method: send
        Description: Send a message to a specific client
    */
    func send clientSocket, message {
        # Create WebSocket frame
        frame = createWebSocketFrame(message)
        
        # Send frame to client
        result = send(clientSocket, frame)
        
        if result < 0 {
            if isMethod(onError) {
                kall onError("Failed to send message to client " + clientSocket)
            }
            if debug {
                ? "Error: Failed to send message to client " + clientSocket
            }
            return false
        }
        
        return true
    }
    
    /*
        Method: broadcast
        Description: Send a message to all connected clients
    */
    func broadcast message {
        # Create WebSocket frame once
        frame = createWebSocketFrame(message)
        
        # Send to all clients
        for clientSocket in clients {
            send(clientSocket, frame)
        }
        
        return true
    }
    
    /*
        Method: stop
        Description: Stop the WebSocket server
    */
    func stop {
        # Set server as not running
        isRunning = false
        
        # Submit termination tasks to all threads
        for i = 1 to THREAD_NUM {
            oTask = new WebSocketTask {
                taskType = :terminate
            }
            submitTask(oTask)
        }
        
        # Close all client connections
        for clientSocket in clients {
            close(clientSocket)
        }
        
        # Clear clients list
        clients = []
        
        # Close server socket
        close(socket)
        
        # Clean up thread pool resources
        destroy_mtx_t(mutexQueue)
        destroy_cnd_t(condQueue)
        
        if debug {
            ? "WebSocket server stopped"
        }
        
        return true
    }
    
    /*
        Method: isMethod
        Description: Check if a callback is a valid method
    */
    func isMethod callback {
        if callback != NULL and type(callback) = "STRING" {
            return true
        }
        return false
    }
    
    /*
        Method: kall
        Description: kall a callback method
    */
    func kall callback, p1, p2, p3 {
        # Check if callback is a string (function name)
        if isString(callback) {
            # Build the function call string
            cCall = callback
            
            # Add parameters if provided
            if p1 != NULL and p2 != NULL and p3 != NULL {
                if isString(p1) { p1 = '\"' + p1 + '\"' }
                if isString(p2) { p2 = '\"' + p2 + '\"' }
                if isString(p3) { p3 = '\"' + p3 + '\"' }
                cCall += "(" + p1 + "," + p2 + "," + p3 + ")"
            elseif p1 != NULL and p2 != NULL 
                if isString(p1) { p1 = '\"' + p1 + '\"' }
                if isString(p2) { p2 = '\"' + p2 + '\"' }
                cCall += "(" + p1 + "," + p2 + ")"
            elseif p1 != NULL 
                if isString(p1) { p1 = '\"' + p1 + '\"' }
                cCall += "(" + p1 + ")"
            else
                cCall += "()"
            }
            
            # Evaluate the function call
            eval(cCall)
        }
    }
}

/*
    Class: WebSocketTask
    Description: Task for the WebSocket thread pool
*/
class WebSocketTask {
    # Task type
    taskType = NULL  # :handleClient, :terminate
    
    # Task data
    clientSocket = NULL
    webSocket = NULL
    
    /*
        Method: execute
        Description: Execute the task
    */
    func execute {
        switch taskType {
            case :handleClient
                webSocket.handleClientMessage(clientSocket)
                
            case :terminate
                # Nothing to do, just a signal to terminate the thread
        }
    }
         
}
