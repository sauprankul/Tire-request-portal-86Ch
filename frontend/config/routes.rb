Rails.application.routes.draw do
  # Root path
  root 'home#index'

  # Authentication routes
  get '/signin', to: 'sessions#new', as: 'signin'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  # OmniAuth routes
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'

  # User registration and approval
  resources :users, only: [:index, :new, :create] do
    member do
      post :approve
      post :reject
    end
  end
  get '/pending', to: 'users#pending', as: 'pending'

  # Dashboard routes
  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  get '/dashboard/participant', to: 'dashboard#participant', as: 'participant_dashboard'
  get '/dashboard/representative', to: 'dashboard#representative', as: 'representative_dashboard'
  get '/dashboard/admin', to: 'dashboard#admin', as: 'admin_dashboard'
  get '/dashboard/switch_view', to: 'dashboard#switch_view', as: 'switch_dashboard_view'

  # Requests routes
  resources :requests do
    member do
      post :assign
      post :withdraw
      post :mark_paid
      post :mark_received
    end
    
    # Messages nested under requests
    resources :messages, only: [:create]
  end

  # Points routes
  resources :points, only: [:index, :show, :edit, :update] do
    collection do
      post :bulk_update
    end
  end

  # Products routes
  resources :products
end
