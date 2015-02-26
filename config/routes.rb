Rails.application.routes.draw do

  

  resources :stripe_customers

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
  resources :stripe_customers, only: [:new, :create]
  post '/users/:id/settings/charge' => 'charges#create'
  post '/users/:id/settings/subscription' => 'charges#subscription_create'
  get '/users/:id/settings/subscription' => 'charges#subscription_update'

  root to: redirect('/v1/cameras'), as: :root

  get '/v1/cameras' => 'cameras#index', as: :cameras_index
  get '/v1/cameras/new' => 'cameras#new', as: :cameras_new
  post '/v1/cameras/new' => 'cameras#create'
  get '/cameras/transfer' => 'cameras#transfer'
  get '/v1/cameras/:id' => 'cameras#single', as: :cameras_single
  get '/v1/cameras/:id/clone' => 'cameras#new', as: :cameras_clone
  post '/v1/cameras/:id' => 'cameras#update'
  delete '/cameras/:id' => 'cameras#delete'

  get '/v1/cameras/:id/*subpath' => 'cameras#single'

  post '/cameras/:id/webhooks' => 'webhooks#create'
  delete '/cameras/:id/webhooks' => 'webhooks#delete'

  get '/v1/public/cameras' => 'public#index', as: :public_cameras_index
  get '/v1/public/cameras/:id' => 'public#single', as: :public_cameras_single

  #TODO: remove this after Node.js snapshot servers are taken down
  get 'publiccam/:id' => redirect('public/cameras/%{id}')

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :edit]
  get '/sessions' => redirect('/')

  get '/v1/users/signup' => 'users#new', as: :signup
  post '/v1/users/signup' => 'users#create'
  get '/v1/users/password-reset' => 'users#password_reset_request', as: :password_reset
  post '/v1/users/password-reset' => 'users#password_reset_request'
  get '/v1/users/password-new' => 'users#password_update_form', as: :password_new
  post '/v1/users/password-new' => 'users#password_update'
  get '/v1/users/:id/resend' => 'users#resend_confirmation_email', as: :user_email_resend
  get '/confirm' => 'users#confirm'
  get '/v1/users/signin' => 'sessions#new', as: :signin
  get '/widget_signin' => 'sessions#widget_new', as: :widget_signin
  delete '/v1/users/signout' => 'sessions#destroy', as: :signout
  get '/v1/users/:id' => 'users#settings', as: :user
  post '/v1/users/:id' => 'users#settings_update'

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

  get '*path' => 'pages#log_and_redirect'
end
