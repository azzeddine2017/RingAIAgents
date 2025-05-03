/**
 * RingAI Agents - Chat Interface JavaScript
 * Author: Azzeddine Remmal
 * Date: 2025
 */

// Global variables
let currentConversation = [];
let currentAgentId = "0";

$(document).ready(function() {
    // Scroll to bottom of chat
    scrollToBottom();

    // Update chat title when agent is selected
    $('#agent-selector').change(function() {
        const agentId = $(this).val();
        currentAgentId = agentId;
        const agentName = $(this).find('option:selected').text();

        // Update UI
        $('#chat-title').text(agentName);
        $('#agent-status').text('Ready to chat');

        // Clear chat except for the first welcome message
        $('#chat-messages').html(`
            <div class='ai-message message'>
                Hello! I'm ${agentName}. How can I help you today?
                <div class='message-time'>${getCurrentTime()}</div>
            </div>
        `);

        // Reset conversation history
        currentConversation = [{
            role: 'ai',
            content: `Hello! I'm ${agentName}. How can I help you today?`,
            timestamp: getCurrentTime()
        }];

        // Load previous conversations with this agent
        loadAgentConversations(agentId);
    });

    // Focus on input field
    $('#message-input').focus();
});

/**
 * Get current time in HH:MM format
 * @returns {string} Current time
 */
function getCurrentTime() {
    const now = new Date();
    return now.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}

/**
 * Get current date in YYYY-MM-DD format
 * @returns {string} Current date
 */
function getCurrentDate() {
    const now = new Date();
    return now.toISOString().split('T')[0];
}

/**
 * Scroll chat to bottom
 */
function scrollToBottom() {
    const chatMessages = document.getElementById('chat-messages');
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

/**
 * Send message to server
 * @param {Event} event Form submit event
 */
function sendMessage(event) {
    event.preventDefault();

    const messageInput = document.getElementById('message-input');
    const message = messageInput.value.trim();

    if (message === '') return;

    // Add user message to chat
    addMessage(message, 'user');
    messageInput.value = '';

    // Add to conversation history
    currentConversation.push({
        role: 'user',
        content: message,
        timestamp: getCurrentTime()
    });

    // Show typing indicator
    document.getElementById('typing-indicator').style.display = 'block';
    scrollToBottom();

    // Get selected agent
    const agentId = currentAgentId;

    // Send message to server
    $.ajax({
        url: '/ai/chat',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            prompt: message,
            parameters: {
                agent_id: agentId
            }
        }),
        success: function(response) {
            // Hide typing indicator
            document.getElementById('typing-indicator').style.display = 'none';

            // Add AI response to chat
            if (response.status === 'success') {
                addMessage(response.response, 'ai');

                // Add to conversation history
                currentConversation.push({
                    role: 'ai',
                    content: response.response,
                    timestamp: getCurrentTime()
                });

                // Save conversation to local storage
                saveConversation();
            } else {
                addMessage('Sorry, I encountered an error: ' + response.message, 'ai');
            }
        },
        error: function() {
            // Hide typing indicator
            document.getElementById('typing-indicator').style.display = 'none';

            // Add error message
            addMessage('Sorry, I encountered a network error. Please try again.', 'ai');
        }
    });
}

/**
 * Add message to chat
 * @param {string} message Message content
 * @param {string} sender Message sender ('user' or 'ai')
 */
function addMessage(message, sender) {
    const chatMessages = document.getElementById('chat-messages');
    const messageElement = document.createElement('div');
    messageElement.classList.add('message');
    messageElement.classList.add(sender + '-message');

    // Replace newlines with <br> tags
    const formattedMessage = message.replace(/\n/g, '<br>');
    messageElement.innerHTML = formattedMessage;

    // Add timestamp
    const timeElement = document.createElement('div');
    timeElement.classList.add('message-time');
    timeElement.textContent = getCurrentTime();
    messageElement.appendChild(timeElement);

    chatMessages.appendChild(messageElement);
    scrollToBottom();
}

/**
 * Save current conversation to local storage
 */
function saveConversation() {
    if (currentConversation.length <= 1) return; // Don't save empty conversations

    const conversations = JSON.parse(localStorage.getItem('chatConversations') || '{}');
    const agentId = currentAgentId;
    const agentName = $('#agent-selector option:selected').text();
    const timestamp = new Date().toISOString();
    const conversationId = 'conv_' + timestamp.replace(/[^0-9]/g, '');

    // Create conversation object
    const conversation = {
        id: conversationId,
        agentId: agentId,
        agentName: agentName,
        timestamp: timestamp,
        messages: currentConversation,
        preview: currentConversation[currentConversation.length - 2].content.substring(0, 50) + '...'
    };

    // Add to conversations
    if (!conversations[agentId]) {
        conversations[agentId] = [];
    }

    // Limit to 10 conversations per agent
    if (conversations[agentId].length >= 10) {
        conversations[agentId].shift();
    }

    conversations[agentId].push(conversation);

    // Save to local storage
    localStorage.setItem('chatConversations', JSON.stringify(conversations));

    // Update history display
    loadChatHistory();
}

/**
 * Load chat history from local storage and server
 */
function loadChatHistory() {
    // First load from local storage
    loadLocalChatHistory();

    // Then load from server
    loadServerChatHistory();
}

/**
 * Load chat history from local storage
 */
function loadLocalChatHistory() {
    const conversations = JSON.parse(localStorage.getItem('chatConversations') || '{}');
    const historyContainer = document.getElementById('chat-history');

    // Clear history container
    historyContainer.innerHTML = '';

    // Check if there are any conversations
    let hasConversations = false;
    for (const agentId in conversations) {
        if (conversations[agentId].length > 0) {
            hasConversations = true;
            break;
        }
    }

    if (!hasConversations) {
        historyContainer.innerHTML = '<p>Your recent conversations will appear here.</p>';
        return;
    }

    // Group conversations by date
    const conversationsByDate = {};

    for (const agentId in conversations) {
        for (const conversation of conversations[agentId]) {
            const date = conversation.timestamp.split('T')[0];
            if (!conversationsByDate[date]) {
                conversationsByDate[date] = [];
            }
            conversationsByDate[date].push(conversation);
        }
    }

    // Sort dates in descending order
    const sortedDates = Object.keys(conversationsByDate).sort().reverse();

    // Create history items
    for (const date of sortedDates) {
        // Add date header
        const dateHeader = document.createElement('h6');
        dateHeader.classList.add('mt-3', 'mb-2');
        dateHeader.textContent = formatDate(date);
        historyContainer.appendChild(dateHeader);

        // Add conversations for this date
        for (const conversation of conversationsByDate[date]) {
            const historyItem = document.createElement('div');
            historyItem.classList.add('history-item');
            historyItem.dataset.conversationId = conversation.id;
            historyItem.dataset.agentId = conversation.agentId;
            historyItem.dataset.source = 'local';
            historyItem.onclick = function() {
                loadConversation(conversation.id, conversation.agentId, 'local');
            };

            historyItem.innerHTML = `
                <div class="d-flex justify-content-between">
                    <strong>${conversation.agentName}</strong>
                    <span class="time">${formatTime(conversation.timestamp)}</span>
                </div>
                <div class="preview">${conversation.preview}</div>
            `;

            historyContainer.appendChild(historyItem);
        }
    }
}

/**
 * Load chat history from server
 */
function loadServerChatHistory() {
    // Get selected agent
    const agentId = currentAgentId;

    // Show loading indicator
    const historyContainer = document.getElementById('chat-history');
    if (historyContainer.innerHTML === '<p>Your recent conversations will appear here.</p>') {
        historyContainer.innerHTML = '<p>Loading conversations from server...</p>';
    }

    // Send request to server
    $.ajax({
        url: '/ai/chat/history',
        type: 'POST',
        data: {
            agent_id: agentId
        },
        success: function(response) {
            if (response.status === 'success' && response.conversations && response.conversations.length > 0) {
                // Group conversations by date
                const conversationsByDate = {};

                for (const conversation of response.conversations) {
                    const date = new Date(conversation.timestamp).toISOString().split('T')[0];
                    if (!conversationsByDate[date]) {
                        conversationsByDate[date] = [];
                    }
                    conversationsByDate[date].push(conversation);
                }

                // Sort dates in descending order
                const sortedDates = Object.keys(conversationsByDate).sort().reverse();

                // Check if history container is empty
                if (historyContainer.innerHTML === '<p>Loading conversations from server...</p>' ||
                    historyContainer.innerHTML === '<p>Your recent conversations will appear here.</p>') {
                    historyContainer.innerHTML = '';
                }

                // Create history items
                for (const date of sortedDates) {
                    // Check if date header already exists
                    let dateHeader = Array.from(historyContainer.querySelectorAll('h6')).find(h => h.textContent === formatDate(date));

                    if (!dateHeader) {
                        // Add date header
                        dateHeader = document.createElement('h6');
                        dateHeader.classList.add('mt-3', 'mb-2');
                        dateHeader.textContent = formatDate(date);
                        historyContainer.appendChild(dateHeader);
                    }

                    // Add conversations for this date
                    for (const conversation of conversationsByDate[date]) {
                        // Create preview from prompt
                        const preview = conversation.prompt.substring(0, 50) + '...';

                        const historyItem = document.createElement('div');
                        historyItem.classList.add('history-item', 'server-history');
                        historyItem.dataset.conversationId = conversation.id;
                        historyItem.dataset.agentId = conversation.agent_id || agentId;
                        historyItem.dataset.source = 'server';
                        historyItem.onclick = function() {
                            loadServerConversation(conversation.id);
                        };

                        const agentName = $('#agent-selector option[value="' + (conversation.agent_id || agentId) + '"]').text() || 'AI Assistant';

                        historyItem.innerHTML = `
                            <div class="d-flex justify-content-between">
                                <strong>${agentName}</strong>
                                <span class="time">${formatTime(conversation.timestamp)}</span>
                            </div>
                            <div class="preview">${preview}</div>
                        `;

                        // Insert after date header
                        dateHeader.after(historyItem);
                    }
                }
            } else if (historyContainer.innerHTML === '<p>Loading conversations from server...</p>') {
                historyContainer.innerHTML = '<p>No conversations found on server.</p>';
            }
        },
        error: function() {
            if (historyContainer.innerHTML === '<p>Loading conversations from server...</p>') {
                historyContainer.innerHTML = '<p>Failed to load conversations from server.</p>';
            }
        }
    });
}

/**
 * Load agent-specific conversations
 * @param {string} agentId Agent ID
 */
function loadAgentConversations(agentId) {
    const conversations = JSON.parse(localStorage.getItem('chatConversations') || '{}');

    if (!conversations[agentId] || conversations[agentId].length === 0) {
        return;
    }

    // Sort conversations by timestamp (newest first)
    conversations[agentId].sort((a, b) => {
        return new Date(b.timestamp) - new Date(a.timestamp);
    });

    // Get latest conversation
    const latestConversation = conversations[agentId][conversations[agentId].length - 1];

    // Load conversation
    loadConversation(latestConversation.id, agentId);
}

/**
 * Load a specific conversation
 * @param {string} conversationId Conversation ID
 * @param {string} agentId Agent ID
 * @param {string} source Source of conversation ('local' or 'server')
 */
function loadConversation(conversationId, agentId, source = 'local') {
    if (source === 'local') {
        loadLocalConversation(conversationId, agentId);
    } else {
        loadServerConversation(conversationId);
    }
}

/**
 * Load a specific conversation from local storage
 * @param {string} conversationId Conversation ID
 * @param {string} agentId Agent ID
 */
function loadLocalConversation(conversationId, agentId) {
    const conversations = JSON.parse(localStorage.getItem('chatConversations') || '{}');

    if (!conversations[agentId]) {
        return;
    }

    // Find conversation
    const conversation = conversations[agentId].find(c => c.id === conversationId);

    if (!conversation) {
        return;
    }

    // Select agent in dropdown
    $('#agent-selector').val(agentId);
    currentAgentId = agentId;

    // Update UI
    $('#chat-title').text(conversation.agentName);
    $('#agent-status').text('Ready to chat');

    // Clear chat
    $('#chat-messages').empty();

    // Add messages
    for (const message of conversation.messages) {
        const messageElement = document.createElement('div');
        messageElement.classList.add('message');
        messageElement.classList.add(message.role + '-message');

        // Replace newlines with <br> tags
        const formattedMessage = message.content.replace(/\n/g, '<br>');
        messageElement.innerHTML = formattedMessage;

        // Add timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        timeElement.textContent = message.timestamp;
        messageElement.appendChild(timeElement);

        $('#chat-messages').append(messageElement);
    }

    // Set current conversation
    currentConversation = [...conversation.messages];

    // Scroll to bottom
    scrollToBottom();
}

/**
 * Load a specific conversation from server
 * @param {string} conversationId Conversation ID
 */
function loadServerConversation(conversationId) {
    // Show loading indicator
    $('#agent-status').text('Loading conversation...');

    // Send request to server
    $.ajax({
        url: '/ai/chat/history',
        type: 'POST',
        data: {
            conversation_id: conversationId
        },
        success: function(response) {
            if (response.status === 'success' && response.conversations && response.conversations.length > 0) {
                const conversation = response.conversations[0];

                // Select agent in dropdown if available
                if (conversation.agent_id) {
                    $('#agent-selector').val(conversation.agent_id);
                    currentAgentId = conversation.agent_id;
                }

                // Get agent name
                const agentName = $('#agent-selector option:selected').text();

                // Update UI
                $('#chat-title').text(agentName);
                $('#agent-status').text('Conversation loaded from server');

                // Clear chat
                $('#chat-messages').empty();

                // Create messages
                const userMessage = document.createElement('div');
                userMessage.classList.add('message', 'user-message');
                userMessage.innerHTML = conversation.prompt.replace(/\n/g, '<br>');

                const userTimeElement = document.createElement('div');
                userTimeElement.classList.add('message-time');
                userTimeElement.textContent = formatTime(conversation.timestamp);
                userMessage.appendChild(userTimeElement);

                const aiMessage = document.createElement('div');
                aiMessage.classList.add('message', 'ai-message');
                aiMessage.innerHTML = conversation.response.replace(/\n/g, '<br>');

                const aiTimeElement = document.createElement('div');
                aiTimeElement.classList.add('message-time');
                aiTimeElement.textContent = formatTime(conversation.timestamp);
                aiMessage.appendChild(aiTimeElement);

                // Add messages to chat
                $('#chat-messages').append(userMessage);
                $('#chat-messages').append(aiMessage);

                // Set current conversation
                currentConversation = [
                    {
                        role: 'user',
                        content: conversation.prompt,
                        timestamp: formatTime(conversation.timestamp)
                    },
                    {
                        role: 'ai',
                        content: conversation.response,
                        timestamp: formatTime(conversation.timestamp)
                    }
                ];

                // Scroll to bottom
                scrollToBottom();
            } else {
                $('#agent-status').text('Failed to load conversation');
            }
        },
        error: function() {
            $('#agent-status').text('Failed to load conversation');
        }
    });
}

/**
 * Clear current chat
 */
function clearChat() {
    const agentId = currentAgentId;
    const agentName = $('#agent-selector option:selected').text();

    // Clear chat except for the first welcome message
    $('#chat-messages').html(`
        <div class='ai-message message'>
            Hello! I'm ${agentName}. How can I help you today?
            <div class='message-time'>${getCurrentTime()}</div>
        </div>
    `);

    // Reset conversation history
    currentConversation = [{
        role: 'ai',
        content: `Hello! I'm ${agentName}. How can I help you today?`,
        timestamp: getCurrentTime()
    }];

    // Focus on input field
    $('#message-input').focus();
}

/**
 * Save current chat to file
 */
function saveChat() {
    if (currentConversation.length <= 1) {
        alert('No conversation to save.');
        return;
    }

    const agentName = $('#agent-selector option:selected').text();
    const timestamp = new Date().toISOString().replace(/:/g, '-').replace(/\..+/, '');
    const filename = `chat_${agentName.replace(/\s+/g, '_')}_${timestamp}.txt`;

    let content = `Chat with ${agentName}\n`;
    content += `Date: ${new Date().toLocaleString()}\n\n`;

    for (const message of currentConversation) {
        const sender = message.role === 'user' ? 'You' : agentName;
        content += `${sender} (${message.timestamp}):\n${message.content}\n\n`;
    }

    // Create download link
    const element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(content));
    element.setAttribute('download', filename);
    element.style.display = 'none';

    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
}

/**
 * Format date for display
 * @param {string} dateString Date string in YYYY-MM-DD format
 * @returns {string} Formatted date
 */
function formatDate(dateString) {
    const date = new Date(dateString);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (dateString === today.toISOString().split('T')[0]) {
        return 'Today';
    } else if (dateString === yesterday.toISOString().split('T')[0]) {
        return 'Yesterday';
    } else {
        return date.toLocaleDateString();
    }
}

/**
 * Format time for display
 * @param {string} timeString ISO timestamp
 * @returns {string} Formatted time
 */
function formatTime(timeString) {
    const date = new Date(timeString);
    return date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}
