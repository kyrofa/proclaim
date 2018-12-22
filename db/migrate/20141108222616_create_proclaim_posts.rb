class CreateProclaimPosts < ActiveRecord::Migration[5.2]
	def change
		create_table :proclaim_posts do |t|
			t.belongs_to :author, index: true

			t.string :title, null: false, default: ""
			t.text :body, null: false, default: ""
			t.text :quill_body, null: false, default: ""

			t.string :state, null: false, default: "draft", index: true
			t.string :slug

			t.datetime :published_at
			t.timestamps null: false
		end

		# This ensures that even if two clients try to create the same
		# post slug at exactly the same time, the database won't accept
		# one of them (Rails would have)
		add_index :proclaim_posts, :slug, unique: true
	end
end
