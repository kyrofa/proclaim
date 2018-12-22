$:.push File.expand_path("../lib", __FILE__)

require "proclaim/version"

Gem::Specification.new do |s|
	s.name        = "proclaim"
	s.version     = Proclaim::VERSION
	s.authors     = ["Kyle Fazzari"]
	s.email       = ["proclaim@status.e4ward.com"]
	s.homepage    = "https://github.com/kyrofa/proclaim"
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

	s.add_dependency "rails"
	s.add_dependency "coffee-rails"
	s.add_dependency "sass-rails"
	s.add_dependency "jquery-rails"
	s.add_dependency "htmlentities"
	s.add_dependency "friendly_id"
	s.add_dependency "nokogiri"
	s.add_dependency "premailer"
	s.add_dependency "closure_tree"
	s.add_dependency "font-awesome-rails"
	s.add_dependency "medium-editor-rails"
	s.add_dependency "carrierwave"
	s.add_dependency "aasm"
	s.add_dependency "rails-timeago"
	s.add_dependency "pundit"

	s.add_development_dependency "sqlite3"
	s.add_development_dependency "factory_bot_rails"
	s.add_development_dependency "mocha"
	s.add_development_dependency "annotate"
	s.add_development_dependency "capybara"
	s.add_development_dependency "selenium-webdriver"
	s.add_development_dependency "database_cleaner"
	s.add_development_dependency "faker"
	s.add_development_dependency "simplecov"
	s.add_development_dependency "rails-controller-testing"
	s.add_development_dependency "puma"
end
