module Bespoke
	class User < ActiveRecord::Base
		has_many :posts, inverse_of: :author
		self.table_name = Bespoke.author_table_name

		def readonly?
			not Rails.env.test?
		end

		def delete
			unless Rails.env.test?
				raise ReadOnlyRecord
			end
		end
	end
end
