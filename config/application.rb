require File.expand_path('../boot', __FILE__)

require 'rails/all'
#require "action_controller/railtie"
#require "action_mailer/railtie"
#require "sprockets/railtie"
#require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module EvercamDashboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    GC::Profiler.enable

    # Incorporate Bootstrap elements.
    config.assets.paths << "#{Rails.root.to_s}/vendor/assets/fonts"
    #config.assets.paths << "#{Rails.root.to_s}/vendor/assets/javascripts"
    #config.assets.paths << "#{Rails.root.to_s}/lib/assets/javascripts"
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    config.assets.precompile += ['glyphicons-halflings-regular.eot',
                                 'glyphicons-halflings-regular.svg',
                                 'glyphicons-halflings-regular.ttf',
                                 'glyphicons-halflings-regular.woff',
                                 'proximanova-regular-webfont.woff',
                                 'proximanova-regular-webfont.ttf',
                                 'proximanova-regular-webfont.svg',
                                 'proximanova-regular-webfont.eot',
                                 'proximanova-bold-webfont.woff',
                                 'proximanova-bold-webfont.ttf',
                                 'proximanova-bold-webfont.svg',
                                 'proximanova-bold-webfont.eot',
                                 'Simple-Line-Icons.eot',
                                 'Simple-Line-Icons.svg',
                                 'Simple-Line-Icons.ttf',
                                 'Simple-Line-Icons.woff',
                                 'Simple-Line-Icons.dev.svg',
                                 'spin-1.3.2.min.js',
                                 'ladda-0.8.0.min.js',
                                 'swagger.js',
                                 'cameras.js',
                                 'widgets.js',
                                 'camera_single.js',
                                 'publiccam.js',
                                 'testsnapshot.js',
                                 'jquery.js',
                                 'swagger.css',
                                 'throbber.gif',
                                 'ladda-themeless-0.8.0.min.css',
                                 'custom.js',
                                 'bootbox-4.2.0.js',
                                 'editable-1.5.1.min.js',
                                 'moment.min.js',
                                 'jquery.cookie.js',
                                 'jquery.datetimepicker-2.2.5.min.js',
                                 'jquery.datetimepicker-2.2.5.min.css',
                                 'layout.js',
                                 'jquery.uniform.min-v2.1.min.js',
                                 'metronic-layout.css',
                                 'metronic-components.css',
                                 'uniform.default.min.css',
                                 'quick-sidebar.js',
                                 'jquery.dcjqaccordion.2.7.js',
                                 'rails_admin/rails_admin.css',
                                 'rails_admin/rails_admin.js',
                                 'admin/admin.css',
                                 'admin/admin.js',
                                 'jquery.slimscroll.min.js',
                                 'jquery.nicescroll.js']

    config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif]

    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      r301      %r{io/v1/(.*)},    'https://api.evercam.io/v1/$1'
    end

  end
end










