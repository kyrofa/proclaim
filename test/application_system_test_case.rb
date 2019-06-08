require "test_helper"
require "selenium-webdriver"
require "capybara/rails"

module Proclaim
	class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
		if ENV['TRAVIS']
			# Sauce labs and Travis are super slow. Increase timeout
			Capybara.default_max_wait_time = 10

			capabilities = Selenium::WebDriver::Remote::Capabilities.send ENV["BROWSER"]
			capabilities.platform = ENV["PLATFORM"]
			capabilities.version = ENV["BROWSER_VERSION"]

			if ENV["PLATFORM"] == "Linux"
				# Browser versions on Linux are super old
				capabilities['seleniumVersion'] = '2.53.1'
			else
				capabilities['seleniumVersion'] = Selenium::WebDriver::VERSION
			end
			capabilities['tunnelIdentifier'] = ENV['TRAVIS_JOB_NUMBER']
			capabilities['name'] = "Travis ##{ENV['TRAVIS_JOB_NUMBER']}"
			capabilities['deviceName'] = ENV['DEVICE_NAME']
			capabilities['deviceOrientation'] = ENV['DEVICE_ORIENTATION']

			driven_by :selenium, using: :remote, options: {
				url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com/wd/hub",
				desired_capabilities: capabilities
			}
		else
			# Five seconds instead of two, since we use fades
			Capybara.default_max_wait_time = 5
			driven_by :selenium, using: :firefox, screen_size: [1400, 1400]
		end

		def assert_difference(expression, difference = 1, message = nil, &block)
			expressions = Array(expression)

			exps = expressions.map do |e|
				e.respond_to?(:call) ? e : -> { eval(e, block.binding) }
			end
			before = exps.map(&:call)
			after = []

			retval = yield

			# Keep evaluating expression until it's either true, or it times out
			start_time = Capybara::Helpers.monotonic_time
			loop do
				after = exps.map(&:call)
				break if before.zip(after).all? { |(b, a)| a == b + difference } ||
				         start_time + Capybara.default_max_wait_time < Capybara::Helpers.monotonic_time
				sleep 0.1
			end

			expressions.zip(after).each_with_index do |(code, a), i|
				error  = "#{code.inspect} didn't change by #{difference}"
				error  = "#{message}.\n#{error}" if message
				assert_equal(before[i] + difference, a, error)
			end

			retval
		end
	end
end
