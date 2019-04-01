# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"
require "factory_bot_rails"
require "mocha/minitest"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
	ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
	ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
	ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
	ActiveSupport::TestCase.fixtures :all
end

def sign_in(user)
	ApplicationController.any_instance.stubs(:current_user).returns(user)
	ApplicationController.any_instance.stubs(:authenticate_user).returns(!user.nil?)

	if @controller
		@controller.stubs(:current_user).returns(user)
		@controller.stubs(:authenticate_user).returns(true)
	end
end

def test_image_file_path
	File.join(Rails.root, '../', 'support', 'images', 'test.jpg')
end