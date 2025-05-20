Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :appointments, only: [:show] do
    member do
      patch :check_in, to: "appointments/check_ins#update"
      patch :status, to: "appointments/status_updates#update"
    end
  end

  get "status/:token", to: "patient_status#show", as: :patient_status

  namespace :settings do
    resources :integrations, only: [:index, :destroy]
    resources :staff, only: [:index, :create, :update, :destroy]
  end

  namespace :api do
    namespace :v1 do
      resources :appointments, only: [:index, :create, :update]
    end
  end

  namespace :webhooks do
    post :twilio, to: "twilio#create"
    post "integrations/:integration_id", to: "integrations#create", as: :integration
  end

  root "dashboard#index"
end
