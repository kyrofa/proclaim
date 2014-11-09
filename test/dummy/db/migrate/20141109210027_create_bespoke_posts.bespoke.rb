# This migration comes from bespoke (originally 20141108222616)
class CreateBespokePosts < ActiveRecord::Migration
	def change
		create_table :bespoke_posts do |t|
			t.belongs_to :author, index: true
			t.string :title
			t.text :body

			t.timestamps
		end
	end
end
