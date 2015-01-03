require 'rails'
require 'coffee-rails'
require 'sass-rails'
require 'jquery-rails'
require 'closure_tree'
require 'font-awesome-rails'
require 'medium-editor-rails'
require 'carrierwave'
require 'aasm'
require 'rails-timeago'
require 'pundit'
require 'premailer'

module Proclaim
	class Engine < ::Rails::Engine
		isolate_namespace Proclaim

		initializer :assets do
			Rails.application.config.assets.precompile += %w{ link.png remove.png resize-bigger.png resize-smaller.png unlink.png }
		end

		initializer :append_migrations do |app|
			engine_root = Pathname(root)
			application_root = Pathname(app.root)
			within_engine = false
			application_root.ascend {|f| within_engine = true and break if f == engine_root}

			unless within_engine # Don't run migrations twice for dummy app
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
