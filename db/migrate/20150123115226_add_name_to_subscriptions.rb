class AddNameToSubscriptions < ActiveRecord::Migration
	def change
		change_table :proclaim_subscriptions do |t|
			t.string :name, null: false, default: ""
		end
	end
end
