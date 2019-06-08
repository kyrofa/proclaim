class CreateProclaimSubscriptions < ActiveRecord::Migration[5.2]
	def change
		create_table :proclaim_subscriptions do |t|
			t.belongs_to :comment, index: true
			t.string :name, null: false, default: ""
			t.string :email

			t.timestamps null: false
		end

		add_foreign_key :proclaim_subscriptions, :proclaim_comments, column: :comment_id

		# This ensures that even if two clients try to create the same
		# subscription at exactly the same time, the database won't accept
		# one of them (Rails would have)
		add_index :proclaim_subscriptions, [:comment_id, :email], :unique => true
	end
end
