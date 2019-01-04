class AddNameToSubscriptions < ActiveRecord::Migration[5.2]
	def change
		change_table :proclaim_subscriptions do |t|
			t.string :name, null: false, default: ""
		end
	end
end
