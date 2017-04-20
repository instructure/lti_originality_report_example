$(document).ready(function(){
  $('#submission-index-alert').hide();

  function showStatus() {
    $('#submission-index-alert').show();
  }

  $('button.get-submission').click(function(e){
    var button = e.currentTarget
    $.get(
      '/tool_proxy/' + button.getAttribute('data-tp-guid') +
      '/submissions/' + button.getAttribute('data-tc-id') + '/retrieve',
      {},
      function(data, status){
        console.log(status);
        console.log(data);
        showStatus();
      }
    );
  });

  $('button.create-report').click(function(e){
    var button = e.currentTarget;
    var assignmentId = button.getAttribute('data-assignment-tc-id');
    var submissionId = button.getAttribute('data-subject-tc-id');
    var score = $('#' + submissionId + '-' + assignmentId + '.score-input').val();
    console.log(score);
    $.post(
      '/assignments/' + assignmentId +
      '/submissions/' + submissionId +
      '/originality_report',
      { 'originality_score': score },
      function(data, status){
        console.log(status);
        console.log(data);
        showStatus();
      }
    );
  });
});
