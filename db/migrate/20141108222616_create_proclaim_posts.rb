class CreateProclaimPosts < ActiveRecord::Migration
	def change
		create_table :proclaim_posts do |t|
			t.belongs_to :author, index: true

			t.string :title, null: false, default: ""
			t.text :body, null: false, default: ""

			t.string :state, null: false, default: "draft", index: true

			t.datetime :published_at
			t.timestamps null: false
		end
	end
end
