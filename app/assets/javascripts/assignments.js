$(document).ready(function(){
  const settingsForm = $('form#assignment-settings-form');

  settingsForm.submit(function(event){
    event.preventDefault();
    $.post(
      '/assignments/' + $('#lti_assignment_id').val() + '/update',
      {
        settings: {
          settings_one: $(this).find('#setting_one').prop('checked'),
          settings_two: $(this).find('#setting_two').prop('checked')
        }
      },
      function(data, status){
        console.log(status);
        console.log(data);
      }
    );
  })

  $(settingsForm).find('input').change(function(event){
    settingsForm.submit();
  });
});


