/**
 * RingAI Agents - Chat History JavaScript
 * Author: Azzeddine Remmal
 * Date: 2025
 */

// Global variables
let currentConversations = [];
let selectedConversationId = null;

/**
 * Load chat history from server
 */
function loadChatHistory() {
    // Show loading indicator
    $('#chat-history-list').html('<p>Loading conversations...</p>');
    
    // Send request to server
    $.ajax({
        url: '/ai/chat/history',
        type: 'POST',
        data: {
            agent_id: 0 // Get all conversations
        },
        success: function(response) {
            if (response.status === 'success' && response.conversations && response.conversations.length > 0) {
                // Store conversations
                currentConversations = response.conversations;
                
                // Display conversations
                displayConversations(currentConversations);
            } else {
                $('#chat-history-list').html('<p>No conversations found.</p>');
            }
        },
        error: function() {
            $('#chat-history-list').html('<p>Failed to load conversations.</p>');
        }
    });
}

/**
 * Display conversations in the list
 * @param {Array} conversations List of conversations
 */
function displayConversations(conversations) {
    const historyContainer = document.getElementById('chat-history-list');
    
    // Clear history container
    historyContainer.innerHTML = '';
    
    if (conversations.length === 0) {
        historyContainer.innerHTML = '<p>No conversations found.</p>';
        return;
    }
    
    // Group conversations by date
    const conversationsByDate = {};
    
    for (const conversation of conversations) {
        const date = new Date(conversation.timestamp).toISOString().split('T')[0];
        if (!conversationsByDate[date]) {
            conversationsByDate[date] = [];
        }
        conversationsByDate[date].push(conversation);
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
            // Create preview from prompt
            const preview = conversation.prompt.substring(0, 50) + '...';
            
            const historyItem = document.createElement('div');
            historyItem.classList.add('history-item');
            historyItem.dataset.conversationId = conversation.id;
            historyItem.onclick = function() {
                selectConversation(conversation.id);
            };
            
            // Get agent name
            const agentId = conversation.agent_id || 0;
            const agentName = $('#agent-filter option[value="' + agentId + '"]').text() || 'AI Assistant';
            
            historyItem.innerHTML = `
                <div class="d-flex justify-content-between">
                    <strong>${agentName}</strong>
                    <span class="time">${formatTime(conversation.timestamp)}</span>
                </div>
                <div class="preview">${preview}</div>
            `;
            
            historyContainer.appendChild(historyItem);
        }
    }
}

/**
 * Select a conversation to display details
 * @param {string} conversationId Conversation ID
 */
function selectConversation(conversationId) {
    // Update selected conversation
    selectedConversationId = conversationId;
    
    // Highlight selected conversation
    $('.history-item').removeClass('selected');
    $('.history-item[data-conversation-id="' + conversationId + '"]').addClass('selected');
    
    // Find conversation
    const conversation = currentConversations.find(c => c.id === conversationId);
    
    if (!conversation) {
        return;
    }
    
    // Get agent name
    const agentId = conversation.agent_id || 0;
    const agentName = $('#agent-filter option[value="' + agentId + '"]').text() || 'AI Assistant';
    
    // Update conversation title
    $('#conversation-title').text('Conversation with ' + agentName);
    
    // Display conversation details
    const detailsContainer = document.getElementById('conversation-details');
    
    // Create HTML for conversation
    let html = `
        <div class="conversation-info mb-3">
            <p><strong>Date:</strong> ${new Date(conversation.timestamp).toLocaleString()}</p>
            <p><strong>Agent:</strong> ${agentName}</p>
        </div>
        <div class="conversation-messages">
    `;
    
    // Add user message
    html += `
        <div class="message user-message">
            ${conversation.prompt.replace(/\n/g, '<br>')}
            <div class="message-time">${formatTime(conversation.timestamp)}</div>
        </div>
    `;
    
    // Add AI response
    html += `
        <div class="message ai-message">
            ${conversation.response.replace(/\n/g, '<br>')}
            <div class="message-time">${formatTime(conversation.timestamp)}</div>
        </div>
    `;
    
    html += '</div>';
    
    detailsContainer.innerHTML = html;
}

/**
 * Filter conversations based on selected agent and date
 */
function filterConversations() {
    const agentId = $('#agent-filter').val();
    const dateFilter = $('#date-filter').val();
    
    // Filter by agent
    let filteredConversations = currentConversations;
    
    if (agentId !== '0') {
        filteredConversations = filteredConversations.filter(c => 
            c.agent_id === parseInt(agentId) || c.agent_id === agentId
        );
    }
    
    // Filter by date
    if (dateFilter !== 'all') {
        const now = new Date();
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        switch (dateFilter) {
            case 'today':
                filteredConversations = filteredConversations.filter(c => {
                    const date = new Date(c.timestamp);
                    return date >= today;
                });
                break;
            case 'yesterday':
                filteredConversations = filteredConversations.filter(c => {
                    const date = new Date(c.timestamp);
                    return date >= yesterday && date < today;
                });
                break;
            case 'week':
                const weekStart = new Date(today);
                weekStart.setDate(today.getDate() - today.getDay());
                filteredConversations = filteredConversations.filter(c => {
                    const date = new Date(c.timestamp);
                    return date >= weekStart;
                });
                break;
            case 'month':
                const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
                filteredConversations = filteredConversations.filter(c => {
                    const date = new Date(c.timestamp);
                    return date >= monthStart;
                });
                break;
        }
    }
    
    // Display filtered conversations
    displayConversations(filteredConversations);
}

/**
 * Search conversations by text
 */
function searchConversations() {
    const searchText = $('#search-input').val().trim().toLowerCase();
    
    if (searchText === '') {
        // Reset to all conversations
        displayConversations(currentConversations);
        return;
    }
    
    // Filter conversations by search text
    const filteredConversations = currentConversations.filter(c => 
        c.prompt.toLowerCase().includes(searchText) || 
        c.response.toLowerCase().includes(searchText)
    );
    
    // Display filtered conversations
    displayConversations(filteredConversations);
}

/**
 * Export selected conversation to file
 */
function exportConversation() {
    if (!selectedConversationId) {
        alert('Please select a conversation to export.');
        return;
    }
    
    // Find conversation
    const conversation = currentConversations.find(c => c.id === selectedConversationId);
    
    if (!conversation) {
        return;
    }
    
    // Get agent name
    const agentId = conversation.agent_id || 0;
    const agentName = $('#agent-filter option[value="' + agentId + '"]').text() || 'AI Assistant';
    
    // Create file content
    const timestamp = new Date(conversation.timestamp).toISOString().replace(/:/g, '-').replace(/\..+/, '');
    const filename = `chat_${agentName.replace(/\s+/g, '_')}_${timestamp}.txt`;
    
    let content = `Chat with ${agentName}\n`;
    content += `Date: ${new Date(conversation.timestamp).toLocaleString()}\n\n`;
    content += `You:\n${conversation.prompt}\n\n`;
    content += `${agentName}:\n${conversation.response}\n`;
    
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
 * Delete selected conversation
 */
function deleteConversation() {
    if (!selectedConversationId) {
        alert('Please select a conversation to delete.');
        return;
    }
    
    if (!confirm('Are you sure you want to delete this conversation? This action cannot be undone.')) {
        return;
    }
    
    // TODO: Implement server-side deletion
    alert('Deletion functionality will be implemented in a future version.');
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
