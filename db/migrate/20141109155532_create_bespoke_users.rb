class CreateBespokeUsers < ActiveRecord::Migration
	def change
		if Rails.env.test?
			create_table :users do |t|
				t.string :first_name
				t.string :last_name

				t.timestamps
			end
		end
	end
end
