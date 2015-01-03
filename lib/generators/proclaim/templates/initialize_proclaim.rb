Proclaim.setup do |config|
	config.author_class = "User"
	config.current_author_method = :current_user
	config.author_name_method = :name
	config.authentication_method = :authenticate_user
	config.asset_host = nil # Will default to root_url
	config.excerpt_length = 500
end
