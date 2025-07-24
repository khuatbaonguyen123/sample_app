Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"

    # static pages
    get "/static_pages/home", to: "static_pages#home", as: "home"
    get "/static_pages/help", to: "static_pages#help", as: "help"
    get "/static_pages/contact", to: "static_pages#contact", as: "contact"

    # sign up
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    resources :users, only: :show

    resources :microposts, only: [:index]
  end
end
