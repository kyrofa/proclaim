class CreateProclaimImages < ActiveRecord::Migration[5.2]
	def change
		create_table :proclaim_images do |t|
			t.belongs_to :post, index: true
			t.string :image

			t.timestamps null: false
		end

		add_foreign_key :proclaim_images, :proclaim_posts, column: :post_id
	end
end
