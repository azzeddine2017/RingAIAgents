/**
 * Common JavaScript functions for RingAI Agents
 */

// AJAX functions
function ajaxGet(url, callback) {
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            console.log("AJAX GET Response:", response);
            callback(response);
        },
        error: function(xhr, status, error) {
            console.error("AJAX GET Error:", xhr.responseText);
            alert('Error fetching data. Please try again.');
        }
    });
}

function ajaxPost(url, data, callback) {
    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        dataType: 'json',
        success: function(response) {
            console.log("AJAX POST Response:", response);
            callback(response);
        },
        error: function(xhr, status, error) {
            console.error("AJAX POST Error:", xhr.responseText);
            alert('Error submitting data. Please try again.');
        }
    });
}

// Refresh functions
function refreshPage() {
    location.reload();
}

// Modal functions
function showModal(title, content) {
    $('#modalTitle').text(title);
    $('#modalBody').html(content);
    $('#mainModal').modal('show');
}
