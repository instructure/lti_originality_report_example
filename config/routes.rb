Rails.application.routes.draw do
  root 'pages#home'

  scope(controller: :registration) do
    post 'register', action: :register, as: :registration
  end

  scope(controller: :assignment_configuration) do
    post 'assignment-configuration', action: :configure, as: :configuration
  end
end
