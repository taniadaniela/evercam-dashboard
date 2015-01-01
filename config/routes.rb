EvercamDashboard::Application.routes.draw do

  namespace :admin do
    get '/' => 'dashboard#index'
    get '/map' => 'dashboard#map'
    get '/kpi' => 'dashboard#kpi'
    resources :dash_cameras, path: :cameras
    resources :dash_users, path: :users
    resources :dash_vendor_model, path: :models
    get '/users/:id/impersonate' => 'dash_users#impersonate', as: :impersonate
    put '/users/:id' => 'dash_users#update'
    put '/models/:id' => 'dash_vendor_model#update'
    get '/models/load.vendor.model' => 'dash_vendor_model#load_vendor_model'
  end

  root 'cameras#index', as: :root

  scope :cameras do
    get '/', to: redirect('/'), as: :cameras_index
    get '/new' => 'cameras#new'
    post '/new' => 'cameras#create'
    get '/transfer' => 'cameras#transfer'
    get '/:id' => 'cameras#single', as: :cameras_single
    post '/:id' => 'cameras#update'
    delete '/:id' => 'cameras#delete'
  end

  scope :webhooks do
    post '/' => 'webhooks#create'
    delete '/:id' => 'webhooks#delete'
  end

  get 'public/cameras' => 'public#index'
  get 'public/cameras/:id' => 'public#single'

  get 'locations' => 'locations#index'

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
  get '/sessions', to: redirect('/')
  match '/signup', to: 'users#new', via: 'get'
  post '/signup', to: 'users#create'
  get '/reset', to: 'users#password_reset_request'
  post '/reset', to: 'users#password_reset_request'
  get '/newpassword', to: 'users#password_update_form'
  post '/newpassword', to: 'users#password_update'
  get '/users/:id/settings', to: 'users#settings'
  get '/confirm', to: 'users#confirm'
  post '/users/:id/settings', to: 'users#settings_update'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/widget_signin', to: 'sessions#widget_new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  get '/dev' => 'pages#dev'
  get '/swagger' => 'pages#swagger'
  get '/widgets-new' => 'widgets#widgets_new'
  get '/live.view.widget' => 'widgets#live_view_widget'
  get '/live.view.private.widget' => 'widgets#live_view_private_widget'
  get '/widgets-hikvision' => 'widgets#widgets_hikvision'
  get '/hikvision.local.storage' => 'widgets#hikvision_local_storage'
  get '/hikvision.private.widget' => 'widgets#hikvision_private_widget'

  get '/widgets-snapshot-navigator' => 'widgets#widget_snapshot_navigator'
  get '/snapshot.navigator.widget' => 'widgets#snapshot_navigator_widget'
  get '/snapshot.navigator' => 'widgets#snapshot_navigator'

  get '/live' => 'pages#live'
  get '/live/:id' => 'pages#live'
  get '/location' => 'pages#location'

  scope :share do
    post '/' => 'sharing#create'
    delete '/' => 'sharing#delete'
    post '/camera/:id' => 'sharing#update_camera'
    delete '/request' => 'sharing#cancel_share_request'
    patch '/:id' => 'sharing#update_share'
    patch '/request/:id' => 'sharing#update_share_request'
  end

  scope :oauth2 do
    get '/error' => 'oauth2#error'
    post '/feedback' => 'oauth2#feedback'
    get '/authorize' => 'oauth2#authorize'
    post '/authorize' => 'oauth2#post_authorize'
    get '/tokeninfo' => 'oauth2#tokeninfo'
    get '/revoke' => 'oauth2#revoke'
  end
end
