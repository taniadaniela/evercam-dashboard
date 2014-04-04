# -*- encoding: utf-8 -*-
# stub: evercam_models 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "evercam_models"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Evercam.io"]
  s.date = "2014-04-04"
  s.description = "This library contains all of the models used by the Evercam system."
  s.email = ["howrya@evercam.io"]
  s.files = ["CHANGELOG.md", "LICENSE.txt", "README.md", "lib/evercam_models", "lib/evercam_models.rb", "lib/evercam_models/access_right.rb", "lib/evercam_models/access_right_set.rb", "lib/evercam_models/access_token.rb", "lib/evercam_models/camera.rb", "lib/evercam_models/camera_activity.rb", "lib/evercam_models/camera_endpoint.rb", "lib/evercam_models/camera_share.rb", "lib/evercam_models/client.rb", "lib/evercam_models/country.rb", "lib/evercam_models/right_sets", "lib/evercam_models/right_sets/account_right_set.rb", "lib/evercam_models/right_sets/camera_right_set.rb", "lib/evercam_models/right_sets/snapshot_right_set.rb", "lib/evercam_models/snapshot.rb", "lib/evercam_models/user.rb", "lib/evercam_models/vendor.rb", "lib/evercam_models/vendor_model.rb", "lib/evercam_models/version.rb"]
  s.homepage = "https://evercam.io"
  s.licenses = ["Commercial"]
  s.rubygems_version = "2.2.2"
  s.summary = "Evercam model classes library."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<database_cleaner>, ["~> 1.2"])
      s.add_development_dependency(%q<factory_girl>, ["~> 4.4"])
      s.add_development_dependency(%q<mocha>, ["~> 1.0"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_development_dependency(%q<rake>, ["~> 10.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14"])
      s.add_development_dependency(%q<webmock>, ["~> 1.17"])
      s.add_runtime_dependency(%q<bcrypt>, ["~> 3.1"])
      s.add_runtime_dependency(%q<dotenv>, ["~> 0.10"])
      s.add_runtime_dependency(%q<evercam_misc>, ["~> 0.0"])
      s.add_runtime_dependency(%q<georuby>, ["~> 2.2"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_runtime_dependency(%q<pg>, ["~> 0.17"])
      s.add_runtime_dependency(%q<sequel>, ["~> 4.9"])
      s.add_runtime_dependency(%q<simplecov>, ["~> 0.8"])
      s.add_runtime_dependency(%q<timezone>, ["~> 0.3"])
      s.add_runtime_dependency(%q<typhoeus>, ["~> 0.6"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<database_cleaner>, ["~> 1.2"])
      s.add_dependency(%q<factory_girl>, ["~> 4.4"])
      s.add_dependency(%q<mocha>, ["~> 1.0"])
      s.add_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_dependency(%q<rake>, ["~> 10.2"])
      s.add_dependency(%q<rspec>, ["~> 2.14"])
      s.add_dependency(%q<webmock>, ["~> 1.17"])
      s.add_dependency(%q<bcrypt>, ["~> 3.1"])
      s.add_dependency(%q<dotenv>, ["~> 0.10"])
      s.add_dependency(%q<evercam_misc>, ["~> 0.0"])
      s.add_dependency(%q<georuby>, ["~> 2.2"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<pg>, ["~> 0.17"])
      s.add_dependency(%q<sequel>, ["~> 4.9"])
      s.add_dependency(%q<simplecov>, ["~> 0.8"])
      s.add_dependency(%q<timezone>, ["~> 0.3"])
      s.add_dependency(%q<typhoeus>, ["~> 0.6"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<database_cleaner>, ["~> 1.2"])
    s.add_dependency(%q<factory_girl>, ["~> 4.4"])
    s.add_dependency(%q<mocha>, ["~> 1.0"])
    s.add_dependency(%q<rack-test>, ["~> 0.6"])
    s.add_dependency(%q<rake>, ["~> 10.2"])
    s.add_dependency(%q<rspec>, ["~> 2.14"])
    s.add_dependency(%q<webmock>, ["~> 1.17"])
    s.add_dependency(%q<bcrypt>, ["~> 3.1"])
    s.add_dependency(%q<dotenv>, ["~> 0.10"])
    s.add_dependency(%q<evercam_misc>, ["~> 0.0"])
    s.add_dependency(%q<georuby>, ["~> 2.2"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<pg>, ["~> 0.17"])
    s.add_dependency(%q<sequel>, ["~> 4.9"])
    s.add_dependency(%q<simplecov>, ["~> 0.8"])
    s.add_dependency(%q<timezone>, ["~> 0.3"])
    s.add_dependency(%q<typhoeus>, ["~> 0.6"])
  end
end
