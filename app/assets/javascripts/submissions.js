$(document).ready(function(){
  $('#submission-index-alert').hide();

  function showStatus() {
    $('#submission-index-alert').show();
  }

  function success(data, status) {
    console.log(status);
    console.log(data);
    showStatus();
  }

  $('button.get-submission').click(function(e){
    var button = e.currentTarget
    $.get(
      '/tool_proxy/' + button.getAttribute('data-tp-guid') +
      '/submissions/' + button.getAttribute('data-tc-id') + '/retrieve',
      {},
      success
    );
  });

  $('button.create-report').click(function(e){
    var button = e.currentTarget;
    var assignmentId = button.getAttribute('data-assignment-tc-id');
    var submissionId = button.getAttribute('data-subject-tc-id');
    var canvasEndpoint = '/assignments/' + assignmentId + '/submissions/' + submissionId + '/originality_report'
    var score = $('#' + submissionId + '-' + assignmentId + '.score-input').val();

    if (button.getAttribute('data-updating') === 'true') {
      $.ajax({
        url: canvasEndpoint + '/' + button.getAttribute('data-or-id'),
        type: 'PUT',
        data: { 'originality_score': score },
        success: success
      });
    } else {
      $.post(
        canvasEndpoint,
        { 'originality_score': score },
        success
      );
    }

  });
});
