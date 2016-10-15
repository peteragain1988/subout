require 'sidekiq/web'

Subout::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount ApiDoc => "/api/doc"

  root :to => 'static#index'

  get '/index.html' => 'static#index'
  get '/embedded.html' => 'static#embedded'

  # this is used for cache busting locally
  if Rails.env.development?
    get '/files/:timestamp/:path' => 'static#asset', :constraints => { :path => /.+/ }
    mount MailPreview => 'mail_view'
  end

  devise_for :users, skip: [:registrations, :sessions, :passwords, :confirmations]
  devise_for :retailers, :controllers => { :registrations => "retailers/registrations" }

  namespace :consumers do
    resources :quote_requests do
      get :select_winner, on: :member
      resources :quote do
        post :win, on: :member
      end
    end

    resources :pages, only: [:terms_and_conditions] do
      get :terms_and_conditions, on: :collection
    end
  end

  namespace :retailers do
    resource :profile
    root to: 'profiles#edit'
  end

  namespace :vendors do
    resources :offers do
      put "accept", on: :member
      put "decline", on: :member
    end
  end

  namespace :api, defaults: {format: 'json'}  do
    namespace :v1 do
      resources :gateway_subscriptions do
        get :connect_company, on: :collection
        get :update_account, on: :collection
        get :card_info, on: :member
      end
      resources :products
      resources :file_uploader_signatures, only: :new
      resources :passwords do
        put "update", on: :collection
      end
      resources :tokens
      resources :settings
      resources :users  do
        collection do
          post :account
        end
      end

      resources :quote_requests do
        resources :quotes
      end

      resources :auctions do
        member do
          put :select_winner
          put :create_negotiation
          put :decline_negotiation
          put :cancel
          put :award
        end
      end

      resources :favorite_invitations do
        collection do
          post :create_for_unknown_supplier
        end

        member do
          get :accept
        end
      end

      resources :favorites
      resources :events
      resources :companies do
        get :search, on: :collection
        put :update_agreement, on: :member
        put :update_product, on: :member
        put :update_regions, on: :member
        put :update_vehicles, on: :member
      end

      resources :bids do
        member do
          put :cancel
          put :accept_negotiation
          put :decline_negotiation
          put :counter_negotiation
        end
      end

      resources :filters
      resources :tags
      resources :opportunities do
        resources :bids
        resources :offers
        resources :comments
      end

      resources :ratings
      resources :vehicles
      resources :vendors
      resources :terms
    end
  end

  namespace :admin do
    get "/" => "base#index"
    resources :gateway_subscriptions, only: [:index, :edit, :update] do
      put 'resend_invitation', on: :member
    end
    resources :companies, only: [:index, :edit, :update, :destroy] do
      member do
        put "cancel_subscription"
        put "reactivate_subscription"
        put "connect_subscription"
        put "lock_account"
        put "unlock_account"
        put "add_as_a_favorite"
        put "change_emails"
        put "change_mode"
        put "change_offerer"
        put "change_password"
        get "auctions"
      end
      resources :vehicles, only: [:edit, :update]
    end
    resources :favorite_invitations, only: [:index] do
      put 'resend_invitation', on: :member
    end
    resources :revenues, only: [:index]
    resources :settings, only: [:index, :update, :edit]
    resources :email_templates, only: [:index, :update, :edit]
    resources :vendors
    resources :quote_requests
    resources :terms do
      post :publish, on: :member
    end
  end
end
