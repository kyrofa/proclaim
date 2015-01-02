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
require 'reverse_markdown'

module Bespoke
	class Engine < ::Rails::Engine
		isolate_namespace Bespoke

		initializer :assets do
			Rails.application.config.assets.precompile += %w{ link.png remove.png resize-bigger.png resize-smaller.png unlink.png bespoke/email.css }
		end

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
