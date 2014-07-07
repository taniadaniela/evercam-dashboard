EvercamDashboard::Application.routes.draw do

   root 'cameras#index'

   get 'cameras/transfer' => 'cameras#transfer'
   get 'cameras' => 'cameras#index', as: :cameras_index
   get 'cameras/new' => 'cameras#new'
   post 'cameras/new' => 'cameras#create'
   get 'cameras/:id/jpg' => 'cameras#jpg'
   get 'cameras/:id' => 'cameras#single', as: :cameras_single
   post 'cameras/:id' => 'cameras#update'
   delete 'cameras/:id' => 'cameras#delete'

   get 'publiccam' => 'public#index'
   get 'publiccam/:id' => 'public#single'

   resources :sessions, only: [:new, :create, :destroy]
   resources :users, only: [:new, :create]
   match '/signup',  to: 'users#new',            via: 'get'
   post '/signup',  to: 'users#create'
   get '/reset',  to: 'users#password_reset_request'
   post '/reset',  to: 'users#password_reset_request'
   get '/newpassword',  to: 'users#password_update_form'
   post '/newpassword',  to: 'users#password_update'
   get '/users/:id/settings',  to: 'users#settings'
   get '/confirm',  to: 'users#confirm'
   post '/users/:id/settings',  to: 'users#settings_update'
   match '/signin',  to: 'sessions#new',         via: 'get'
   match '/signout', to: 'sessions#destroy',     via: 'delete'

   get '/dev' => 'pages#dev'
   get '/swagger' => 'pages#swagger'
   get '/widgets' => 'pages#widgets'
   get '/widgets-new' => 'pages#widgets_new'

   get '/add-android' => 'pages#add_android'

   post '/share/camera/:id' => 'sharing#update_camera'
   delete '/share' => 'sharing#delete'
   delete '/share/request' => 'sharing#cancel_share_request'
   post '/share' => 'sharing#create'
   patch '/share/:id' => 'sharing#update_share'
   patch '/share/request/:id' => 'sharing#update_share_request'
end
