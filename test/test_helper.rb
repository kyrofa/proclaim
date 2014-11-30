# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "factory_girl_rails"
require "mocha/mini_test"

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

def sign_in(user)
	@controller.stubs(:current_user).returns(user)
	@controller.stubs(:authenticate_user).returns(true)
end
