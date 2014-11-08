require 'rails/generators/active_record'

class BespokeGenerator < ActiveRecord::Generators::Base
	argument :attributes, type: :array, default: [], banner: "field:type field:type"

	source_root File.expand_path('../templates', __FILE__)

	def this_is_a_test
		migration_template "posts_migration.rb", "db/migrate/bespoke_create_posts.rb"
	end
end
