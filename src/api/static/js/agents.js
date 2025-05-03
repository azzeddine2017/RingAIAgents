/**
 * JavaScript functions for Agents management
 */

// Helper function for AJAX GET requests
function ajaxGet(url, callback) {
    console.log("AJAX GET:", url);
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            console.log("AJAX GET Response:", response);

            // تحقق من تنسيق الاستجابة وتحويلها إلى كائن إذا كانت سلسلة نصية
            if (typeof response === 'string') {
                try {
                    response = JSON.parse(response);
                } catch (e) {
                    console.error("Error parsing response:", e);
                }
            }

            callback(response);
        },
        error: function(xhr, status, error) {
            console.error("AJAX GET Error:", xhr.responseText);
            alert('Error fetching data. Please try again.');
        }
    });
}

// Helper function for AJAX POST requests
function ajaxPost(url, data, callback) {
    console.log("AJAX POST:", url, data);
    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        dataType: 'json',
        success: function(response) {
            console.log("AJAX POST Response:", response);

            // تحقق من تنسيق الاستجابة وتحويلها إلى كائن إذا كانت سلسلة نصية
            if (typeof response === 'string') {
                try {
                    response = JSON.parse(response);
                } catch (e) {
                    console.error("Error parsing POST response:", e);
                }
            }

            callback(response);
        },
        error: function(xhr, status, error) {
            console.error("AJAX POST Error:", xhr.responseText);
            alert('Error submitting data. Please try again.');
        }
    });
}

// Helper function to refresh the page
function refreshPage() {
    location.reload();
}

// Helper function to show modal
function showModal(title, content) {
    $('#modalTitle').text(title);
    $('#modalBody').html(content);
    $('#mainModal').modal('show');
}

// Show form to add a new agent
function showAddAgentForm() {
    var formHtml = '<form id="addAgentForm">'+
        '<div class="form-group">'+
        '<label for="name">Name</label>'+
        '<input type="text" class="form-control" id="name" name="name" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="role">Role</label>'+
        '<input type="text" class="form-control" id="role" name="role" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="goal">Goal</label>'+
        '<textarea class="form-control" id="goal" name="goal" rows="3" required></textarea>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="skills">Skills (comma separated)</label>'+
        '<input type="text" class="form-control" id="skills" name="skills">'+
        '</div>'+
        '<div class="form-row">'+
        '<div class="form-group col-md-6">'+
        '<label for="openness">Openness (1-10)</label>'+
        '<input type="number" class="form-control" id="openness" name="openness" min="1" max="10" value="5">'+
        '</div>'+
        '<div class="form-group col-md-6">'+
        '<label for="conscientiousness">Conscientiousness (1-10)</label>'+
        '<input type="number" class="form-control" id="conscientiousness" name="conscientiousness" min="1" max="10" value="5">'+
        '</div>'+
        '</div>'+
        '<div class="form-row">'+
        '<div class="form-group col-md-4">'+
        '<label for="extraversion">Extraversion (1-10)</label>'+
        '<input type="number" class="form-control" id="extraversion" name="extraversion" min="1" max="10" value="5">'+
        '</div>'+
        '<div class="form-group col-md-4">'+
        '<label for="agreeableness">Agreeableness (1-10)</label>'+
        '<input type="number" class="form-control" id="agreeableness" name="agreeableness" min="1" max="10" value="5">'+
        '</div>'+
        '<div class="form-group col-md-4">'+
        '<label for="neuroticism">Neuroticism (1-10)</label>'+
        '<input type="number" class="form-control" id="neuroticism" name="neuroticism" min="1" max="10" value="5">'+
        '</div>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="language_model">Language Model</label>'+
        '<select class="form-control" id="language_model" name="language_model">'+
        '<option value="gemini-1.5-flash">Gemini 1.5 Flash</option>'+
        '<option value="gpt-4">GPT-4</option>'+
        '<option value="claude-3">Claude 3</option>'+
        '</select>'+
        '</div>'+
        '<button type="button" class="btn btn-primary" onclick="submitAddAgent()">Add Agent</button>'+
        '</form>';

    showModal('Add New Agent', formHtml);
}

// Submit form to add a new agent
function submitAddAgent() {
    var formData = $('#addAgentForm').serialize();
    ajaxPost('/agents/add', formData, function(response) {
        if (response.status === 'success') {
            $('#mainModal').modal('hide');
            alert('Agent added successfully!');
            refreshPage();
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Show form to edit an agent
function editAgent(id) {
    console.log("Editing agent with ID:", id);

    // Log the ID for debugging
    console.log("Agent ID before encoding:", id);
    console.log("Agent ID after encoding:", encodeURIComponent(id));

    // Use direct AJAX call with more error handling
    $.ajax({
        url: '/agents/' + encodeURIComponent(id),
        type: 'GET',
        data: { agent_id: id },
        dataType: 'json',
        success: function(response) {
            console.log("Agent data received:", response);

            // تحقق من تنسيق الاستجابة وتحويلها إلى كائن إذا كانت سلسلة نصية
            if (typeof response === 'string') {
                try {
                    response = JSON.parse(response);
                } catch (e) {
                    console.error("Error parsing agent data response:", e);
                }
            }

            // Check if response is an error message
            if (response.status === 'error') {
                alert('Error: ' + response.message);
                return;
            }

            var agent = response;

            // Parse personality traits
            var openness = 5;
            var conscientiousness = 5;
            var extraversion = 5;
            var agreeableness = 5;
            var neuroticism = 5;

            if (agent && agent.personality) {
                try {
                    // If personality is a string, parse it
                    if (typeof agent.personality === 'string') {
                        agent.personality = JSON.parse(agent.personality);
                    }

                    openness = agent.personality.openness || 5;
                    conscientiousness = agent.personality.conscientiousness || 5;
                    extraversion = agent.personality.extraversion || 5;
                    agreeableness = agent.personality.agreeableness || 5;
                    neuroticism = agent.personality.neuroticism || 5;
                } catch (e) {
                    console.error("Error parsing personality:", e);
                }
            }

            // Check if agent data is valid
            if (!agent || !agent.name) {
                alert('Error: Could not retrieve agent data');
                return;
            }

            // Safely get agent properties with defaults
            var agentName = agent.name || '';
            var agentRole = agent.role || '';
            var agentGoal = agent.goal || '';
            var agentLanguageModel = agent.language_model || 'gemini-1.5-flash';

            // Handle skills array
            var skillsValue = '';
            try {
                if (agent.skills) {
                    // If skills is a string, parse it
                    if (typeof agent.skills === 'string' && agent.skills.trim() !== '') {
                        agent.skills = JSON.parse(agent.skills);
                    }

                    if (Array.isArray(agent.skills)) {
                        skillsValue = agent.skills.map(s => {
                            if (typeof s === "object" && s.name) return s.name;
                            return s;
                        }).join(", ");
                    }
                }
            } catch (e) {
                console.error("Error parsing skills:", e);
            }

            var formHtml = '<form id="editAgentForm">'+
                '<div class="form-group">'+
                '<label for="name">Name</label>'+
                '<input type="text" class="form-control" id="name" name="name" value="'+agentName+'" required>'+
                '</div>'+
                '<div class="form-group">'+
                '<label for="role">Role</label>'+
                '<input type="text" class="form-control" id="role" name="role" value="'+agentRole+'" required>'+
                '</div>'+
                '<div class="form-group">'+
                '<label for="goal">Goal</label>'+
                '<textarea class="form-control" id="goal" name="goal" rows="3" required>'+agentGoal+'</textarea>'+
                '</div>'+
                '<div class="form-group">'+
                '<label for="skills">Skills (comma separated)</label>'+
                '<input type="text" class="form-control" id="skills" name="skills" value="'+skillsValue+'">'+
                '</div>'+
                '<div class="form-group">'+
                '<label for="language_model">Language Model</label>'+
                '<select class="form-control" id="language_model" name="language_model">'+
                '<option value="gemini-1.5-flash" '+(agentLanguageModel === "gemini-1.5-flash" ? "selected" : "")+'>Gemini 1.5 Flash</option>'+
                '<option value="gpt-4" '+(agentLanguageModel === "gpt-4" ? "selected" : "")+'>GPT-4</option>'+
                '<option value="claude-3" '+(agentLanguageModel === "claude-3" ? "selected" : "")+'>Claude 3</option>'+
                '</select>'+
                '</div>'+
                '<h5 class="mt-4">Personality Traits</h5>'+
                '<div class="form-row">'+
                '<div class="form-group col-md-6">'+
                '<label for="openness">Openness (1-10)</label>'+
                '<input type="number" class="form-control" id="openness" name="openness" min="1" max="10" value="'+openness+'">'+
                '</div>'+
                '<div class="form-group col-md-6">'+
                '<label for="conscientiousness">Conscientiousness (1-10)</label>'+
                '<input type="number" class="form-control" id="conscientiousness" name="conscientiousness" min="1" max="10" value="'+conscientiousness+'">'+
                '</div>'+
                '</div>'+
                '<div class="form-row">'+
                '<div class="form-group col-md-4">'+
                '<label for="extraversion">Extraversion (1-10)</label>'+
                '<input type="number" class="form-control" id="extraversion" name="extraversion" min="1" max="10" value="'+extraversion+'">'+
                '</div>'+
                '<div class="form-group col-md-4">'+
                '<label for="agreeableness">Agreeableness (1-10)</label>'+
                '<input type="number" class="form-control" id="agreeableness" name="agreeableness" min="1" max="10" value="'+agreeableness+'">'+
                '</div>'+
                '<div class="form-group col-md-4">'+
                '<label for="neuroticism">Neuroticism (1-10)</label>'+
                '<input type="number" class="form-control" id="neuroticism" name="neuroticism" min="1" max="10" value="'+neuroticism+'">'+
                '</div>'+
                '</div>'+
                '<input type="hidden" name="agent_id" value="'+id+'">'+
                '<button type="button" class="btn btn-primary" onclick="submitEditAgent(\''+id+'\')">Update Agent</button>'+
                '</form>';

            showModal('Edit Agent', formHtml);
        },
        error: function(xhr, status, error) {
            console.error("Error fetching agent:", error);
            alert('Error fetching agent data. Please try again.');
        }
    });
}

// Submit form to edit an agent
function submitEditAgent(id) {
    // Get form data
    var formData = $('#editAgentForm').serialize();

    // Log form data for debugging
    console.log("Form data:", formData);

    // Send AJAX request
    $.ajax({
        url: '/agents/' + encodeURIComponent(id) + '/update',
        type: 'POST',
        data: formData,  // agent_id is already included in the form
        dataType: 'json',
        success: function(response) {
            console.log("Update response:", response);
            if (response.status === 'success') {
                $('#mainModal').modal('hide');
                alert('Agent updated successfully!');
                // استخدام setTimeout لتأخير إعادة تحميل الصفحة
                setTimeout(function() {
                    window.location.href = '/agents';
                }, 500);
            } else {
                alert('Error: ' + response.message);
            }
        },
        error: function(xhr, status, error) {
            console.error("Update error:", xhr.responseText);
            alert('Error updating agent. Please try again.');
        }
    });
}

// Delete an agent
function deleteAgent(id) {
    if (confirm('Are you sure you want to delete this agent?')) {
        // Log action for debugging
        console.log("Deleting agent ID:", id);

        // Send AJAX request
        $.ajax({
            url: '/agents/' + encodeURIComponent(id) + '/delete',
            type: 'POST',
            data: { agent_id: encodeURIComponent(id) },
            dataType: 'json',
            success: function(response) {
                console.log("Delete response:", response);
                if (response.status === 'success') {
                    alert('Agent deleted successfully!');
                    // استخدام setTimeout لتأخير إعادة تحميل الصفحة
                    setTimeout(function() {
                        window.location.href = '/agents';
                    }, 500);
                } else {
                    alert('Error: ' + response.message);
                }
            },
            error: function(xhr, status, error) {
                console.error("Delete error:", xhr.responseText);
                alert('Error deleting agent. Please try again.');
            }
        });
    }
}
