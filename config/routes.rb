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
    post 'submission/index', action: :index
  end

  scope(controller: :originality_reports) do
    post 'assignments/:assignment_tc_id/submissions/:submission_tc_id/originality_report',
         action: :create, as: :originality_create
    put 'assignments/:assignment_tc_id/submissions/:submission_tc_id/originality_report/:or_tc_id',
         action: :update, as: :originality_update
  end

  namespace :event do
    post :submission
  end
end
