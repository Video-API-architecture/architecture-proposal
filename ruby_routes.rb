Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth
      namespace :auth do
        post 'register', to: 'registrations#create'
        post 'login', to: 'sessions#create'
        post 'password-reset/request', to: 'password_resets#request_reset'
        post 'password-reset/confirm', to: 'password_resets#confirm'
      end

      # Users
      resources :users, only: [:show, :update]

      # Properties
      resources :properties do
        post 'upload/images', to: 'uploads#property_images', on: :collection
      end

      # Bookings
      resources :bookings, only: [:index, :show, :create, :update, :destroy]

      # Dashboards
      namespace :dashboards do
        get 'realtor', to: 'realtor#show'
        get 'buyer', to: 'buyer#show'
      end

      # Analytics
      namespace :analytics do
        get 'realtor', to: 'realtor#show'
      end

      # Calls
      resources :calls, only: [:create, :show] do
        member do
          post 'join'
          post 'end'
        end
      end

      # Uploads
      namespace :upload do
        post 'recordings', to: 'uploads#recordings'
      end
    end
  end
end
