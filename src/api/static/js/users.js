/**
 * JavaScript functions for Users management
 */

// Show form to add a new user
function showAddUserForm() {
    var formHtml = '<form id="addUserForm">'+
        '<div class="form-group">'+
        '<label for="username">Username</label>'+
        '<input type="text" class="form-control" id="username" name="username" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="email">Email</label>'+
        '<input type="email" class="form-control" id="email" name="email" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="password">Password</label>'+
        '<input type="password" class="form-control" id="password" name="password" required>'+
        '</div>'+
        '<div class="form-group">'+
        '<label for="role">Role</label>'+
        '<select class="form-control" id="role" name="role" required>'+
        '<option value="USER">User</option>'+
        '<option value="ADMIN">Admin</option>'+
        '</select>'+
        '</div>'+
        '<button type="button" class="btn btn-warning" onclick="submitAddUser()">Add User</button>'+
        '</form>';
    
    showModal('Add New User', formHtml);
}

// Submit form to add a new user
function submitAddUser() {
    var formData = $('#addUserForm').serialize();
    ajaxPost('/users/add', formData, function(response) {
        if (response.status === 'success') {
            $('#mainModal').modal('hide');
            alert('User added successfully!');
            refreshPage();
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Show form to edit a user
function editUser(id) {
    ajaxGet('/users/' + id, function(response) {
        var user = response.user;
        
        var formHtml = '<form id="editUserForm">'+
            '<div class="form-group">'+
            '<label for="username">Username</label>'+
            '<input type="text" class="form-control" id="username" name="username" value="'+user.username+'" required>'+
            '</div>'+
            '<div class="form-group">'+
            '<label for="email">Email</label>'+
            '<input type="email" class="form-control" id="email" name="email" value="'+user.email+'" required>'+
            '</div>'+
            '<div class="form-group">'+
            '<label for="role">Role</label>'+
            '<select class="form-control" id="role" name="role" required>'+
            '<option value="USER" '+(user.role === 'USER' ? 'selected' : '')+'>User</option>'+
            '<option value="ADMIN" '+(user.role === 'ADMIN' ? 'selected' : '')+'>Admin</option>'+
            '</select>'+
            '</div>'+
            '<div class="form-group">'+
            '<label for="new_password">New Password (leave blank to keep current)</label>'+
            '<input type="password" class="form-control" id="new_password" name="new_password">'+
            '</div>'+
            '<button type="button" class="btn btn-warning" onclick="submitEditUser('+id+')">Update User</button>'+
            '</form>';
        
        showModal('Edit User', formHtml);
    });
}

// Submit form to edit a user
function submitEditUser(id) {
    var formData = $('#editUserForm').serialize();
    ajaxPost('/users/' + id + '/update', formData, function(response) {
        if (response.status === 'success') {
            $('#mainModal').modal('hide');
            alert('User updated successfully!');
            refreshPage();
        } else {
            alert('Error: ' + response.message);
        }
    });
}

// Delete a user
function deleteUser(id) {
    if (confirm('Are you sure you want to delete this user?')) {
        ajaxPost('/users/' + id + '/delete', {}, function(response) {
            if (response.status === 'success') {
                alert('User deleted successfully!');
                refreshPage();
            } else {
                alert('Error: ' + response.message);
            }
        });
    }
}
