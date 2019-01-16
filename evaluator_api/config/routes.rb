Rails.application.routes.draw do
  namespace :api do
    resources :contacts, only: [:create]
    resources :users, param: :email, only: [] do
      member do
        get :resend_verify, action: :resend_verify
        get :reset_password, action: :reset_password
      end
    end
    resources :users, except: [:new] do
      member do
        put :confirm_reset, action: :confirm_reset
        put :verify, action: :verify
      end
    end
    resources :teams, only: [:create, :index]
    resources :courses, except: [:new] do
      member do
        post :registration, action: :register
        delete :registration, action: :unregister
      end
      resources :projects, shallow: true, except: [:new] do
        resources :team_grades, shallow: true, only: [] do
          collection do
            get :latest
          end
        end
        resources :results, shallow: true, only: [:index, :show] do
          collection do
            get :csv
          end
        end
        resources :submissions, shallow: true, except: [:destroy, :new, :update] do
          member do
            get :download
            get :rerun
          end
        end
        resources :test_suites, shallow: true, except: [:new, :update] do
          member do
            get :download, action: :download
          end
        end
      end
    end
    resources :tokens, only: [:create]
    resources :configurations, only: [:index]
    resources :project_bundles, only: [:create, :index] do
      member do
        get :download
      end
    end
  end
end
