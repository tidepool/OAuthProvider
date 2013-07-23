require 'sidekiq/web'

OAuthProvider::Application.routes.draw do
  use_doorkeeper do
    controllers :authorizations => 'authorizations'
  end

  # OmniAuth routes:
  get '/auth/:provider/callback', to: 'authentications#create'
  get '/auth/failure', to: 'authentications#failure'
  
  get '/auth/new', to: 'authentications#add_new'  
  # resources :sessions
  # resources :users

  mount Sidekiq::Web, at: '/sidekiq'

  root :to => 'home#index'

  resources :connections

  namespace :api do
    namespace :v1 do
      # get 'users/finish_login', to: 'users#finish_login'   
      resources :users do 
        get 'personality', to: 'users#personality'
       
        get 'recommendations/latest', to: 'recommendations#latest'
        get 'recommendations/career', to: 'recommendations#career'
        # get 'recommendations/emotion', to: 'recommendations#emotion'
        get 'recommendations/actions', to: 'recommendations#actions'
        
        get 'games/latest', to: 'games#latest'
        post 'preorders', to: 'preorders#create'

        get 'results', to: 'results#index'
        # get 'results/latest', to: 'results#latest'
        get 'results/:id', to: 'results#show'

        resources :games do
          # get 'result' => 'results#show'
          get 'results', to: 'results#index'
          # post 'result' => 'results#create'
          get 'progress', to: 'results#progress'
          # get 'latest' => 'results#show'
        end

        resource :preferences

        get 'connections', to: 'connections#index'
        get 'connections/:provider/synchronize', to: 'connections#synchronize'
        get 'connections/:provider/progress', to: 'connections#progress'

        get 'activities', to: 'activities#index'
      end
            
      post '/user_events' => 'user_events#create'

      get 'preferences/:type/description', to: 'preferences#description'

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
