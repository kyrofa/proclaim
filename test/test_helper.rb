# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "factory_girl_rails"
require "faker"
require "mocha/mini_test"
require 'capybara/rails'
require 'database_cleaner'
require 'test_after_commit'
require 'coffee_script'
require 'sass'
#Capybara.app = Proclaim::Engine

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

#FactoryGirl.definition_file_paths << "test/dummy/test/factories"
#FactoryGirl.reload

#class ActionController::TestCase
#	include Proclaim::Engine.routes.url_helpers
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

def wait_until
	require "timeout"
	begin
		Timeout.timeout(Capybara.default_wait_time) do
			sleep(0.1) until value = yield
			value
		end
	rescue
	end
end

def test_image_file_path
	File.join(Rails.root, '../', 'support', 'images', 'test.jpg')
end
