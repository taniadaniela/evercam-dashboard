EvercamDashboard::Application.routes.draw do

   root 'cameras#index'

   get 'cameras' => 'cameras#index', as: :cameras_index
   get 'cameras/new' => 'cameras#new'
   post 'cameras/new' => 'cameras#create'
   get 'cameras/:id/jpg' => 'cameras#jpg'
   get 'cameras/:id' => 'cameras#single', as: :cameras_single
   post 'cameras/:id' => 'cameras#update'
   delete 'cameras/:id' => 'cameras#delete'

   resources :sessions, only: [:new, :create, :destroy]
   resources :users, only: [:new, :create]
   match '/signup',  to: 'users#new',            via: 'get'
   post '/signup',  to: 'users#create'
   get '/users/:id/settings',  to: 'users#settings'
   get '/confirm',  to: 'users#confirm'
   post '/users/:id/settings',  to: 'users#settings_update'
   match '/signin',  to: 'sessions#new',         via: 'get'
   match '/signout', to: 'sessions#destroy',     via: 'delete'

   get '/dev' => 'pages#dev'
   get '/swagger' => 'pages#swagger'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
