class CreateProclaimComments < ActiveRecord::Migration
	def change
		create_table :proclaim_comments do |t|
			t.belongs_to :post, index: true
			t.integer :parent_id

			t.string :author
			t.text :body

			t.timestamps null: false
		end

		add_foreign_key :proclaim_comments, :proclaim_posts, column: :post_id
	end
end
