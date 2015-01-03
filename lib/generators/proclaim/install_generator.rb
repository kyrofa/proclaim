require 'rails/generators/base'

module Proclaim
	module Generators
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path("../templates", __FILE__)

			def install_initializers
				template "initialize_proclaim.rb", "config/initializers/proclaim.rb"
			end
		end
	end
end
