require 'rails'
require 'coffee-rails'
require 'sassc-rails'
require 'jquery-rails'
require 'htmlentities'
require 'friendly_id'
require 'closure_tree'
require 'font-awesome-rails'
require 'aasm'
require 'rails-timeago'
require 'pundit'
require 'premailer'
require 'punching_bag'

module Proclaim
	class Engine < ::Rails::Engine
		isolate_namespace Proclaim

		initializer :assets do
			Rails.application.config.assets.precompile += %w{
				quill.core.js
				quill.js
				quill.min.js
				quill.min.js.map
				quill.bubble.css
				quill.core.css
				quill.snow.css
			}
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
			g.fixture_replacement :factory_bot, :dir => 'test/factories'
		end

		initializer :ensure_secret_key_presence do |app|
			if app.respond_to?(:credentials) && key_exists?(app.credentials)
				Proclaim.secret_key ||= app.credentials.secret_key_base
			elsif app.respond_to?(:secrets) && key_exists?(app.secrets)
				Proclaim.secret_key ||= app.secrets.secret_key_base
			elsif app.config.respond_to?(:secret_key_base) && key_exists?(app.config)
				Proclaim.secret_key ||= app.config.secret_key_base
			elsif app.respond_to?(:secret_key_base) && key_exists?(app)
				Proclaim.secret_key ||= app.secret_key_base
			end

			if Proclaim.secret_key.nil?
				raise <<-ERROR
Proclaim.secret_key was not set. Please add the following to your Proclaim initializer:

  config.secret_key = '#{SecureRandom.hex(64)}'

Please ensure you restarted your application after installing Proclaim or setting the key.
ERROR
			end
		end

		private

		def key_exists?(object)
			object.secret_key_base.present?
		end
	end
end
