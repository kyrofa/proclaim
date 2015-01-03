require 'test_helper'
require 'generators/proclaim/install_generator'

module Proclaim
	class InstallGeneratorTest < Rails::Generators::TestCase
		tests Proclaim::Generators::InstallGenerator
		destination Rails.root.join('tmp/generators')
		setup :prepare_destination

		test "generator runs without errors" do
			assert_nothing_raised do
				run_generator
			end
		end
	end
end
