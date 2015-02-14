$:.push File.expand_path("../lib", __FILE__)

require "proclaim/version"

Gem::Specification.new do |s|
	s.name        = "proclaim"
	s.version     = Proclaim::VERSION
	s.authors     = ["Kyle Fazzari"]
	s.email       = ["proclaim@status.e4ward.com"]
	s.homepage    = "https://github.com/kyle-f/proclaim"
	s.summary     = "A Rails blogging engine that simplifies your life."
	s.description = <<-EOF
		Most Rails blogging tools include everything you could ever want,
		including things you don't. Proclaim tries to provide the simplest (yet
		beautiful) implementation of a blog via a mountable engine; if more
		functionality is desired, it can easily be combined with other engines.
	EOF
	s.license     = "GPLv3"

	s.files = Dir["{app,config,db,lib,vendor,test}/**/*", "LICENSE", "Rakefile", "README.md", "Gemfile", "proclaim.gemspec", "CHANGELOG", "VERSION"]
	s.test_files = Dir["test/**/*"]

	s.required_ruby_version = '>= 1.9.3'

	s.add_dependency "rails", "~> 4.2"
	s.add_dependency "coffee-rails", "~> 4.1"
	s.add_dependency "sass-rails", "~> 5.0"
	s.add_dependency "jquery-rails", "~> 4.0"
	s.add_dependency "htmlentities", "~> 4.3"
	s.add_dependency "friendly_id", "~> 5.1"
	s.add_dependency "nokogiri", "~> 1.6"
	s.add_dependency "premailer", "~> 1.8"
	s.add_dependency "closure_tree", "~> 5.2"
	s.add_dependency "font-awesome-rails", "~> 4.2"
	s.add_dependency "medium-editor-rails", "~> 1.0"
	s.add_dependency "carrierwave", "~> 0.10"
	s.add_dependency "aasm", "~> 4.0"
	s.add_dependency "rails-timeago", "~> 2.11"
	s.add_dependency "pundit", "~> 0.3"

	s.add_development_dependency "sqlite3", "~> 1.3"
	s.add_development_dependency "factory_girl_rails", "~> 4.5"
	s.add_development_dependency "mocha", "~> 1.1"
	s.add_development_dependency "annotate", "~> 2.6"
	s.add_development_dependency "capybara", "~> 2.4"
	s.add_development_dependency "selenium-webdriver", "~> 2.44"
	s.add_development_dependency "database_cleaner", "~> 1.3"
	s.add_development_dependency "faker", "~> 1.4"
	s.add_development_dependency "test_after_commit", "~> 0.4"
end
