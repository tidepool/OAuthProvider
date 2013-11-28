require 'sidekiq/web'
require 'admin_constraint'

OAuthProvider::Application.routes.draw do
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  
  resources :sessions

  use_doorkeeper do
    controllers :authorizations => 'authorizations'
  end

  # OmniAuth routes:
  get '/auth/:provider/callback', to: 'authentications#create'
  get '/auth/failure', to: 'authentications#failure'
  
  get '/auth/new', to: 'authentications#add_new'  
  get '/auth/client_redirect', to: 'authentications#client_redirect'

  # mount Sidekiq::Web, at: '/sidekiq'
  mount Sidekiq::Web => '/sidekiq', :constraints => AdminConstraint.new
  
  root :to => 'home#index'

  resources :connections

  namespace :api do
    namespace :v1 do
      resources :users do 
        get 'personality', to: 'users#personality'
        post 'reset_password', to: 'users#reset_password'
       
        get 'recommendations/latest', to: 'recommendations#latest'
        get 'recommendations/career', to: 'recommendations#career'
        # get 'recommendations/emotion', to: 'recommendations#emotion'
        get 'recommendations/actions', to: 'recommendations#actions'
        
        get 'games/latest', to: 'games#latest'
        post 'preorders', to: 'preorders#create'

        get 'results', to: 'results#index'
        get 'results/:id', to: 'results#show'

        resources :games do
          get 'results', to: 'results#index'
          get 'progress', to: 'results#progress'
          put 'event_log', to: 'games#update_event_log'
        end

        resource :preferences

        get 'connections', to: 'connections#index'
        get 'connections/:provider/synchronize', to: 'connections#synchronize'
        get 'connections/:provider/progress', to: 'connections#progress'
        delete 'connections/:provider', to: 'connections#destroy'

        get 'activities', to: 'activities#index'
        get 'sleeps', to: 'sleeps#index'

        get 'friends', to: 'friends#index'
        get 'friends/find', to: 'friends#find'
        post 'friends/accept', to: 'friends#accept'
        get 'friends/pending', to: 'friends#pending'
        post 'friends/invite', to: 'friends#invite'
        post 'friends/reject', to: 'friends#reject'
        post 'friends/unfriend', to: 'friends#unfriend'

        get 'games/:game_name/leaderboard', to: 'leaderboards#friends'

        get 'feeds', to: 'activity_stream#index'
      end

      get 'personality/:title', to: 'profile_description#show'

      get 'feeds/:activity_record_id/comments', to: 'comments#index'
      get 'comments/:id', to: 'comments#show'
      post 'feeds/:activity_record_id/comments', to: 'comments#create'
      put  'comments/:id', to: 'comments#update'
      patch 'comments/:id', to: 'comments#update'
      delete 'comments/:id', to: 'comments#destroy'

      get 'feeds/:activity_record_id/highfives', to: 'highfives#index'
      post 'feeds/:activity_record_id/highfives', to: 'highfives#create'
      delete 'highfives/:id', to: 'highfives#destroy'

      post 'fitbit', to: 'fitbit_notifications#notify'
      put 'fitbit', to: 'fitbit_notifications#notify'

      get 'preferences/:type/description', to: 'preferences#description'

      get 'games/:game_name/leaderboard', to: 'leaderboards#global'
      get 'games/:game_id/friend_survey', to: 'friend_surveys#results'
      post 'games/:game_id/friend_survey', to: 'friend_surveys#create'
    end
  end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
