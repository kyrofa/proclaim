require 'rails'
require 'coffee-rails'
require 'sass-rails'
require 'jquery-rails'
require 'closure_tree'
require 'pundit'

module Bespoke
	class Engine < ::Rails::Engine
		isolate_namespace Bespoke

		initializer :append_migrations do |app|
			unless app.root.to_s.match root.to_s
				config.paths["db/migrate"].expanded.each do |expanded_path|
					app.config.paths["db/migrate"] << expanded_path
				end
			end
		end

		config.generators do |g|
			g.fixture_replacement :factory_girl, :dir => 'test/factories'
		end
	end
end
