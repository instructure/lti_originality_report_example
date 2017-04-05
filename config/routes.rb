Rails.application.routes.draw do
  root 'pages#home'

  scope(controller: :registration) do
    post 'register', action: :register, as: :registration
  end

  scope(controller: :assignments) do
    post 'assignments/configure', action: :configure, as: :assignment_configuration
  end
end
