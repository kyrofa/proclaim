class AddSubtitleToPosts < ActiveRecord::Migration[5.2]
	def change
		add_column :proclaim_posts, :subtitle, :string, null: false, default: ""
	end
end
