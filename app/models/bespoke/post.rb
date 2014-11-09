module Bespoke
	class Post < ActiveRecord::Base
		belongs_to :author, class_name: Bespoke.author_class
	end
end
