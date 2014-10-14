namespace :heroku do
  desc 'restarts all heroku dynos'
  task :restart do
    Heroku::API.new(:api_key => '12b77d5a-4ce6-46c0-bf4b-d63dbcfbe368').post_ps_restart('cameras')
  end
end
