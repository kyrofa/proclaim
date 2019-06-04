require 'rails/generators/base'

module Proclaim
	module Generators
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path("../templates", __FILE__)

			desc "Creates a Proclaim initializer and mounts Proclaim in routes."

			def install_initializers
				template "initialize_proclaim.rb", "config/initializers/proclaim.rb"
			end

			def mount_in_routes
				route "mount Proclaim::Engine, at: \"/blog\""
			end

			def show_readme
				readme "README" if behavior == :invoke
			end
		end
	end
end