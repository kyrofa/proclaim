class EditPage
	def medium_inserted_image_html(image)
		"<div class=\"mediumInsert\"><div class=\"mediumInsert-placeholder\"><figure class=\"mediumInsert-images\"><img src=\"#{image.image.url}\"></figure></div></div>"
	end
end
