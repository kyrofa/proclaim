$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bespoke/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
	s.name        = "bespoke"
	s.version     = Bespoke::VERSION
	s.authors     = ["Kyle Fazzari"]
	s.email       = ["bespoke@status.e4ward.com"]
	s.homepage    = "https://source.rainveiltech.com/krf/bespoke"
	s.summary     = "Basic blogging engine."
	s.description = "Basic blogging engine."
	s.license     = "GPLv3"

	s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
	s.test_files = Dir["test/**/*"]

	s.add_dependency "rails", "~> 4.1.7"
	s.add_dependency "coffee-rails", "~> 4.0.0"
	s.add_dependency "sass-rails", "> 4.0.3"
	s.add_dependency "jquery-rails"
	s.add_dependency "closure_tree"
	s.add_dependency "pundit" # For simple authorization

	s.add_development_dependency "sqlite3"
	s.add_development_dependency "factory_girl_rails"
	s.add_development_dependency "mocha"
	s.add_development_dependency "annotate"
	s.add_development_dependency "capybara"
	s.add_development_dependency "selenium-webdriver"
	s.add_development_dependency "database_cleaner"
end
