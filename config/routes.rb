Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match "/", to: "application#index", via: [:post, :get]
  match "/auth", to: "application#auth", via: [:post, :get]
  get "/api", to: "application#info"
  post "/api", to: "application#api"

end
