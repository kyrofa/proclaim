Bespoke.setup do |config|
	config.author_class = "User"
	config.current_author_method = :current_user
	config.authentication_path = :new_user_session_path
end
