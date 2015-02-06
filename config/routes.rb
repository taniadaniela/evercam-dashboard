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

  resources :charges

  root to: redirect('/v1/cameras'), as: :root

  get '/v1/cameras' => 'cameras#index', as: :cameras_index
  get '/cameras/new' => 'cameras#new'
  get '/cameras/:id/clone' => 'cameras#new'
  post '/cameras/new' => 'cameras#create'
  get '/cameras/transfer' => 'cameras#transfer'
  get '/v1/cameras/:id' => 'cameras#single', as: :cameras_single
  post '/cameras/:id' => 'cameras#update'
  delete '/cameras/:id' => 'cameras#delete'

  post '/cameras/:id/webhooks' => 'webhooks#create'
  delete '/cameras/:id/webhooks' => 'webhooks#delete'

  get '/v1/public/cameras' => 'public#index'
  get '/v1/public/cameras/:id' => 'public#single'

  #TODO: remove this after Node.js snapshot servers are taken down
  get 'publiccam/:id', to: redirect('public/cameras/%{id}')

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
  get '/v1/users/:id/settings', to: 'users#settings'
  get '/users/:id/resend', to: 'users#resend_confirmation_email'
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

  get '/live/:id' => 'pages#live'

  post '/share' => 'sharing#create'
  delete '/share' => 'sharing#delete'
  post '/share/camera/:id' => 'sharing#update_camera'
  delete '/share/request' => 'sharing#cancel_share_request'
  post '/share/request/resend' => 'sharing#resend_share_request'
  patch '/share/request' => 'sharing#update_share_request'
  patch '/share/:id' => 'sharing#update_share'

  get '/oauth2/error' => 'oauth2#error'
  post '/oauth2/feedback' => 'oauth2#feedback'
  get '/oauth2/authorize' => 'oauth2#authorize'
  post '/oauth2/authorize' => 'oauth2#post_authorize'
  get '/oauth2/tokeninfo' => 'oauth2#tokeninfo'
  get '/oauth2/revoke' => 'oauth2#revoke'
end
