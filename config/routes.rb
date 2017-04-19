Rails.application.routes.draw do
  root 'pages#home'

  scope(controller: :registration) do
    post 'register', action: :register, as: :registration
  end

  scope(controller: :assignments) do
    post 'assignments/configure', action: :configure, as: :assignment_configuration
    post 'assignments/:lti_assignment_id/update', action: :update, as: :assignment_update
  end

  scope(controller: :submissions) do
    get 'tool_proxy/:tool_proxy_guid/submissions/:tc_submission_id/retrieve',
        action: :retrieve_and_store, as: :submission_retrival
  end

  namespace :event do
    post :submission
  end
end
