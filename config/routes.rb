require'sidekiq/web' 

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/try", graphql_path: "/"
  end
  post "/", to: "graphql#execute"

  mount Sidekiq::Web => '/sidekiq'

  mount ActionCable.server => '/cable'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

