EvercamDashboard::Application.routes.draw do

  namespace :admin do
    get '/' => 'dashboard#index'
    get '/map' => 'dashboard#map'
    get '/kpi' => 'dashboard#kpi'
    resources :dash_cameras, path: :cameras
    resources :dash_users, path: :users
    get '/users/:id/impersonate' => 'dash_users#impersonate', as: :impersonate
    mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'
  end

  root 'cameras#index'

  get 'cameras/transfer' => 'cameras#transfer'
  get 'cameras' => 'cameras#index', as: :cameras_index
  get 'cameras/new' => 'cameras#new'
  post 'cameras/new' => 'cameras#create'
  get 'cameras/:id/jpg' => 'cameras#jpg'
  get 'cameras/:id' => 'cameras#single', as: :cameras_single
  post 'cameras/:id' => 'cameras#update'
  delete 'cameras/:id' => 'cameras#delete'

  post 'webhooks' => 'webhooks#create'
  delete 'webhooks/:id' => 'webhooks#delete'

  get 'publiccam' => 'public#index'
  get 'publiccam/:id' => 'public#single'

  get 'locations' => 'locations#index'

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
  get '/sessions', to: redirect('/')
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
  match '/widget_signin',  to: 'sessions#widget_new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  get '/dev' => 'pages#dev'
  get '/swagger' => 'pages#swagger'
  get '/widgets' => 'widgets#widgets'
  get '/widgets-new' => 'widgets#widgets_new'
  get '/live.view.widget' => 'widgets#live_view_widget'
  get '/live.view.private.widget' => 'widgets#live_view_private_widget'
  get '/widgets-hikvision' => 'widgets#widgets_hikvision'

  get '/add-android' => 'pages#add_android'
  get '/location' => 'pages#location'

  post '/share/camera/:id' => 'sharing#update_camera'
  delete '/share' => 'sharing#delete'
  delete '/share/request' => 'sharing#cancel_share_request'
  post '/share' => 'sharing#create'
  patch '/share/:id' => 'sharing#update_share'
  patch '/share/request/:id' => 'sharing#update_share_request'

  # Oauth2
  get '/oauth2/error' => 'oauth2#error'
  post '/oauth2/feedback' => 'oauth2#feedback'
  get '/oauth2/authorize' => 'oauth2#authorize'
  post '/oauth2/authorize' => 'oauth2#post_authorize'
  get '/oauth2/tokeninfo' => 'oauth2#tokeninfo'
  get '/oauth2/revoke' => 'oauth2#revoke'

end
