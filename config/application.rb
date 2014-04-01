require File.expand_path('../boot', __FILE__)

require 'rails/all'

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

    # Incorporate Bootstrap elements.
    config.assets.paths << "#{Rails.root.to_s}/vendor/assets/fonts"
    config.assets.paths << "#{Rails.root.to_s}/vendor/assets/javascripts"
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    config.assets.precompile += ['bootstrap-3.1.0.min.css',
                                 'bootstrap-theme-3.1.0.min.css',
                                 'bootstrap-3.1.0.min.js',
                                 'glyphicons-halflings-regular.eot',
                                 'glyphicons-halflings-regular.svg',
                                 'glyphicons-halflings-regular.ttf',
                                 'glyphicons-halflings-regular.woff',
                                 'spin-1.3.2.min.js',
                                 'ladda-0.8.0.min.js',
                                 'ladda-themeless-0.8.0.min.css']

    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      r301      %r{io/v1/(.*)},    'https://api.evercam.io/v1/$1'
    end

  end
end
