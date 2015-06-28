# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'selenium-webdriver'
require "factory_girl_rails"
require "faker"
require "mocha/mini_test"
require 'capybara/rails'
require 'database_cleaner'
require 'test_after_commit'
require 'coffee_script'
require 'sass'

Rails.backtrace_cleaner.remove_silencers!
Capybara.default_wait_time = 5 # 5 seconds instead of 2, since we use fades.

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class ActionDispatch::IntegrationTest
	# Make the Capybara DSL available in all integration tests
	include Capybara::DSL
end

if ENV['TRAVIS']
	capabilities = Selenium::WebDriver::Remote::Capabilities.send ENV["BROWSER"]
	capabilities.version = ENV["VERSION"]
	capabilities.platform = ENV["PLATFORM"]

	capabilities['tunnel-identifier'] = ENV['TRAVIS_JOB_NUMBER']
	capabilities['name'] = "Travis ##{ENV['TRAVIS_JOB_NUMBER']}"
	capabilities['deviceName'] = ENV['DEVICE_NAME']
	capabilities['deviceOrientation'] = ENV['DEVICE_ORIENTATION']

	Capybara.register_driver :selenium do |app|
		Capybara::Selenium::Driver.new(app,
			browser: :remote,
			url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com/wd/hub",
			desired_capabilities: capabilities)
	end
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
