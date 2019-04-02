Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    resources :tokens, only: [:create]
    resources :configurations, only: [:index]
    resources :users, param: :email, only: [] do
      member do
        get :reset_password, action: :reset_password
        get :resend_verify, action: :resend_verify
      end
    end
    resources :users, except: [:new] do
      collection do
        put :confirm_reset, action: :confirm_reset
        put :verify, action: :verify
      end
    end
    resources :courses, except: [:new] do
      member do
        # post :registration, action: :register
        # delete :registration, action: :unregister
      end
      resources :projects, shallow: true, except: [:new] do
        resources :test_suites, shallow: true, except: [:new, :update] do
          member do
            get :download, action: :download
          end
        end
        resources :submissions, shallow: true, except: [:destroy, :new, :update] do
          member do
            get :download
          end
        end
      end
    end
  end
end
