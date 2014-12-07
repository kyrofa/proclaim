# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "factory_girl_rails"
require "mocha/mini_test"
require 'capybara/rails'
require 'database_cleaner'
require 'coffee_script'
require 'sass'
#Capybara.app = Bespoke::Engine

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
	ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

#FactoryGirl.definition_file_paths << "test/dummy/test/factories"
#FactoryGirl.reload

#class ActionController::TestCase
#	include Bespoke::Engine.routes.url_helpers
#end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
end

def sign_in(user)
	ApplicationController.any_instance.stubs(:current_user).returns(user)
	ApplicationController.any_instance.stubs(:authenticate_user).returns(true)

	if @controller
		@controller.stubs(:current_user).returns(user)
		@controller.stubs(:authenticate_user).returns(true)
	end
end
