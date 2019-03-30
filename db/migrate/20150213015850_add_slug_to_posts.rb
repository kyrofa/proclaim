class AddSlugToPosts < ActiveRecord::Migration[5.2]
	def change
		change_table :proclaim_posts do |t|
			t.string :slug
		end

		# This ensures that even if two clients try to create the same
		# post slug at exactly the same time, the database won't accept
		# one of them (Rails would have)
		add_index :proclaim_posts, :slug, unique: true

		reversible do |direction|
			direction.up do
				print "Generating slugs for existing posts... "
				Proclaim::Post.find_each(&:save)
				puts "done."
			end
		end
	end
end
