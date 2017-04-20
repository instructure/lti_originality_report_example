$(document).ready(function(){
  $('#submission-index-alert').hide();
  $('button.get-submission').click(function(e){
    var button = e.currentTarget
    $.get(
      '/tool_proxy/' + button.getAttribute('data-tp-guid') +
      '/submissions/' + button.getAttribute('data-tc-id') + '/retrieve',
      {},
      function(data, status){
        console.log(status);
        console.log(data);
        $('#submission-index-alert').show();
      }
    );
  });

  $('button.create-report').click(function(e){
    var button = e.currentTarget
    $.post(
      '/assignments/' + button.getAttribute('data-assignment-tc-id') +
      '/submissions/' + button.getAttribute('data-subject-tc-id') +
      '/originality_report',
      {},
      function(data, status){
        console.log(status);
        console.log(data);
        $('#submission-index-alert').show();
      }
    );
  });
});
