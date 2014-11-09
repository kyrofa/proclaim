require 'test_helper'
require 'generators/bespoke/install_generator'

module Bespoke
	class InstallGeneratorTest < Rails::Generators::TestCase
		tests Bespoke::Generators::InstallGenerator
		destination Rails.root.join('tmp/generators')
		setup :prepare_destination

		test "generator runs without errors" do
			assert_nothing_raised do
				run_generator
			end
		end
	end
end
