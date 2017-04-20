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
  })
});
