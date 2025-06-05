Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }

  get "register", to: "registrations#new"
  post "register", to: "registrations#create"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "search", to: "search#index"

  resources :time_clock, only: [] do
    collection do
      post :clock_in
      post :clock_out
    end
  end

  resources :patients, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      post :send_consent
    end
    resources :cards, only: [:new, :create, :destroy], controller: "patients/cards"
  end
  resources :providers, only: [:index, :show, :new, :create, :edit, :update] do
    resources :integrations, only: [:new, :create, :destroy], controller: "providers/integrations"
    resources :schedules, only: [:create, :destroy], controller: "providers/schedules" do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :appointments, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      patch :check_in, to: "appointments/check_ins#update"
      patch :status, to: "appointments/status_updates#update"
      patch :cancel, to: "appointments#cancel"
      patch :no_show, to: "appointments#no_show"
      patch :waive_charge, to: "appointments#waive_charge"
      get :calendar, to: "appointments#calendar"
    end
    resource :conversation, only: [:show], controller: "appointments/conversations"
  end

  get "status/:token", to: "patient_status#show", as: :patient_status

  # Kiosk (patient self-check-in)
  get "kiosk/:subdomain", to: "kiosk#show", as: :kiosk
  post "kiosk/:subdomain/check_in", to: "kiosk#check_in", as: :kiosk_check_in
  get "kiosk/:subdomain/confirmed/:token", to: "kiosk#confirmed", as: :kiosk_confirmed

  namespace :settings do
    resources :integrations, only: [:index, :new, :create, :destroy]
    resources :staff, only: [:index, :create, :update, :destroy] do
      resources :shifts, only: [:index, :create, :destroy], controller: "staff_shifts" do
        member do
          patch :approve
        end
      end
    end
    resource :analytics, only: [:show] do
      get :export, on: :member
    end
    resource :profile, only: [:show, :update], controller: "profile"
    resource :practice, only: [:show, :update], controller: "practice"
    resource :sync_health, only: [:show], controller: "sync_health"
    resource :timesheet, only: [:show], controller: "timesheet" do
      get :export, on: :member
    end
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
