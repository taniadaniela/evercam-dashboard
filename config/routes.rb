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

   post '/share/camera/:id' => 'sharing#update_camera'
end
