require 'test_helper'
require 'generators/bespoke/bespoke_generator'

module Bespoke
  class BespokeGeneratorTest < Rails::Generators::TestCase
    tests BespokeGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
