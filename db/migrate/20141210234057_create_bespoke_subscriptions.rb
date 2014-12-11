class CreateBespokeSubscriptions < ActiveRecord::Migration
	def change
		create_table :bespoke_subscriptions do |t|
			t.belongs_to :post, index: true
			t.string :email

			t.timestamps
		end

		# This ensures that even if two clients try to create the same
		# subscription at exactly the same time, the database won't accept
		# one of them (Rails would have)
		add_index :bespoke_subscriptions, [:post_id, :email], :unique => true
	end
end
