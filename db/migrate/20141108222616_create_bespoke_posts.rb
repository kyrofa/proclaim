class CreateBespokePosts < ActiveRecord::Migration
	def change
		create_table :bespoke_posts do |t|
			t.belongs_to :author, index: true

			t.string :title, null: false, default: ""
			t.text :body, null: false, default: ""

			t.boolean :published, null: false, default: false
			t.datetime :publication_date

			t.timestamps
		end
	end
end
