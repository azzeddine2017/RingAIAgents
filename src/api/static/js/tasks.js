/**
 * JavaScript functions for Tasks management
 */

// Show form to add a new task
function showAddTaskForm() {
    var formHtml = '<form id="addTaskForm">'+
        '<div class="form-group">'+
        '<label for="title">Task Title</label>'+
        '<input type="text" class="form-control" id="title" name="title" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="description">Description</label>'+
        '<textarea class="form-control" id="description" name="description" rows="3" required></textarea>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="team_id">Assigned Team</label>'+
        '<select class="form-control" id="team_id" name="team_id">'+
        '<option value="">Select a team</option>'+
        '</select>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="agent_id">Assigned Agent</label>'+
        '<select class="form-control" id="agent_id" name="agent_id">'+
        '<option value="">Select an agent</option>'+
        '</select>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="priority">Priority</label>'+
        '<select class="form-control" id="priority" name="priority" required>'+
        '<option value="LOW">Low</option>'+
        '<option value="MEDIUM" selected>Medium</option>'+
        '<option value="HIGH">High</option>'+
        '</select>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="due_date">Due Date</label>'+
        '<input type="date" class="form-control" id="due_date" name="due_date">'+
        '</div>'+
        '<button type="button" class="btn btn-info" onclick="submitAddTask()">Create Task</button>'+
        '</form>';

    showModal('Add New Task', formHtml);

    // Load teams and agents with retry
    console.log("Loading teams and agents...");

    // Function to load teams with retry
    function loadTeams() {
        $.ajax({
            url: '/teams',
            type: 'GET',
            dataType: 'json',
            success: function(response) {
                console.log("Teams response:", response);
                var teams = response.teams || [];
                var select = $('#team_id');

                // Clear existing options
                select.empty();
                select.append('<option value="">Select a team</option>');

                if (teams.length === 0) {
                    console.log("No teams found, retrying in 1 second...");
                    setTimeout(loadTeams, 1000);
                } else {
                    for(var i=0; i<teams.length; i++) {
                        select.append('<option value="'+teams[i].id+'">'+teams[i].name+'</option>');
                    }
                }
            },
            error: function(xhr) {
                console.error("Error loading teams:", xhr.responseText);

                // Retry after 1 second
                console.log("Retrying teams in 1 second...");
                setTimeout(loadTeams, 1000);
            }
        });
    }

    // Function to load agents with retry
    function loadAgents() {
        $.ajax({
            url: '/agents',
            type: 'GET',
            dataType: 'json',
            success: function(response) {
                console.log("Agents response:", response);
                var agents = response.agents || [];
                var select = $('#agent_id');

                // Clear existing options
                select.empty();
                select.append('<option value="">Select an agent</option>');

                if (agents.length === 0) {
                    console.log("No agents found, retrying in 1 second...");
                    setTimeout(loadAgents, 1000);
                } else {
                    for(var i=0; i<agents.length; i++) {
                        select.append('<option value="'+agents[i].id+'">'+agents[i].name+' ('+agents[i].role+')</option>');
                    }
                }
            },
            error: function(xhr) {
                console.error("Error loading agents:", xhr.responseText);

                // Retry after 1 second
                console.log("Retrying agents in 1 second...");
                setTimeout(loadAgents, 1000);
            }
        });
    }

    // Start loading teams and agents
    loadTeams();
    loadAgents();
}

// Submit form to add a new task
function submitAddTask() {
    var formData = $('#addTaskForm').serialize();
    ajaxPost('/tasks/add', formData, function(response) {
        if (response.status === 'success') {
            $('#mainModal').modal('hide');
            alert('Task created successfully!');
            refreshPage();
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Show form to edit a task
function editTask(id) {
    ajaxGet('/tasks/' + id, function(response) {
        var task = response.task;

        var formHtml = '<form id="editTaskForm">'+
            '<div class="form-group">'+
            '<label for="title">Task Title</label>'+
            '<input type="text" class="form-control" id="title" name="title" value="'+task.title+'" required>'+
            '</div>'+
            '<div class="form-group">'+
            '<label for="description">Description</label>'+
            '<textarea class="form-control" id="description" name="description" rows="3" required>'+task.description+'</textarea>'+
            '</div>'+
            '<div class="form-group">'+
            '<label for="status">Status</label>'+
            '<select class="form-control" id="status" name="status" required>'+
            '<option value="PENDING" '+(task.status === 'PENDING' ? 'selected' : '')+'>Pending</option>'+
            '<option value="IN_PROGRESS" '+(task.status === 'IN_PROGRESS' ? 'selected' : '')+'>In Progress</option>'+
            '<option value="COMPLETED" '+(task.status === 'COMPLETED' ? 'selected' : '')+'>Completed</option>'+
            '</select>'+
            '</div>'+
            '<div class="form-group">'+
            '<label for="priority">Priority</label>'+
            '<select class="form-control" id="priority" name="priority" required>'+
            '<option value="LOW" '+(task.priority === 'LOW' ? 'selected' : '')+'>Low</option>'+
            '<option value="MEDIUM" '+(task.priority === 'MEDIUM' ? 'selected' : '')+'>Medium</option>'+
            '<option value="HIGH" '+(task.priority === 'HIGH' ? 'selected' : '')+'>High</option>'+
            '</select>'+
            '</div>'+
            '<button type="button" class="btn btn-info" onclick="submitEditTask('+id+')">Update Task</button>'+
            '</form>';

        showModal('Edit Task', formHtml);
    });
}

// Submit form to edit a task
function submitEditTask(id) {
    var formData = $('#editTaskForm').serialize();
    // Add task_id to form data
    formData += '&task_id=' + encodeURIComponent(id);

    console.log("Updating task with ID:", id);
    console.log("Form data:", formData);

    ajaxPost('/tasks/' + id + '/update', formData, function(response) {
        if (response.status === 'success') {
            $('#mainModal').modal('hide');
            alert('Task updated successfully!');
            // Use setTimeout to delay page refresh
            setTimeout(function() {
                window.location.href = '/tasks';
            }, 500);
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Delete a task
function deleteTask(id) {
    if (confirm('Are you sure you want to delete this task?')) {
        console.log("Deleting task with ID:", id);

        // Create form data with task_id
        var formData = 'task_id=' + encodeURIComponent(id);

        ajaxPost('/tasks/' + id + '/delete', formData, function(response) {
            if (response.status === 'success') {
                alert('Task deleted successfully!');
                // Use setTimeout to delay page refresh
                setTimeout(function() {
                    window.location.href = '/tasks';
                }, 500);
            } else {
                alert('Error: ' + response.message);
            }
        });
    }
}
