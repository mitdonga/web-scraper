require'sidekiq/web' 

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/try", graphql_path: "/"
  end
  post "/", to: "graphql#execute"

  mount Sidekiq::Web => '/sidekiq'

end

