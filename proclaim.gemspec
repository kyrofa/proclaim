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
	spec.license     = "GPLv3"

	# Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
	# to allow pushing to a single host or delete this section to allow pushing to any host.
	if spec.respond_to?(:metadata)
		spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
	else
		raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
	end

	spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

	spec.add_dependency "rails", "~> 5.2.2"
	spec.add_dependency "coffee-rails"
	spec.add_dependency "sassc-rails"
	spec.add_dependency "jquery-rails"
	spec.add_dependency "htmlentities"
	spec.add_dependency "friendly_id"
	spec.add_dependency "nokogiri"
	spec.add_dependency "premailer"
	spec.add_dependency "closure_tree"
	spec.add_dependency "font-awesome-rails"
	spec.add_dependency "aasm"
	spec.add_dependency "rails-timeago"
	spec.add_dependency "pundit"

	spec.add_development_dependency "sqlite3"
	spec.add_development_dependency "factory_bot_rails"
	spec.add_development_dependency "mocha"
	spec.add_development_dependency "annotate"
	spec.add_development_dependency "capybara"
	spec.add_development_dependency "selenium-webdriver"
	spec.add_development_dependency "faker"
	spec.add_development_dependency "simplecov"
	spec.add_development_dependency "puma"
	spec.add_development_dependency "mini_racer"
	spec.add_development_dependency "geckodriver-helper"
end
