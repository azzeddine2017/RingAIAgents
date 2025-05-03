/**
 * RingAI Agents - API Keys Management JavaScript
 * Author: Azzeddine Remmal
 * Date: 2025
 */

// Global variables
let apiKeys = [];
let modelsByProvider = {
    'google': [
        { value: 'gemini-1.5-flash', name: 'Gemini 1.5 Flash' },
        { value: 'gemini-1.5-pro', name: 'Gemini 1.5 Pro' },
        { value: 'gemini-1.0-pro', name: 'Gemini 1.0 Pro' }
    ],
    'openai': [
        { value: 'gpt-4o', name: 'GPT-4o' },
        { value: 'gpt-4-turbo', name: 'GPT-4 Turbo' },
        { value: 'gpt-3.5-turbo', name: 'GPT-3.5 Turbo' }
    ],
    'anthropic': [
        { value: 'claude-3-opus', name: 'Claude 3 Opus' },
        { value: 'claude-3-sonnet', name: 'Claude 3 Sonnet' },
        { value: 'claude-3-haiku', name: 'Claude 3 Haiku' }
    ],
    'mistral': [
        { value: 'mistral-large', name: 'Mistral Large' },
        { value: 'mistral-medium', name: 'Mistral Medium' },
        { value: 'mistral-small', name: 'Mistral Small' }
    ],
    'cohere': [
        { value: 'command-r', name: 'Command R' },
        { value: 'command-r-plus', name: 'Command R+' }
    ]
};

/**
 * Load API keys from server
 */
function loadAPIKeys() {
    // Show loading indicator
    $('#api-keys-table').html('<tr><td colspan="5" class="text-center">Loading API keys...</td></tr>');

    // Send request to server
    $.ajax({
        url: '/api/keys',
        type: 'GET',
        success: function(response) {
            if (response.status === 'success' && response.keys) {
                apiKeys = response.keys;
                displayAPIKeys(apiKeys);
            } else {
                $('#api-keys-table').html('<tr><td colspan="5" class="text-center">No API keys found.</td></tr>');
            }
        },
        error: function() {
            $('#api-keys-table').html('<tr><td colspan="5" class="text-center text-danger">Failed to load API keys.</td></tr>');
        }
    });
}

/**
 * Display API keys in the table
 * @param {Array} keys List of API keys
 */
function displayAPIKeys(keys) {
    if (keys.length === 0) {
        $('#api-keys-table').html('<tr><td colspan="5" class="text-center">No API keys found.</td></tr>');
        return;
    }

    let html = '';

    for (const key of keys) {
        const maskedKey = maskAPIKey(key.key);
        const statusClass = key.status === 'active' ? 'status-active' :
                           (key.status === 'expired' ? 'status-expired' : 'status-unknown');
        const statusText = key.status === 'active' ? 'Active' :
                          (key.status === 'expired' ? 'Expired' : 'Unknown');

        html += `
            <tr data-key-id="${key.id}">
                <td>
                    <img src="/static/images/${key.provider.toLowerCase()}-icon.png" alt="${key.provider}" class="provider-icon">
                    ${key.provider}
                </td>
                <td>${key.model}</td>
                <td>
                    <span class="api-key-masked">${maskedKey}</span>
                    <i class="fas fa-copy copy-btn" onclick="copyAPIKey('${key.id}')" title="Copy API Key"></i>
                </td>
                <td><span class="${statusClass}">${statusText}</span></td>
                <td class="api-key-actions">
                    <button class="btn btn-sm btn-outline-primary" onclick="testAPIKey('${key.id}')">
                        <i class="fas fa-vial"></i> Test
                    </button>
                    <button class="btn btn-sm btn-outline-secondary" onclick="editAPIKey('${key.id}')">
                        <i class="fas fa-edit"></i> Edit
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteAPIKey('${key.id}')">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                </td>
            </tr>
        `;
    }

    $('#api-keys-table').html(html);
}

/**
 * Mask API key for display
 * @param {string} key API key
 * @returns {string} Masked API key
 */
function maskAPIKey(key) {
    if (key.length <= 8) {
        return '••••••••';
    }

    return key.substring(0, 4) + '••••••••' + key.substring(key.length - 4);
}

/**
 * Update model options based on selected provider
 */
function updateModelOptions() {
    const provider = $('#provider').val();
    const modelSelect = $('#model');

    // Clear current options
    modelSelect.empty();
    modelSelect.append('<option value="">Select Model</option>');

    // Add models for selected provider
    if (provider && modelsByProvider[provider]) {
        for (const model of modelsByProvider[provider]) {
            modelSelect.append(`<option value="${model.value}">${model.name}</option>`);
        }
    }
}

/**
 * Save new API key
 */
function saveAPIKey() {
    const provider = $('#provider').val();
    const model = $('#model').val();
    const apiKey = $('#api-key').val();

    if (!provider || !model || !apiKey) {
        alert('Please fill in all fields.');
        return;
    }

    // Disable save button
    $('#save-key-btn').prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');

    // Send request to server
    $.ajax({
        url: '/api/keys',
        type: 'POST',
        data: {
            provider: provider,
            model: model,
            key: apiKey
        },
        success: function(response) {
            if (response.status === 'success') {
                // Close modal
                $('#add-key-modal').modal('hide');

                // Reset form
                $('#add-key-form')[0].reset();

                // Reload API keys
                loadAPIKeys();

                // Show success message
                alert('API key saved successfully.');
            } else {
                alert('Failed to save API key: ' + response.message);
            }

            // Enable save button
            $('#save-key-btn').prop('disabled', false).text('Save Key');
        },
        error: function() {
            alert('Failed to save API key. Please try again.');

            // Enable save button
            $('#save-key-btn').prop('disabled', false).text('Save Key');
        }
    });
}

/**
 * Edit API key
 * @param {string} keyId API key ID
 */
function editAPIKey(keyId) {
    const key = apiKeys.find(k => k.id === keyId);

    if (!key) {
        return;
    }

    // Set form values
    $('#edit-key-id').val(key.id);
    $('#edit-provider').val(key.provider);
    $('#edit-model').val(key.model);
    $('#edit-api-key').val('');

    // Show modal
    $('#edit-key-modal').modal('show');
}

/**
 * Update API key
 */
function updateAPIKey() {
    const keyId = $('#edit-key-id').val();
    const apiKey = $('#edit-api-key').val();

    if (!keyId) {
        return;
    }

    // Disable update button
    $('#update-key-btn').prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Updating...');

    // Send request to server
    $.ajax({
        url: '/api/keys/' + keyId + '/update',
        type: 'POST',
        data: {
            key: apiKey
        },
        success: function(response) {
            if (response.status === 'success') {
                // Close modal
                $('#edit-key-modal').modal('hide');

                // Reset form
                $('#edit-key-form')[0].reset();

                // Reload API keys
                loadAPIKeys();

                // Show success message
                alert('API key updated successfully.');
            } else {
                alert('Failed to update API key: ' + response.message);
            }

            // Enable update button
            $('#update-key-btn').prop('disabled', false).text('Update Key');
        },
        error: function() {
            alert('Failed to update API key. Please try again.');

            // Enable update button
            $('#update-key-btn').prop('disabled', false).text('Update Key');
        }
    });
}

/**
 * Delete API key
 * @param {string} keyId API key ID
 */
function deleteAPIKey(keyId) {
    if (!confirm('Are you sure you want to delete this API key?')) {
        return;
    }

    // Send request to server
    $.ajax({
        url: '/api/keys/' + keyId + '/delete',
        type: 'POST',
        success: function(response) {
            if (response.status === 'success') {
                // Reload API keys
                loadAPIKeys();

                // Show success message
                alert('API key deleted successfully.');
            } else {
                alert('Failed to delete API key: ' + response.message);
            }
        },
        error: function() {
            alert('Failed to delete API key. Please try again.');
        }
    });
}

/**
 * Test API key
 * @param {string} keyId API key ID
 */
function testAPIKey(keyId) {
    const key = apiKeys.find(k => k.id === keyId);

    if (!key) {
        return;
    }

    // Update button state
    const button = $(`tr[data-key-id="${keyId}"] .btn-outline-primary`);
    button.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Testing...');

    // Send request to server
    $.ajax({
        url: '/api/keys/' + keyId + '/test',
        type: 'POST',
        success: function(response) {
            if (response.status === 'success') {
                // Update button state
                button.removeClass('btn-outline-primary').addClass('btn-success').html('<i class="fas fa-check"></i> Valid');

                // Update key status
                $(`tr[data-key-id="${keyId}"] td:nth-child(4) span`).removeClass().addClass('status-active').text('Active');

                // Update key in array
                const keyIndex = apiKeys.findIndex(k => k.id === keyId);
                if (keyIndex !== -1) {
                    apiKeys[keyIndex].status = 'active';
                }

                // Reset button after 2 seconds
                setTimeout(function() {
                    button.removeClass('btn-success').addClass('btn-outline-primary').html('<i class="fas fa-vial"></i> Test');
                    button.prop('disabled', false);
                }, 2000);
            } else {
                // Update button state
                button.removeClass('btn-outline-primary').addClass('btn-danger').html('<i class="fas fa-times"></i> Invalid');

                // Update key status
                $(`tr[data-key-id="${keyId}"] td:nth-child(4) span`).removeClass().addClass('status-expired').text('Expired');

                // Update key in array
                const keyIndex = apiKeys.findIndex(k => k.id === keyId);
                if (keyIndex !== -1) {
                    apiKeys[keyIndex].status = 'expired';
                }

                // Reset button after 2 seconds
                setTimeout(function() {
                    button.removeClass('btn-danger').addClass('btn-outline-primary').html('<i class="fas fa-vial"></i> Test');
                    button.prop('disabled', false);
                }, 2000);
            }
        },
        error: function() {
            // Update button state
            button.removeClass('btn-outline-primary').addClass('btn-danger').html('<i class="fas fa-times"></i> Error');

            // Reset button after 2 seconds
            setTimeout(function() {
                button.removeClass('btn-danger').addClass('btn-outline-primary').html('<i class="fas fa-vial"></i> Test');
                button.prop('disabled', false);
            }, 2000);
        }
    });
}

/**
 * Copy API key to clipboard
 * @param {string} keyId API key ID
 */
function copyAPIKey(keyId) {
    const key = apiKeys.find(k => k.id === keyId);

    if (!key) {
        return;
    }

    // Create temporary input element
    const tempInput = document.createElement('input');
    tempInput.value = key.key;
    document.body.appendChild(tempInput);

    // Select and copy
    tempInput.select();
    document.execCommand('copy');

    // Remove temporary element
    document.body.removeChild(tempInput);

    // Show feedback
    const copyIcon = $(`tr[data-key-id="${keyId}"] .copy-btn`);
    copyIcon.removeClass('fa-copy').addClass('fa-check');

    // Reset icon after 2 seconds
    setTimeout(function() {
        copyIcon.removeClass('fa-check').addClass('fa-copy');
    }, 2000);
}
