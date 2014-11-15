class CreateBespokeComments < ActiveRecord::Migration
	def change
		create_table :bespoke_comments do |t|
			t.belongs_to :post, index: true
			t.integer :parent_id

			t.string :author

			t.string :title
			t.text :body

			t.timestamps
		end
	end
end
