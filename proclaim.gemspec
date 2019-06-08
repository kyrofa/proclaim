$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "proclaim/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
	spec.name        = "proclaim"
	spec.version     = Proclaim::VERSION
	spec.authors     = ["Kyle Fazzari"]
	spec.email       = ["kyrofa@ubuntu.com"]
	spec.homepage    = "https://github.com/kyrofa/proclaim"
	spec.summary     = "A Rails blogging engine that simplifies your life."
	spec.description = <<-EOF
		Most Rails blogging tools include everything you could ever want,
		including things you don't. Proclaim tries to provide the simplest (yet
		beautiful) implementation of a blog via a mountable engine; if more
		functionality is desired, it can easily be combined with other engines.
	EOF
	spec.license     = "GPL-3.0"

	spec.files = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE", "Rakefile", "README.md"]
        spec.required_ruby_version = '>= 2.6.0'

	spec.add_dependency "rails", "~> 5.2.2"
	spec.add_dependency "coffee-rails", "~> 4.2.2"
	spec.add_dependency "sassc-rails", "~> 2.1.0"
	spec.add_dependency "jquery-rails", "~> 4.3.3"
	spec.add_dependency "htmlentities", "~> 4.3.4"
	spec.add_dependency "friendly_id", "~> 5.2.5"
	spec.add_dependency "nokogiri", "~> 1.10.1"
	spec.add_dependency "premailer", "~> 1.11.1"
	spec.add_dependency "closure_tree", "~> 7.0.0"
	spec.add_dependency "font-awesome-rails", "~> 4.7.0.4"
	spec.add_dependency "aasm", "~> 5.0.1"
	spec.add_dependency "rails-timeago", "~> 2.17.1"
	spec.add_dependency "pundit", "~> 2.0.1"

	spec.add_development_dependency "sqlite3", "~> 1.3.13"
	spec.add_development_dependency "factory_bot_rails", "~> 5.0.0"
	spec.add_development_dependency "mocha", "~> 1.8.0"
	spec.add_development_dependency "annotate", "~> 2.7.4"
	spec.add_development_dependency "capybara", "~> 3.13.2"
	spec.add_development_dependency "selenium-webdriver", "~> 3.141.0"
	spec.add_development_dependency "faker", "~> 1.9.1"
	spec.add_development_dependency "simplecov", "~> 0.16.1"
	spec.add_development_dependency "puma", "~> 3.12.0"
	spec.add_development_dependency "mini_racer", "~> 0.2.5"
	spec.add_development_dependency "geckodriver-helper", "~> 0.23.0"
end
