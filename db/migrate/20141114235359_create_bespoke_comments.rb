class CreateBespokeComments < ActiveRecord::Migration
	def change
		create_table :bespoke_comments do |t|
			t.belongs_to :post, index: true
			t.integer :parent_id

			t.string :author
			t.text :body

			t.timestamps null: false
		end

		add_foreign_key :bespoke_comments, :posts
	end
end
