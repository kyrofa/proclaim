require 'rails/generators/base'

module Bespoke
	module Generators
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path("../templates", __FILE__)

			def install_initializer
				template "initialize_bespoke.rb", "config/initializers/bespoke.rb"
			end
		end
	end
end
