Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  passwordless_for :managers

  namespace :info, path: '' do
    root to: 'application#about'
    get :statistics, to: 'application#statistics'
  end

  namespace :map do
    root to: 'application#show'
  end

  namespace :cms do
    root to: 'application#show'
    get :regions, to: 'application#regions'

    resources :countries, except: %i[edit update] do
      get :regions
      resources :managers, only: %i[index new create destroy]
      resources :venues, only: %i[index]
      resources :events, only: %i[index]
      resources :provinces, only: %i[new create]
      resources :local_areas, only: %i[new create]
      resources :audits, only: %i[index]
    end

    resources :provinces, except: %i[edit update index] do
      get :regions
      resources :managers, only: %i[index new create destroy]
      resources :venues, only: %i[index new create]
      resources :events, only: %i[index]
      resources :local_areas, only: %i[new create]
      resources :audits, only: %i[index]
    end

    resources :local_areas, except: %i[index] do
      resources :managers, only: %i[index new create destroy]
      resources :venues, only: %i[index new create]
      resources :events, only: %i[index]
      resources :audits, only: %i[index]
    end

    resources :venues do
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index new create]
      resources :audits, only: %i[index]
    end

    resources :events do
      get :images, to: 'events#images'
      post :images, to: 'events#upload_image', as: :upload_image
      delete 'images/:index', to: 'events#destroy_image', as: :destroy_image
      get :regions
      resources :managers, only: %i[index new create destroy]
      resources :registrations, only: %i[index]
      resources :audits, only: %i[index]
    end

    resources :managers do
      get :regions
      get :activity
      resources :venues, only: %i[index]
      resources :events, only: %i[index]
      resources :audits, only: %i[index]
    end

    resources :registrations, only: %i[index]
    resources :audits, only: %i[index]
    resources :access_keys, only: %i[index new create edit update destroy]
  end

  namespace :api do
    get '404', to: 'api/application#error' # Not found
    get '429', to: 'api/application#error' # Too many requests
    get '500', to: 'api/application#error' # Internal server error

    resources :events, only: %i[index show]
    resources :venues, only: %i[index show] do
      resources :events, only: %i[index]
    end
  end
end
