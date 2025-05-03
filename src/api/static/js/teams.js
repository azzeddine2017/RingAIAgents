/**
 * JavaScript functions for Teams management
 */

// Show form to add a new team
function showAddTeamForm() {
    var formHtml = '<form id="addTeamForm">'+
        '<div class="form-group">'+
        '<label for="name">Team Name</label>'+
        '<input type="text" class="form-control" id="name" name="name" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="objective">Objective</label>'+
        '<textarea class="form-control" id="objective" name="objective" rows="3" required></textarea>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="leader_id">Team Leader</label>'+
        '<select class="form-control" id="leader_id" name="leader_id" required>'+
        '<option value="">Select a leader</option>'+
        '</select>'+
        '</div>'+
        '<button type="button" class="btn btn-success" onclick="submitAddTeam()">Create Team</button>'+
        '</form>';

    showModal('Add New Team', formHtml);

    // Load agents directly with retry
    console.log("Loading agents directly...");

    // عداد المحاولات
    var retryCount = 0;
    var maxRetries = 3; // الحد الأقصى لعدد المحاولات

    function loadAgents() {
        // زيادة عداد المحاولات
        retryCount++;

        $.ajax({
            url: '/api/agents/list',
            type: 'GET',
            dataType: 'json',
            success: function(response) {
                console.log("Agents response:", response);

                // تحقق من تنسيق الاستجابة وتحويلها إلى كائن إذا كانت سلسلة نصية
                if (typeof response === 'string') {
                    try {
                        response = JSON.parse(response);
                    } catch (e) {
                        console.error("Error parsing agent response:", e);
                    }
                }

                var agents = response.agents || [];
                var select = $('#leader_id');

                if (agents.length === 0) {
                    if (retryCount < maxRetries) {
                        console.log("No agents found, retrying in 1 second... (Attempt " + retryCount + " of " + maxRetries + ")");
                        setTimeout(loadAgents, 1000);
                    } else {
                        console.log("No agents found after " + maxRetries + " attempts.");
                        select.empty();
                        select.append('<option value="">No agents available</option>');
                        // إظهار رسالة للمستخدم
                        $('#agentLoadingMessage').remove();
                        $('#leader_id').after('<div id="agentLoadingMessage" class="alert alert-warning mt-2">No agents available. Please create agents first.</div>');
                    }
                    return;
                }

                // Clear existing options
                select.empty();
                select.append('<option value="">Select a leader</option>');

                for(var i=0; i<agents.length; i++) {
                    select.append('<option value="'+agents[i].id+'">'+agents[i].name+' ('+agents[i].role+')</option>');
                }

                // إزالة رسالة التحميل إذا كانت موجودة
                $('#agentLoadingMessage').remove();
            },
            error: function(xhr) {
                console.error("Error loading agents. Status:", xhr.status);
                console.error("Response text:", xhr.responseText);

                if (retryCount < maxRetries) {
                    // Retry after 1 second
                    console.log("Retrying in 1 second... (Attempt " + retryCount + " of " + maxRetries + ")");
                    setTimeout(loadAgents, 1000);
                } else {
                    console.error("Failed to load agents after " + maxRetries + " attempts.");
                    // إظهار رسالة خطأ للمستخدم
                    $('#agentLoadingMessage').remove();
                    $('#leader_id').after('<div id="agentLoadingMessage" class="alert alert-danger mt-2">Failed to load agents. Please try again later.</div>');
                }
            }
        });
    }

    // Start loading agents
    loadAgents();
}

// Submit form to add a new team
function submitAddTeam() {
    var formData = $('#addTeamForm').serialize();
    ajaxPost('/teams/add', formData, function(response) {
        if (response.status === 'success') {
            $('#mainModal').modal('hide');
            alert('Team created successfully!');
            refreshPage();
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Show form to edit a team
function editTeam(id) {
    console.log("Editing team with ID:", id);

    // تأكد من أن المعرف سلسلة نصية
    id = String(id);

    // استخدام AJAX مباشرة مع معالجة أخطاء أكثر تفصيلاً
    $.ajax({
        url: '/teams/' + encodeURIComponent(id),
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            console.log("Team data received (raw):", response);

            // تحقق من تنسيق الاستجابة
            if (typeof response === 'string') {
                try {
                    response = JSON.parse(response);
                } catch (e) {
                    console.error("Error parsing team response:", e);
                }
            }

            console.log("Team data processed:", response);

            // التحقق من حالة الاستجابة
            if (response.status === 'error') {
                alert('Error: ' + response.message);
                return;
            }

            // التحقق من وجود بيانات الفريق
            if (!response.team) {
                console.error("Team data not found in response:", response);
                alert('Error: Team data not found in response');
                return;
            }

            var team = response.team;

            var formHtml = '<form id="editTeamForm">'+
                '<div class="form-group">'+
                '<label for="name">Team Name</label>'+
                '<input type="text" class="form-control" id="name" name="name" value="'+team.name+'" required>'+
                '</div>'+
                '<div class="form-group">'+
                '<label for="objective">Objective</label>'+
                '<textarea class="form-control" id="objective" name="objective" rows="3" required>'+team.objective+'</textarea>'+
                '</div>'+
                '<div class="form-group">'+
                '<label for="leader_id">Team Leader</label>'+
                '<select class="form-control" id="leader_id" name="leader_id" required>'+
                '<option value="">Select a leader</option>'+
                '</select>'+
                '</div>'+
                '<button type="button" class="btn btn-success" onclick="submitEditTeam(\''+id+'\')">Update Team</button>'+
                '</form>';

            showModal('Edit Team', formHtml);

            // Load agents with retry
            // عداد المحاولات للتعديل
            var editRetryCount = 0;
            var editMaxRetries = 3; // الحد الأقصى لعدد المحاولات

            function loadAgentsForEdit() {
            // زيادة عداد المحاولات
            editRetryCount++;

            $.ajax({
                url: '/api/agents/list',
                type: 'GET',
                dataType: 'json',
                success: function(agentResponse) {
                    console.log("Agents response for edit:", agentResponse);

                    // تحقق من تنسيق الاستجابة وتحويلها إلى كائن إذا كانت سلسلة نصية
                    if (typeof agentResponse === 'string') {
                        try {
                            agentResponse = JSON.parse(agentResponse);
                        } catch (e) {
                            console.error("Error parsing agent response:", e);
                        }
                    }

                    var agents = agentResponse.agents || [];
                    var select = $('#leader_id');

                    if (agents.length === 0) {
                        if (editRetryCount < editMaxRetries) {
                            console.log("No agents found for edit, retrying in 1 second... (Attempt " + editRetryCount + " of " + editMaxRetries + ")");
                            setTimeout(loadAgentsForEdit, 1000);
                        } else {
                            console.log("No agents found for edit after " + editMaxRetries + " attempts.");
                            select.empty();
                            select.append('<option value="">No agents available</option>');
                            // إظهار رسالة للمستخدم
                            $('#agentEditLoadingMessage').remove();
                            $('#leader_id').after('<div id="agentEditLoadingMessage" class="alert alert-warning mt-2">No agents available. Please create agents first.</div>');
                        }
                        return;
                    }

                    // Clear existing options
                    select.empty();
                    select.append('<option value="">Select a leader</option>');

                    for(var i=0; i<agents.length; i++) {
                        var selected = (agents[i].id === team.leader_id) ? 'selected' : '';
                        select.append('<option value="'+agents[i].id+'" '+selected+'>'+agents[i].name+' ('+agents[i].role+')</option>');
                    }

                    // إزالة رسالة التحميل إذا كانت موجودة
                    $('#agentEditLoadingMessage').remove();
                },
                error: function(xhr) {
                    console.error("Error loading agents for edit:", xhr.responseText);

                    if (editRetryCount < editMaxRetries) {
                        // Retry after 1 second
                        console.log("Retrying agents for edit in 1 second... (Attempt " + editRetryCount + " of " + editMaxRetries + ")");
                        setTimeout(loadAgentsForEdit, 1000);
                    } else {
                        console.error("Failed to load agents for edit after " + editMaxRetries + " attempts.");
                        // إظهار رسالة خطأ للمستخدم
                        $('#agentEditLoadingMessage').remove();
                        $('#leader_id').after('<div id="agentEditLoadingMessage" class="alert alert-danger mt-2">Failed to load agents. Please try again later.</div>');
                    }
                }
            });
        }

            // Start loading agents
            loadAgentsForEdit();
        },
        error: function(xhr, textStatus, errorThrown) {
            console.error("Error fetching team:", errorThrown);
            console.error("Status:", textStatus);
            console.error("Response text:", xhr.responseText);

            // محاولة تحليل الاستجابة كـ JSON
            try {
                var responseObj = JSON.parse(xhr.responseText);
                if (responseObj && responseObj.id) {
                    // إذا كانت الاستجابة تحتوي على بيانات الفريق، استخدمها
                    console.log("Found team data in error response, trying to use it");

                    var team = {
                        id: responseObj.id,
                        name: responseObj.name || "",
                        objective: responseObj.objective || "",
                        leader_id: responseObj.leader_id || ""
                    };

                    var formHtml = '<form id="editTeamForm">'+
                        '<div class="form-group">'+
                        '<label for="name">Team Name</label>'+
                        '<input type="text" class="form-control" id="name" name="name" value="'+team.name+'" required>'+
                        '</div>'+
                        '<div class="form-group">'+
                        '<label for="objective">Objective</label>'+
                        '<textarea class="form-control" id="objective" name="objective" rows="3" required>'+team.objective+'</textarea>'+
                        '</div>'+
                        '<div class="form-group">'+
                        '<label for="leader_id">Team Leader</label>'+
                        '<select class="form-control" id="leader_id" name="leader_id" required>'+
                        '<option value="">Select a leader</option>'+
                        '</select>'+
                        '</div>'+
                        '<button type="button" class="btn btn-success" onclick="submitEditTeam(\''+id+'\')">Update Team</button>'+
                        '</form>';

                    showModal('Edit Team', formHtml);

                    // تحميل العملاء
                    var editRetryCount = 0;
                    var editMaxRetries = 3;

                    function loadAgentsForEdit() {
                        editRetryCount++;
                        $.ajax({
                            url: '/api/agents/list',
                            type: 'GET',
                            dataType: 'json',
                            success: function(agentResponse) {
                                console.log("Agents response for edit:", agentResponse);

                                if (typeof agentResponse === 'string') {
                                    try {
                                        agentResponse = JSON.parse(agentResponse);
                                    } catch (e) {
                                        console.error("Error parsing agent response:", e);
                                    }
                                }

                                var agents = agentResponse.agents || [];
                                var select = $('#leader_id');

                                if (agents.length === 0) {
                                    if (editRetryCount < editMaxRetries) {
                                        setTimeout(loadAgentsForEdit, 1000);
                                    } else {
                                        select.empty();
                                        select.append('<option value="">No agents available</option>');
                                        $('#agentEditLoadingMessage').remove();
                                        $('#leader_id').after('<div id="agentEditLoadingMessage" class="alert alert-warning mt-2">No agents available. Please create agents first.</div>');
                                    }
                                    return;
                                }

                                select.empty();
                                select.append('<option value="">Select a leader</option>');

                                for(var i=0; i<agents.length; i++) {
                                    var selected = (agents[i].id === team.leader_id) ? 'selected' : '';
                                    select.append('<option value="'+agents[i].id+'" '+selected+'>'+agents[i].name+' ('+agents[i].role+')</option>');
                                }

                                $('#agentEditLoadingMessage').remove();
                            },
                            error: function(xhr) {
                                console.error("Error loading agents for edit:", xhr.responseText);

                                if (editRetryCount < editMaxRetries) {
                                    setTimeout(loadAgentsForEdit, 1000);
                                } else {
                                    $('#agentEditLoadingMessage').remove();
                                    $('#leader_id').after('<div id="agentEditLoadingMessage" class="alert alert-danger mt-2">Failed to load agents. Please try again later.</div>');
                                }
                            }
                        });
                    }

                    loadAgentsForEdit();
                    return;
                }
            } catch (e) {
                console.error("Error parsing error response:", e);
            }

            alert('Error fetching team data. Please try again.');
        }
    });
}

// Submit form to edit a team
function submitEditTeam(id) {
    // تأكد من أن المعرف سلسلة نصية
    id = String(id);

    var formData = $('#editTeamForm').serialize();
    // Add team_id to form data
    formData += '&team_id=' + encodeURIComponent(id);

    console.log("Updating team with ID:", id);
    console.log("Form data:", formData);

    ajaxPost('/teams/' + encodeURIComponent(id) + '/update', formData, function(response) {
        console.log("Update team response:", response);

        if (response.status === 'success' || response.status === 'warning') {
            // إخفاء النافذة المنبثقة
            $('#mainModal').modal('hide');

            // عرض رسالة نجاح
            if (response.status === 'success') {
                alert('Team updated successfully!');
            } else {
                alert('Team updated with warning: ' + response.message);
            }

            // تحديث الصفحة بعد فترة قصيرة
            setTimeout(function() {
                // إعادة تحميل الصفحة بالكامل
                window.location.reload();
            }, 500);
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Delete a team
function deleteTeam(id) {
    // تأكد من أن المعرف سلسلة نصية
    id = String(id);

    if (confirm('Are you sure you want to delete this team?')) {
        console.log("Deleting team with ID:", id);

        // Create form data with team_id
        var formData = 'team_id=' + encodeURIComponent(id);

        ajaxPost('/teams/' + encodeURIComponent(id) + '/delete', formData, function(response) {
            if (response.status === 'success') {
                alert('Team deleted successfully!');
                // Use setTimeout to delay page refresh
                setTimeout(function() {
                    window.location.href = '/teams';
                }, 500);
            } else {
                alert('Error: ' + response.message);
            }
        });
    }
}
