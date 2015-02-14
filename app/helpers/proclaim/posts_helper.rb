module Proclaim
	module PostsHelper
		def fake_form_field(post, attribute, &block)
			if post.errors.any? and not post.errors[attribute].blank?
				content_tag :div, block.call, class: "field_with_errors"
			else
				block.call
			end
		end
	end
end
