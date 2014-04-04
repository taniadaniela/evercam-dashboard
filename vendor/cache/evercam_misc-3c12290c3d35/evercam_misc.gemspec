# -*- encoding: utf-8 -*-
# stub: evercam_misc 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "evercam_misc"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Evercam.io"]
  s.date = "2014-04-04"
  s.description = "Miscellaneous classes extracted from the ./lib directory and used by other Evercam system components."
  s.email = ["howrya@evercam.io"]
  s.files = ["CHANGELOG.md", "LICENSE.txt", "README.md", "lib/evercam_misc", "lib/evercam_misc.rb", "lib/evercam_misc/config.rb", "lib/evercam_misc/errors.rb", "lib/evercam_misc/three_scale_helpers.rb", "lib/evercam_misc/version.rb"]
  s.homepage = "https://evecam.io"
  s.licenses = ["Commercial"]
  s.rubygems_version = "2.2.2"
  s.summary = "Miscellaneous classes used by the Evercam application."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, ["~> 10.2"])
      s.add_runtime_dependency(%q<3scale_client>, ["~> 2.3"])
      s.add_runtime_dependency(%q<dotenv>, ["~> 0.10"])
      s.add_runtime_dependency(%q<sidekiq>, ["~> 2.17"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<rake>, ["~> 10.2"])
      s.add_dependency(%q<3scale_client>, ["~> 2.3"])
      s.add_dependency(%q<dotenv>, ["~> 0.10"])
      s.add_dependency(%q<sidekiq>, ["~> 2.17"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<rake>, ["~> 10.2"])
    s.add_dependency(%q<3scale_client>, ["~> 2.3"])
    s.add_dependency(%q<dotenv>, ["~> 0.10"])
    s.add_dependency(%q<sidekiq>, ["~> 2.17"])
  end
end
