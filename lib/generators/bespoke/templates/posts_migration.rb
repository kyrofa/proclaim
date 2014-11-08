class BespokeCreatePosts < ActiveRecord::Migration
	def change
		create_table(:posts) do |t|
			t.belongs_to :<%= plural_name %>

			t.timestamps
		end
	end
end
