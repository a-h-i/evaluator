# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#                api_tokens POST   /api/tokens(.:format)                                                                    api/tokens#create
#        api_configurations GET    /api/configurations(.:format)                                                            api/configurations#index
#   reset_password_api_user GET    /api/users/:email/reset_password(.:format)                                               api/users#reset_password
#    resend_verify_api_user GET    /api/users/:email/resend_verify(.:format)                                                api/users#resend_verify
#   confirm_reset_api_users PUT    /api/users/confirm_reset(.:format)                                                       api/users#confirm_reset
#          verify_api_users PUT    /api/users/verify(.:format)                                                              api/users#verify
#                 api_users GET    /api/users(.:format)                                                                     api/users#index
#                           POST   /api/users(.:format)                                                                     api/users#create
#                  api_user GET    /api/users/:id(.:format)                                                                 api/users#show
#                           PATCH  /api/users/:id(.:format)                                                                 api/users#update
#                           PUT    /api/users/:id(.:format)                                                                 api/users#update
#                           DELETE /api/users/:id(.:format)                                                                 api/users#destroy
#   download_api_test_suite GET    /api/test_suites/:id/download(.:format)                                                  api/test_suites#download
#   api_project_test_suites GET    /api/projects/:project_id/test_suites(.:format)                                          api/test_suites#index
#                           POST   /api/projects/:project_id/test_suites(.:format)                                          api/test_suites#create
#            api_test_suite GET    /api/test_suites/:id(.:format)                                                           api/test_suites#show
#                           DELETE /api/test_suites/:id(.:format)                                                           api/test_suites#destroy
#   download_api_submission GET    /api/submissions/:id/download(.:format)                                                  api/submissions#download
#   api_project_submissions GET    /api/projects/:project_id/submissions(.:format)                                          api/submissions#index
#                           POST   /api/projects/:project_id/submissions(.:format)                                          api/submissions#create
#            api_submission GET    /api/submissions/:id(.:format)                                                           api/submissions#show
#       api_course_projects GET    /api/courses/:course_id/projects(.:format)                                               api/projects#index
#                           POST   /api/courses/:course_id/projects(.:format)                                               api/projects#create
#               api_project GET    /api/projects/:id(.:format)                                                              api/projects#show
#                           PATCH  /api/projects/:id(.:format)                                                              api/projects#update
#                           PUT    /api/projects/:id(.:format)                                                              api/projects#update
#                           DELETE /api/projects/:id(.:format)                                                              api/projects#destroy
#               api_courses GET    /api/courses(.:format)                                                                   api/courses#index
#                           POST   /api/courses(.:format)                                                                   api/courses#create
#                api_course GET    /api/courses/:id(.:format)                                                               api/courses#show
#                           PATCH  /api/courses/:id(.:format)                                                               api/courses#update
#                           PUT    /api/courses/:id(.:format)                                                               api/courses#update
#                           DELETE /api/courses/:id(.:format)                                                               api/courses#destroy
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

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
